// import Ingredient from "../models/ingredient.model.js";
// import Additive from "../models/additive.model.js";
// import { extractIngredientsAndAdditives } from "./ingredientExtractor.service.js";
// import { computeNOVA } from "./nova.service.js";

// export async function runOCRPipeline(rawText) {
//   // 1️⃣ Extract
//   const { ingredients, additives } =
//     extractIngredientsAndAdditives(rawText);

//   // 2️⃣ Resolve ingredients from DB
//   const ingredientDocs = await Promise.all(
//     ingredients.map(name =>
//       Ingredient.findOne({
//         $or: [
//           { canonical_name: new RegExp(`^${name}$`, "i") },
//           { aliases: new RegExp(`^${name}$`, "i") }
//         ]
//       }).lean()
//     )
//   );

//   // 3️⃣ Resolve additives from DB
//   const additiveDocs = await Promise.all(
//     additives.map(code =>
//       Additive.findOne({ code: code.toLowerCase() }).lean()
//     )
//   );

//   const resolvedIngredients = ingredientDocs
//     .filter(Boolean)
//     .map(i => ({
//       name: i.canonical_name,
//       description: i.description || null,
//       health_rating: i.health_rating || null
//     }));

//   const resolvedAdditives = additiveDocs
//     .filter(Boolean)
//     .map(a => ({
//       code: a.code.toUpperCase(),
//       name: a.name,
//       description: a.description || null,
//       health_rating: a.health_rating || null
//     }));

//   // 4️⃣ NOVA
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

export async function runOCRPipeline(rawText) {
  // 1️⃣ Extract text → tokens
  const { ingredients, additives } =
    extractIngredientsAndAdditives(rawText);

  // 2️⃣ Resolve INGREDIENTS
  const ingredientDocs = await Promise.all(
    ingredients.map(name =>
      Ingredient.findOne({
        $or: [
          { canonical_name: new RegExp(`^${name}$`, "i") },
          { aliases: new RegExp(`^${name}$`, "i") }
        ]
      }).lean()
    )
  );

  const resolvedIngredients = ingredientDocs
    .filter(Boolean)
    .map(i => ({
      name: i.canonical_name,
      description: i.description || null,
      source_tag: i.source_tag || null
    }));

  // 3️⃣ Resolve ADDITIVES (case-safe + synonym-safe)
  const additiveDocs = await Promise.all(
    additives.map(code =>
      Additive.findOne({
        $or: [
          { code: new RegExp(`^${code}$`, "i") },
          { synonyms: new RegExp(`^${code}$`, "i") }
        ]
      }).lean()
    )
  );

  const resolvedAdditives = additiveDocs
    .filter(Boolean)
    .map(a => ({
      code: a.code.toUpperCase(),
      name: a.name,
      description: a.description || null,
      source_tag: a.source_tag || null
    }));

  // 4️⃣ NOVA (still based on raw strings)
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
