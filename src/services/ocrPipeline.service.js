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

//   const resolvedIngredients = ingredientDocs.map((doc, idx) => {
//   if (doc) {
//     return {
//       name: doc.canonical_name,
//       description: doc.description || null,
//       source_tag: doc.source_tag || null
//     };
//   }

//   // 🔥 FALLBACK: preserve raw ingredient text
//   return {
//     name: ingredients[idx],
//     description: null,
//     source_tag: "⚪"
//   };
// });


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
//     .filter(Boolean)
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


import Ingredient from "../models/ingredient.model.js";
import Additive from "../models/additive.model.js";
import { extractIngredientsAndAdditives } from "./ingredientExtractor.service.js";
import { computeNOVA } from "./nova.service.js";

/* ✅ REQUIRED: regex safety */
function escapeRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export async function runOCRPipeline(rawText) {
  // 1️⃣ Extract text → tokens
  const { ingredients, additives } =
    extractIngredientsAndAdditives(rawText);

  // 2️⃣ Resolve INGREDIENTS (SAFE)
  const ingredientDocs = await Promise.all(
    ingredients.map(name => {
      const safe = escapeRegex(name);
      return Ingredient.findOne({
        $or: [
          { canonical_name: new RegExp(`^${safe}$`, "i") },
          { aliases: new RegExp(`^${safe}$`, "i") }
        ]
      }).lean();
    })
  );

  // ✅ ONLY RETURN DB-MATCHED INGREDIENTS
  const resolvedIngredients = ingredientDocs
    .filter(doc => doc && doc.canonical_name)
    .map(doc => ({
      name: doc.canonical_name,
      description: doc.description || null,
      source_tag: doc.source_tag || null
    }));

  // 3️⃣ Resolve ADDITIVES (SAFE)
  const additiveDocs = await Promise.all(
    additives.map(code => {
      const safe = escapeRegex(code);
      return Additive.findOne({
        $or: [
          { code: new RegExp(`^${safe}$`, "i") },
          { synonyms: new RegExp(`^${safe}$`, "i") }
        ]
      }).lean();
    })
  );

  const resolvedAdditives = additiveDocs
    .filter(a => a && a.code)
    .map(a => ({
      code: a.code.toUpperCase(),
      name: a.name,
      description: a.description || null,
      source_tag: a.source_tag || null
    }));

  // 4️⃣ NOVA (unchanged)
  const nova = computeNOVA({
    ingredients,
    additives
  });

  return {
    ingredients: resolvedIngredients,
    additives: resolvedAdditives,
    nova
  };
}
