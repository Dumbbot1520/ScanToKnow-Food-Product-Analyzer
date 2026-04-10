// // src/services/ocrPipeline.service.js
// import Ingredient from "../models/ingredient.model.js";
// import Additive from "../models/additive.model.js";
// import { extractIngredientsAndAdditives } from "./ingredientExtractor.service.js";
// import { computeNOVA } from "./nova.service.js";

// /* ✅ REQUIRED: regex safety */
// function escapeRegex(text) {
//   return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
// }

// export async function runOCRPipeline(rawText) {
//   // 1️⃣ Extract text → tokens
//   const { ingredients, additives } =
//     extractIngredientsAndAdditives(rawText);

//   // 2️⃣ Resolve INGREDIENTS (SAFE)
//   const ingredientDocs = await Promise.all(
//     ingredients.map(name => {
//       const safe = escapeRegex(name);
//       return Ingredient.findOne({
//         $or: [
//           { canonical_name: new RegExp(`^${safe}$`, "i") },
//           { aliases: new RegExp(`^${safe}$`, "i") }
//         ]
//       }).lean();
//     })
//   );

//   // ✅ ONLY RETURN DB-MATCHED INGREDIENTS
//   const resolvedIngredients = ingredientDocs
//     .filter(doc => doc && doc.canonical_name)
//     .map(doc => ({
//       name: doc.canonical_name,
//       description: doc.description || null,
//       source_tag: doc.source_tag || null
//     }));

//   // 3️⃣ Resolve ADDITIVES (SAFE)
//   const additiveDocs = await Promise.all(
//     additives.map(code => {
//       const safe = escapeRegex(code);
//       return Additive.findOne({
//         $or: [
//           { code: new RegExp(`^${safe}$`, "i") },
//           { synonyms: new RegExp(`^${safe}$`, "i") }
//         ]
//       }).lean();
//     })
//   );

//   const resolvedAdditives = additiveDocs
//     .filter(a => a && a.code)
//     .map(a => ({
//       code: a.code.toUpperCase(),
//       name: a.name,
//       description: a.description || null,
//       source_tag: a.source_tag || null
//     }));

//   // 4️⃣ NOVA (unchanged)
//   const nova = computeNOVA({
//     ingredients,
//     additives
//   });

//   return {
//     ingredients: resolvedIngredients,
//     additives: resolvedAdditives,
//     nova
//   };
// }


/* =========================================================
   ocrPipeline.service.js — v3.0
   All DB matching lives here.
   Extractor gives { eCodes[], unresolvedNames[] }
   We resolve everything against DB with fuzzy fallback.
   ========================================================= */

import Ingredient from "../models/ingredient.model.js";
import Additive   from "../models/additive.model.js";
import { extractIngredientsAndAdditives, extractNutrimentsFromText } from "./ingredientExtractor.service.js";

/* =========================================================
   LEVENSHTEIN DISTANCE
   For fuzzy name matching — handles OCR typos
   ========================================================= */
function levenshtein(a, b) {
  const m = a.length, n = b.length;
  const dp = Array.from({ length: m + 1 }, (_, i) =>
    Array.from({ length: n + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0))
  );
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i-1] === b[j-1]
        ? dp[i-1][j-1]
        : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]);
    }
  }
  return dp[m][n];
}

/* =========================================================
   SOURCE TAG → HEALTH INFO
   Converts emoji source_tag + health_rating → UI-friendly object
   ========================================================= */
function resolveHealthInfo(doc) {
  const rating = doc.health_rating ?? null;
  let label = "unknown";
  let color = "grey";

  if (rating !== null) {
    if (rating >= 85)      { label = "very_good"; color = "green";  }
    else if (rating >= 60) { label = "good";      color = "green";  }
    else if (rating >= 40) { label = "okay";      color = "yellow"; }
    else if (rating >= 20) { label = "poor";      color = "orange"; }
    else                   { label = "very_poor"; color = "red";    }
  }

  return { health_rating: rating, health_label: label, health_color: color };
}

/* =========================================================
   RESOLVE E-CODES → Additive DB docs
   Strategy:
   1. Exact code match (case-insensitive): "e330" → E330
   2. Synonym match: synonyms array contains "E330"
   ========================================================= */
