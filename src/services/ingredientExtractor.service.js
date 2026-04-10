// /* =========================================================
//    Ingredient & Additive Extractor (OCR)
//    Ported from Flutter (final logic)
//    ========================================================= */

// const MIN_E = 100;
// const MAX_E = 1520;

// const CONTEXT_WORDS = [
//   "preserv",
//   "regulator",
//   "acidity",
//   "stabilizer",
//   "emulsifier",
//   "color",
//   "colour",
//   "additive",
//   "antioxidant",
//   "agent",
//   "class",
//   "treatment",
//   "acid",
//   "ins",
//   "e"
// ];

// const NAME_BASED_ADDITIVES = {
//   "sorbic acid": "e200",
//   "benzoic acid": "e210",
//   "citric acid": "e330",
//   "sodium citrate": "e331",
//   "ascorbic acid": "e300",
//   "riboflavin": "e101",
//   "sucralose": "e955",
//   "acesulfame potassium": "e950",
//   "calcium propionate": "e282",
//   "monoglyceride": "e471",
//   "diglyceride": "e471",
//   "lecithin": "e322"
// };

// /* -------------------- TEXT CLEANER -------------------- */

// function cleanText(text) {
//   if (!text) return "";

//   let cleaned = text.toLowerCase();

//   cleaned = cleaned.replace(/[^a-z0-9,().:;\n -]/g, "");

//   cleaned = cleaned
//     .split("\n")
//     .map(line => line.trim().replace(/\s+/g, " "))
//     .join("\n");

//   cleaned = cleaned.replace(/\s*,\s*/g, ", ");

//   return cleaned.trim();
// }

// /* ---------------- INGREDIENT SECTION ---------------- */

// function extractIngredientsSection(text) {
//   const cleaned = cleanText(text);
//   const lower = cleaned.toLowerCase();

//   const words = lower.split(/[\s,:;.]+/);
//   let startIndex = -1;

//   for (const w of words) {
//     if (similar(w, "ingredient") >= 0.7) {
//       startIndex = lower.indexOf(w);
//       break;
//     }
//   }

//   if (startIndex === -1) return "";

//   let after = cleaned.substring(startIndex);

//   const stopWords = [
//     "nutrition",
//     "allergen",
//     "warning",
//     "expiry",
//     "manufact"
//   ];

//   let end = after.length;
//   for (const stop of stopWords) {
//     const idx = after.toLowerCase().indexOf(stop);
//     if (idx !== -1 && idx < end) end = idx;
//   }

//   let section = after.substring(0, end).trim();
//   section = section.replace(/ingredi\w*/i, "").replace(":", "").trim();

//   return section;
// }

// /* -------------------- SPLITTER -------------------- */

// function splitIngredients(raw) {
//   if (!raw) return [];

//   return raw
//     .replace(/\n/g, ",")
//     .replace(/;/g, ",")
//     .replace(/\s+/g, " ")
//     .toLowerCase()
//     .split(",")
//     .map(e => e.trim())
//     .filter(Boolean);
// }

// /* ---------------- CLASSIFICATION ---------------- */

// function classifyItems(items) {
//   const ingredients = new Set();
//   const additives = new Set();

//   for (const rawItem of items) {
//     const s = rawItem
//   .toLowerCase()
//   .replace(/[()\.]$/g, "") // 🔥 remove trailing ), .
//   .trim();

//   // Ignore junk numeric leftovers
// if (/^\d{1,4}$/.test(s)) continue;

// // Ignore long cosmetic flavor text
// if (s.includes("flavoring substances")) continue;


//     const p = extractParenthesisAdditive(s);
//     if (p) {
//       additives.add(finalizeCode(p));
//       continue;
//     }

//     const ins = extractINSCode(s);
//     if (ins) {
//       additives.add(finalizeCode(ins));
//       continue;
//     }

//     const messy = extractMessyECandidate(s);
//     if (messy) {
//       const normalized = normalizeCandidate(messy);
//       const resolved = resolveHybrid(normalized, s);
//       if (resolved) {
//         additives.add(resolved);
//         continue;
//       }
//     }