async function resolveECodes(eCodes) {
  if (!eCodes.length) return { resolved: [], unresolved: [] };

  const resolved   = [];
  const unresolved = [];

  await Promise.all(eCodes.map(async (code) => {
    const upper = code.toUpperCase(); // "E330"

    const doc = await Additive.findOne({
      $or: [
        { code:     { $regex: `^${upper}$`,  $options: "i" } },
        { synonyms: { $elemMatch: { $regex: `^${upper}$`, $options: "i" } } },
      ]
    }).lean();

    if (doc) {
      resolved.push({
        code:         doc.code,
        name:         doc.name,
        description:  doc.description  ?? null,
        category:     doc.category     ?? null,
        ...resolveHealthInfo(doc),
      });
    } else {
      unresolved.push(code);
    }
  }));

  return { resolved, unresolved };
}

/* =========================================================
   RESOLVE UNRESOLVED NAMES → Additive OR Ingredient
   Strategy per name:
   1. Try Additive.synonyms exact (case-insensitive)
   2. Try Additive.name exact (case-insensitive)
   3. Try Ingredient.canonical_name exact (case-insensitive)
   4. Try Ingredient.aliases exact (case-insensitive)
   5. Try Additive.synonyms fuzzy (Levenshtein ≤ 2, only for short names)
   6. Try Ingredient.canonical_name fuzzy (Levenshtein ≤ 2)
   7. Try Ingredient.aliases contains (partial match)
   8. Unmatched → unresolved_terms
   ========================================================= */