//     const numeric = detectBareNumberAdditive(s);
//     if (numeric) {
//       additives.add(numeric);
//       continue;
//     }

//     const name = detectByName(s);
//     if (name) {
//       additives.add(name);
//       continue;
//     }

//     ingredients.add(rawItem);
//   }

//   return {
//     ingredients: Array.from(ingredients),
//     additives: Array.from(additives)
//   };
// }

// /* ---------------- HELPERS ---------------- */

// function extractParenthesisAdditive(s) {
//   const m = s.match(/\(\s*(e?\d{3,4}[a-z]?)\s*\)/i);
//   if (!m) return null;

//   let code = m[1].toLowerCase();
//   const digits = code.replace("e", "");
//   if (digits.length < 3) return null;

//   if (!code.startsWith("e")) code = "e" + code;
//   return code;
// }

// function extractINSCode(s) {
//   const m = s.match(/ins\s*[-:]?\s*(\d{3,4}[a-z]?)/i);
//   return m ? "e" + m[1].toLowerCase() : null;
// }

// function extractMessyECandidate(s) {
//   const m = s.match(/\be[\da-z\-\s]{1,10}\b/i);
//   return m ? m[0] : null;
// }

// function normalizeCandidate(candidate) {
//   let c = candidate.toLowerCase().replace(/[^a-z0-9]/g, "");
//   c = c.replace(/o/g, "0").replace(/l/g, "1");

//   const m = c.match(/(\d{3,4}[a-z]?)/);
//   return m ? "e" + m[1] : "e";
// }

// function resolveHybrid(normalized, original) {
//   const m = normalized.match(/e(\d{3,4})([a-z]?)/);
//   if (!m) return null;

//   const num = parseInt(m[1], 10);
//   const letter = m[2];

//   if (num >= MIN_E && num <= MAX_E) {
//     return letter ? `e${num}${letter}` : `e${num}`;
//   }

//   const fallback = original.match(/(\d{3,4})/);
//   if (fallback) {
//     const n = parseInt(fallback[1], 10);
//     if (n >= MIN_E && n <= MAX_E) return `e${n}`;
//   }

//   return null;
// }

// function detectBareNumberAdditive(s) {
//   const m = s.match(/\b(\d{3,4})\b/);
//   if (!m) return null;

//   const n = parseInt(m[1], 10);
//   if (n >= MIN_E && n <= MAX_E && hasContext(s)) {
//     return `e${n}`;
//   }
//   return null;
// }

// function detectByName(s) {
//   for (const name in NAME_BASED_ADDITIVES) {
//     if (s.includes(name)) return NAME_BASED_ADDITIVES[name];
//   }
//   return null;
// }

// function hasContext(s) {
//   return CONTEXT_WORDS.some(w => s.includes(w));
// }

// function finalizeCode(code) {
//   const m = code.toLowerCase().match(/e(\d{3,4}[a-z]?)/);
//   return m ? `e${m[1]}` : code;
// }

// function similar(a, b) {
//   let score = 0;
//   const len = Math.min(a.length, b.length);
//   for (let i = 0; i < len; i++) {
//     if (a[i] === b[i]) score++;
//   }
//   return score / b.length;
// }

// /* ---------------- PUBLIC API ---------------- */

// export function extractIngredientsAndAdditives(rawText) {
//   const section = extractIngredientsSection(rawText);
//   const items = splitIngredients(section || rawText);
//   return classifyItems(items);
// }




/* =========================================================
   ingredientExtractor.service.js — v3.0
   Pure parsing only. No DB calls. No hardcoded additive names.
   Returns { eCodes[], unresolvedNames[] }
   eCodes   → deterministically extracted E/INS/bare numbers
   unresolvedNames → everything else, goes to DB fuzzy matching
   ========================================================= */

const MIN_E = 100;
const MAX_E = 1520;

/* =========================================================
   NOISE LINE PATTERNS
   Full lines/tokens that are definitely not ingredients
   ========================================================= */
const NOISE_PATTERNS = [
  /^may contain/i,
  /^contains no /i,
  /^allergen/i,
  /^allergy/i,
  /manufactured\s*(by|in)/i,
  /packed\s*(by|in)/i,
  /best before/i,
  /use before/i,
  /expiry/i,
  /net\s*wt/i,
  /net\s*weight/i,
  /serving size/i,
  /per\s*100\s*(ml|g)/i,
  /per\s*serve/i,
  /%\s*rda/i,
  /based on.*kcal/i,
  /approx.*val/i,
  /nutrition(al)?\s*(info|fact|value)/i,
  /^\s*energy\s*[\d]/i,
  /^\s*carbohydrate/i,
  /^\s*total fat/i,
  /^\s*protein\s*[\d]/i,
  /^\s*sodium\s*[\d]/i,
  /^\s*dietary\s*fib/i,
  /product of/i,
  /imported by/i,
  /distributed by/i,
  /marketed by/i,
  /fssai/i,
  /lic(ence|ense|\.)\s*no/i,
  /batch\s*no/i,
  /mfg\s*date/i,
  /^\s*vegetarian\s*$/i,
  /^\s*vegan\s*$/i,
  /^\s*halal\s*$/i,
  /^\s*kosher\s*$/i,
  /contains no fruit/i,
  /sweetened carbonated/i,
  /^\s*\d+(\.\d+)?\s*(ml|g|kg|l)\s*$/i,  // standalone quantity
  /^\s*\d+(\.\d+)?%\s*$/i,                // standalone percentage
  /contient\s*:/i,                         // French bilingual trigger
  /ingr[eé]dients\s*:/i,                  // French bilingual trigger
  /^\s*[a-z]{1,2}\s*$/i,                  // single/double char noise
];

/* =========================================================
   SECTION STOP PHRASES
   Everything after these is discarded
   ========================================================= */
const STOP_PHRASES = [
  "allergen",
  "allergy advice",
  "may contain",
  "contains no",
  "nutrition information",
  "nutritional information",
  "nutrition facts",
  "nutritional value",
  "nutrition value",
  "manufactured by",
  "manufactured in",
  "packed by",
  "best before",
  "expiry date",
  "net weight",
  "net wt",
  "fssai",
  "customer care",
  "for more information",
  "contient :",       // French
  "ingrédients :",    // French
  "zutaten",          // German
  "ingredienti",      // Italian
];

/* =========================================================
   INGREDIENTS SECTION HEADER PATTERNS
   ========================================================= */
const HEADER_PATTERNS = [
  /ingredi[ea]nts?\s*:/i,
  /ingr[ei]di[ea]nts?\s*:/i,
  /lngredients?\s*:/i,         // OCR: capital I → l
  /lngr[ei]di[ea]nts?\s*:/i,
  /composition\s*:/i,
  /made\s+with\s*:/i,
  /ingredi[ea]nts?\s*\n/i,
  /ingredi[ea]nts\s+include/i,
];

/* =========================================================
   STEP 1 — OCR TEXT CLEANUP
   ========================================================= */
function cleanOCRText(raw) {
  if (!raw) return "";

  let text = raw;

  // Normalize line endings
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");

  // Common OCR character confusions in E-codes
  // "l330" or "I330" at word boundary → likely "e330"
  text = text.replace(/\b[lI](\d{3,4}[a-z]?)\b/g, (_, n) => {
    const num = parseInt(n, 10);
    if (num >= MIN_E && num <= MAX_E) return `e${n}`;
    return _;
  });

  // "lns" or "LNS" → "ins"
  text = text.replace(/\b[lL][nN][sS]\b/g, "ins");

  // Normalize per-line whitespace but keep newlines
  text = text
    .split("\n")
    .map(line => line.trim().replace(/\s+/g, " "))
    .filter(Boolean)
    .join("\n");

  return text.trim();
}

/* =========================================================
   STEP 2 — ISOLATE INGREDIENTS SECTION
   ========================================================= */