async function resolveNames(unresolvedNames) {
  if (!unresolvedNames.length) {
    return { ingredients: [], additives: [], unresolved_terms: [] };
  }

  // Load all additives and ingredients once (small collections)
  // This avoids N×2 DB round-trips and is faster for ≤200 docs
  const [allAdditives, allIngredients] = await Promise.all([
    Additive.find({}).lean(),
    Ingredient.find({}).lean(),
  ]);

  const ingredients     = [];
  const additives       = [];
  const unresolved_terms = [];

  for (const name of unresolvedNames) {
    const nameLower = name.toLowerCase().trim();
    if (nameLower.length < 2) continue;

    let matched = false;

    // ── PASS 1: Exact additive synonym match ──────────────
    for (const add of allAdditives) {
      const synonymsLower = (add.synonyms || []).map(s => s.toLowerCase());
      if (synonymsLower.includes(nameLower)) {
        additives.push({
          code:        add.code,
          name:        add.name,
          description: add.description ?? null,
          category:    add.category    ?? null,
          ...resolveHealthInfo(add),
        });
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // ── PASS 2: Exact additive name match ─────────────────
    for (const add of allAdditives) {
      if (add.name.toLowerCase() === nameLower) {
        additives.push({
          code:        add.code,
          name:        add.name,
          description: add.description ?? null,
          category:    add.category    ?? null,
          ...resolveHealthInfo(add),
        });
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // ── PASS 3: Exact ingredient canonical_name match ─────
    for (const ing of allIngredients) {
      if (ing.canonical_name.toLowerCase() === nameLower) {
        ingredients.push({
          name:        ing.canonical_name,
          description: ing.description ?? null,
          category:    ing.category    ?? null,
          ...resolveHealthInfo(ing),
        });
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // ── PASS 4: Exact ingredient alias match ──────────────
    for (const ing of allIngredients) {
      const aliasesLower = (ing.aliases || []).map(a => a.toLowerCase());
      if (aliasesLower.includes(nameLower)) {
        ingredients.push({
          name:        ing.canonical_name,
          description: ing.description ?? null,
          category:    ing.category    ?? null,
          ...resolveHealthInfo(ing),
        });
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // ── PASS 5: Partial contains match on ingredient aliases
    // e.g. "Natural Flavouring Substances" contains "flavouring"
    for (const ing of allIngredients) {
      const aliasesLower = (ing.aliases || []).map(a => a.toLowerCase());
      const canonLower   = ing.canonical_name.toLowerCase();
      const nameWords    = nameLower.split(/\s+/);

      // Check if canonical name or any alias is contained within the OCR name
      // OR if the OCR name is contained within canonical/alias
      const containsMatch =
        canonLower.split(/\s+/).every(w => nameLower.includes(w)) ||
        aliasesLower.some(alias =>
          alias.split(/\s+/).every(w => nameLower.includes(w)) ||
          nameWords.every(w => alias.includes(w))
        );

      if (containsMatch && canonLower.length > 3) {
        ingredients.push({
          name:        ing.canonical_name,
          description: ing.description ?? null,
          category:    ing.category    ?? null,
          ...resolveHealthInfo(ing),
        });
        matched = true;
        break;
      }
    }
    if (matched) continue;

    // ── PASS 6: Fuzzy Levenshtein on ingredient canonical_name
    // Only for names ≤ 25 chars (long names have too many false positives)
    if (nameLower.length <= 25) {
      let bestMatch = null;
      let bestDist  = Infinity;

      for (const ing of allIngredients) {
        const dist = levenshtein(nameLower, ing.canonical_name.toLowerCase());
        // Allow distance of 2 for short names, 3 for longer
        const maxDist = nameLower.length <= 10 ? 2 : 3;
        if (dist <= maxDist && dist < bestDist) {
          bestDist  = dist;
          bestMatch = ing;
        }
      }

      if (bestMatch) {
        ingredients.push({
          name:        bestMatch.canonical_name,
          description: bestMatch.description ?? null,
          category:    bestMatch.category    ?? null,
          ...resolveHealthInfo(bestMatch),
        });
        matched = true;
      }
    }
    if (matched) continue;

    // ── PASS 7: Fuzzy Levenshtein on additive synonyms ────
    if (nameLower.length <= 25) {
      let bestMatch = null;
      let bestDist  = Infinity;

      for (const add of allAdditives) {
        for (const syn of (add.synonyms || [])) {
          const dist = levenshtein(nameLower, syn.toLowerCase());
          const maxDist = nameLower.length <= 10 ? 2 : 3;
          if (dist <= maxDist && dist < bestDist) {
            bestDist  = dist;
            bestMatch = add;
          }
        }
      }

      if (bestMatch) {
        additives.push({
          code:        bestMatch.code,
          name:        bestMatch.name,
          description: bestMatch.description ?? null,
          category:    bestMatch.category    ?? null,
          ...resolveHealthInfo(bestMatch),
        });
        matched = true;
      }
    }
    if (matched) continue;

    // ── UNMATCHED ─────────────────────────────────────────
    unresolved_terms.push(name);
  }

  return { ingredients, additives, unresolved_terms };
}

/* =========================================================
   PARTIAL CPHS SCORE
   No NOVA (not available from OCR label scan)
   Formula: S_Nutri (60%) + S_Ing (40%) + additive penalty
   ========================================================= */
function computePartialCPHS({ ingredients, additives, nutriments }) {

  // ── S_Nutri (0-1) from nutriments ─────────────────────
  let S_Nutri = null;

  if (nutriments) {
    const {
      energy_kcal_100g = null,
      sugar_g_100g     = null,
      fat_g_100g       = null,
      sodium_g_100g    = null,
      protein_g_100g   = null,
      fiber_g_100g     = null,
    } = nutriments;

    // Penalty components (higher = worse)
    let penalty = 0;
    let penaltyCount = 0;

    if (energy_kcal_100g !== null) {
      penalty += Math.min(energy_kcal_100g / 400, 1); penaltyCount++;
    }
    if (sugar_g_100g !== null) {
      penalty += Math.min(sugar_g_100g / 20, 1); penaltyCount++;
    }
    if (fat_g_100g !== null) {
      penalty += Math.min(fat_g_100g / 20, 1); penaltyCount++;
    }
    if (sodium_g_100g !== null) {
      penalty += Math.min(sodium_g_100g / 0.6, 1); penaltyCount++;
    }

    // Bonus components (higher = better)
    let bonus = 0;
    let bonusCount = 0;

    if (protein_g_100g !== null) {
      bonus += Math.min(protein_g_100g / 10, 1); bonusCount++;
    }
    if (fiber_g_100g !== null) {
      bonus += Math.min(fiber_g_100g / 5, 1); bonusCount++;
    }

    const penaltyScore = penaltyCount > 0 ? penalty / penaltyCount : 0.5;
    const bonusScore   = bonusCount  > 0 ? bonus  / bonusCount  : 0;

    S_Nutri = Math.max(0, Math.min(1, (1 - penaltyScore) * 0.7 + bonusScore * 0.3));
  }

  // ── S_Ing (0-1) from ingredient health ratings ────────
  let S_Ing = null;

  if (ingredients.length > 0) {
    const ratingsWithValues = ingredients
      .filter(i => i.health_rating !== null && i.health_rating !== undefined);

    if (ratingsWithValues.length > 0) {
      const avg = ratingsWithValues.reduce((sum, i) => sum + i.health_rating, 0)
        / ratingsWithValues.length;
      S_Ing = avg / 100; // normalize to 0-1
    }
  }

  // ── Additive penalty multiplier ───────────────────────
  let M_Add = 1.0;

  if (additives.length > 0) {
    const avgAddRating = additives
      .filter(a => a.health_rating !== null && a.health_rating !== undefined)
      .reduce((sum, a, _, arr) => sum + a.health_rating / arr.length, 0);

    // Additives with low health_rating pull score down
    if (avgAddRating < 40)      M_Add = 0.65;
    else if (avgAddRating < 60) M_Add = 0.80;
    else if (avgAddRating < 80) M_Add = 0.92;
  }

  // ── Final partial CPHS ────────────────────────────────
  // Only compute if we have at least one of S_Nutri or S_Ing
  if (S_Nutri === null && S_Ing === null) return null;

  let cphs;
  if (S_Nutri !== null && S_Ing !== null) {
    cphs = (S_Nutri * 0.60 + S_Ing * 0.40) * M_Add;
  } else if (S_Nutri !== null) {
    cphs = S_Nutri * M_Add;
  } else {
    cphs = S_Ing * M_Add;
  }

  cphs = Math.max(0, Math.min(1, cphs));

  // Convert to health label
  let health_label;
  const score100 = cphs * 100;
  if (score100 >= 85)      health_label = "very_good";
  else if (score100 >= 60) health_label = "good";
  else if (score100 >= 40) health_label = "okay";
  else if (score100 >= 20) health_label = "poor";
  else                     health_label = "very_poor";

  return {
    cphs_score:   parseFloat(cphs.toFixed(3)),
    cphs_100:     Math.round(score100),
    health_label,
    note: "Partial score — NOVA not available from label scan"
  };
}

/* =========================================================
   MAIN PIPELINE
   ========================================================= */
export async function runOCRPipeline(rawText) {
  // ── Step 1: Parse raw text ─────────────────────────────
  const { eCodes, unresolvedNames } = extractIngredientsAndAdditives(rawText);

  // ── Step 2: Resolve E-codes against Additive DB ───────
  const {
    resolved:   additivesFromCodes,
    unresolved: unresolvedCodes
  } = await resolveECodes(eCodes);

  // ── Step 3: Resolve names against DB (both collections)
  const {
    ingredients,
    additives:       additivesFromNames,
    unresolved_terms,
  } = await resolveNames(unresolvedNames);

  // Merge additives from both passes, deduplicate by code
  const allAdditives = [
    ...additivesFromCodes,
    ...additivesFromNames,
  ].filter((a, idx, arr) =>
    arr.findIndex(x => x.code === a.code) === idx
  );

  // Add unresolved codes to unresolved_terms
  const allUnresolved = [
    ...unresolved_terms,
    ...unresolvedCodes.map(c => c.toUpperCase()),
  ];

  // ── Step 4: Extract nutriments ─────────────────────────
  const nutriments = extractNutrimentsFromText(rawText);

  // ── Step 5: Compute partial CPHS ──────────────────────
  const cphs = computePartialCPHS({
    ingredients,
    additives: allAdditives,
    nutriments,
  });

  // ── Step 6: Return ────────────────────────────────────
  return {
    ingredients,
    additives:       allAdditives,
    nutriments:      nutriments   ?? null,
    cphs:            cphs         ?? null,
    unresolved_terms: allUnresolved,
    raw_text:        rawText,      // for debugging
  };
}