function isolateSection(text) {
  const lower = text.toLowerCase();

  // Find header
  let headerEnd = -1;
  for (const pattern of HEADER_PATTERNS) {
    const match = text.match(pattern);
    if (match && match.index !== undefined) {
      headerEnd = match.index + match[0].length;
      break;
    }
  }

  // No header found — check if text looks like a raw ingredients list
  if (headerEnd === -1) {
    const commas  = (text.match(/,/g)  || []).length;
    const bullets = (text.match(/•/g)  || []).length;
    if (commas > 2 || bullets > 2) {
      headerEnd = 0; // use full text
    } else {
      return "";
    }
  }

  let section = text.substring(headerEnd);

  // Cut at stop phrases
  const sectionLower = section.toLowerCase();
  let cutAt = section.length;

  for (const stop of STOP_PHRASES) {
    const idx = sectionLower.indexOf(stop);
    if (idx > 0 && idx < cutAt) {
      cutAt = idx;
    }
  }

  section = section.substring(0, cutAt).trim();

  // Remove trailing period/dot
  section = section.replace(/\.\s*$/, "").trim();

  return section;
}

/* =========================================================
   STEP 3 — SMART SPLIT (respects bracket depth)
   ========================================================= */
function smartSplit(text) {
  const tokens = [];
  let depth = 0;
  let current = "";

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (ch === "(" || ch === "[") {
      depth++;
      current += ch;
    } else if (ch === ")" || ch === "]") {
      depth = Math.max(0, depth - 1);
      current += ch;
    } else if (ch === "," && depth === 0) {
      const t = current.trim();
      if (t) tokens.push(t);
      current = "";
    } else {
      current += ch;
    }
  }

  const t = current.trim();
  if (t) tokens.push(t);
  return tokens;
}

function splitIntoTokens(section) {
  if (!section) return [];

  let text = section;

  // Normalize separators
  // Bullets → comma
  text = text.replace(/•/g, ",");
  // Semicolons → comma
  text = text.replace(/;/g, ",");
  // Newlines → comma (join lines)
  text = text
    .split("\n")
    .map(l => l.trim())
    .filter(Boolean)
    .join(", ");

  // Clean up multiple commas
  text = text.replace(/,\s*,+/g, ",");

  return smartSplit(text)
    .map(t => t.trim())
    .filter(Boolean);
}

/* =========================================================
   STEP 4 — EXTRACT CODES FROM BRACKET CONTENT
   e.g. "(330, 331(iii))" → ["e330", "e331"]
   e.g. "(414, 445)"      → ["e414", "e445"]
   e.g. "(NATURAL FLAVOURING SUBSTANCES)" → [] (descriptive)
   ========================================================= */
function extractCodesFromBracket(content) {
  const codes = [];
  // Split on comma or & inside bracket
  const parts = content.split(/[,&]/);

  for (const part of parts) {
    const p = part.trim().toLowerCase();
    if (!p) continue;

    // INS pattern: "ins 330", "ins330"
    const insMatch = p.match(/ins\s*[-:]?\s*(\d{3,4})/i);
    if (insMatch) {
      const n = parseInt(insMatch[1], 10);
      if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
    }

    // E-code with optional letter/Roman suffix: "e330", "E331iii", "e331(iii)"
    // Strip Roman numerals and letters after digits
    const eCodeMatch = p.match(/^e(\d{3,4})/i);
    if (eCodeMatch) {
      const n = parseInt(eCodeMatch[1], 10);
      if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
    }

    // Bare number (3-4 digits), possibly followed by Roman/letter qualifier
    // "330", "331iii", "331(iii)"
    const bareMatch = p.match(/^(\d{3,4})/);
    if (bareMatch) {
      const n = parseInt(bareMatch[1], 10);
      if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
    }
  }

  return codes;
}

function isDescriptiveBracket(content) {
  // If bracket content has mostly letters and no valid code patterns
  // e.g. "NATURAL & NATURE-IDENTICAL FLAVOURING SUBSTANCES"
  const hasCode = /\d{3,4}/.test(content);
  const wordCount = content.trim().split(/\s+/).length;
  return !hasCode && wordCount >= 2;
}

/* =========================================================
   STEP 5 — STRIP PERCENTAGE PREFIX
   "AND LESS THAN 2% SUGAR" → "SUGAR"
   "2% OR LESS OF: SALT"    → "SALT"
   ========================================================= */
function stripPercentagePrefix(s) {
  return s
    .replace(/^(and\s+)?(less\s+than|more\s+than|at\s+least)?\s*\d+(\.\d+)?\s*%\s*(or\s+less\s+)?(of\s*:?\s*)?/i, "")
    .replace(/^\d+(\.\d+)?\s*%\s*(or\s+less\s+(of\s*)?:?\s*)?/i, "")
    .trim();
}

/* =========================================================
   STEP 6 — CLASSIFY TOKENS
   Returns { eCodes[], unresolvedNames[] }
   ========================================================= */
function classifyTokens(tokens) {
  const eCodes          = new Set();
  const unresolvedNames = new Set();

  for (let rawToken of tokens) {
    rawToken = rawToken.trim();
    if (!rawToken) continue;

    // ── NOISE FILTER ─────────────────────────────────────
    if (NOISE_PATTERNS.some(p => p.test(rawToken))) continue;

    // Strip percentage prefix
    const dePercent = stripPercentagePrefix(rawToken);
    const working   = dePercent || rawToken;

    // Discard if still pure number or too short
    if (/^\d+(\.\d+)?%?$/.test(working)) continue;
    if (working.length < 2) continue;

    // ── EXTRACT BRACKET CONTENTS ──────────────────────────
    const bracketContents = [];
    const bracketRegex = /\(([^()]*)\)/g;
    let bMatch;
    while ((bMatch = bracketRegex.exec(working)) !== null) {
      bracketContents.push(bMatch[1]);
    }

    // Base token with brackets removed
    const base = working.replace(/\([^()]*\)/g, "").trim();

    let foundCodes = false;

    for (const content of bracketContents) {
      const codes = extractCodesFromBracket(content);
      if (codes.length > 0) {
        codes.forEach(c => eCodes.add(c));
        foundCodes = true;
      } else if (isDescriptiveBracket(content)) {
        // Descriptive bracket → add content as unresolved name
        // e.g. "NATURAL & NATURE-IDENTICAL FLAVOURING SUBSTANCES"
        // Split on & and add each part
        content.split(/[&]/).forEach(part => {
          const p = toTitleCase(part.trim());
          if (p.length > 2) unresolvedNames.add(p);
        });
      }
    }

    // ── BASE TOKEN CLASSIFICATION ─────────────────────────

    // Check if base is just a category label (codes were in brackets)
    // e.g. "ACIDITY REGULATOR", "STABILIZERS", "PRESERVATIVE"
    // Still add as unresolved — DB may have it as an ingredient
    const baseNorm = toTitleCase(base);

    if (base.length < 2) continue;
    if (NOISE_PATTERNS.some(p => p.test(base))) continue;

    // Direct E-code in base: "E330", "e150a"
    const directE = base.match(/^e(\d{3,4}[a-z]?)$/i);
    if (directE) {
      const n = parseInt(directE[1], 10);
      if (n >= MIN_E && n <= MAX_E) {
        eCodes.add(`e${directE[1].toLowerCase()}`);
        continue;
      }
    }

    // INS code in base: "INS 330", "ins330"
    const insInBase = base.match(/ins\s*[-:]?\s*(\d{3,4})/i);
    if (insInBase) {
      const n = parseInt(insInBase[1], 10);
      if (n >= MIN_E && n <= MAX_E) {
        eCodes.add(`e${n}`);
        continue;
      }
    }

    // Bare 3-4 digit number as entire token
    const bareNum = base.match(/^(\d{3,4})$/);
    if (bareNum) {
      const n = parseInt(bareNum[1], 10);
      if (n >= MIN_E && n <= MAX_E) {
        eCodes.add(`e${n}`);
        continue;
      }
    }

    // Everything else → unresolved name for DB matching
    if (baseNorm.length > 2) {
      unresolvedNames.add(baseNorm);
    }
  }

  return {
    eCodes:          Array.from(eCodes),
    unresolvedNames: Array.from(unresolvedNames),
  };
}

/* =========================================================
   UTILITY
   ========================================================= */
function toTitleCase(str) {
  return str
    .toLowerCase()
    .replace(/\b\w/g, c => c.toUpperCase())
    .trim();
}

/* =========================================================
   NUTRIENTS EXTRACTOR
   Parses nutrition table from raw OCR text
   Exported separately — called directly in ocrPipeline
   ========================================================= */
export function extractNutrimentsFromText(rawText) {
  if (!rawText) return null;
  const text = rawText.toLowerCase();
  const nutriments = {};

  const grab = (pattern) => {
    const m = text.match(pattern);
    return m ? parseFloat(m[1]) : null;
  };

  // Energy
  const energyKcal = grab(/energy[\s\S]{0,40}?(\d+\.?\d*)\s*kcal/i);
  const energyKj   = grab(/energy[\s\S]{0,40}?(\d+\.?\d*)\s*kj/i);
  if (energyKcal != null)      nutriments.energy_kcal_100g = energyKcal;
  else if (energyKj != null)   nutriments.energy_kcal_100g = Math.round(energyKj / 4.184);

  // Carbohydrates
  const carb = grab(/carbohydrate[s]?[\s\S]{0,30}?(\d+\.?\d*)\s*g/i);
  if (carb != null) nutriments.carbohydrates_g_100g = carb;

  // Sugars
  const sugar = grab(/(?:total\s+)?sugars?[\s\S]{0,30}?(\d+\.?\d*)\s*g/i);
  if (sugar != null) nutriments.sugar_g_100g = sugar;

  // Fat
  const fat = grab(/(?:total\s+)?fat[\s\S]{0,30}?(\d+\.?\d*)\s*g/i);
  if (fat != null) nutriments.fat_g_100g = fat;

  // Saturated fat
  const satFat = grab(/saturated[\s\S]{0,20}?fat[\s\S]{0,20}?(\d+\.?\d*)\s*g/i);
  if (satFat != null) nutriments.saturated_fat_g_100g = satFat;

  // Protein
  const protein = grab(/protein[s]?[\s\S]{0,30}?(\d+\.?\d*)\s*g/i);
  if (protein != null) nutriments.protein_g_100g = protein;

  // Fiber
  const fiber = grab(/(?:dietary\s+)?fib(?:er|re)[s]?[\s\S]{0,30}?(\d+\.?\d*)\s*g/i);
  if (fiber != null) nutriments.fiber_g_100g = fiber;

  // Sodium (convert mg → g)
  const sodiumMg = grab(/sodium[\s\S]{0,30}?(\d+\.?\d*)\s*mg/i);
  const sodiumG  = grab(/sodium[\s\S]{0,30}?(\d+\.?\d*)\s*g(?!\/)/i);
  if (sodiumMg != null)     nutriments.sodium_g_100g = parseFloat((sodiumMg / 1000).toFixed(4));
  else if (sodiumG != null) nutriments.sodium_g_100g = sodiumG;

  // Salt (convert mg → g)
  const saltMg = grab(/salt[\s\S]{0,30}?(\d+\.?\d*)\s*mg/i);
  const saltG  = grab(/salt[\s\S]{0,30}?(\d+\.?\d*)\s*g(?!\/)/i);
  if (saltMg != null)     nutriments.salt_g_100g = parseFloat((saltMg / 1000).toFixed(4));
  else if (saltG != null) nutriments.salt_g_100g = saltG;

  return Object.keys(nutriments).length > 0 ? nutriments : null;
}

/* =========================================================
   PUBLIC API
   ========================================================= */
export function extractIngredientsAndAdditives(rawText) {
  const cleaned  = cleanOCRText(rawText);
  const section  = isolateSection(cleaned);
  const tokens   = splitIntoTokens(section || cleaned);
  const result   = classifyTokens(tokens);
  return result;
}