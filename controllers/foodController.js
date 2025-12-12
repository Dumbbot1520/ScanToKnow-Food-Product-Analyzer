// // controllers/foodController.js
// import Food from "../models/Food.js";
// import IngredientsInfo from "../models/IngredientsInfo.js";
// import AdditiveInfo from "../models/AdditiveInfo.js";

// /* Helper to pick nutriment values from several possible keys used in dumps. */
// function pickNutriment(n, candidates = []) {
//   for (const key of candidates) {
//     if (Object.prototype.hasOwnProperty.call(n, key)) {
//       const v = n[key];
//       return (typeof v === "undefined") ? null : v;
//     }
//   }
//   return null;
// }

// /* GET /api/food
//    Simple list endpoint (paginated optional).
//    Supports:
//      - ?category=<slug>  -> exact match against primary_category (case-insensitive)
//      - ?q=<query>        -> basic search over product_name and brands (regex, case-insensitive)
//      - ?page & ?limit    -> pagination (limit capped at 100)
// */
// export const getFoods = async (req, res) => {
//   try {
//     const limit = Math.min(100, Math.max(1, parseInt(req.query.limit || "50", 10)));
//     const page = Math.max(0, parseInt(req.query.page || "0", 10));

//     // category filter: canonical primary_category (we expect it to be stored in lowercase)
//     const categoryRaw = (req.query.category || "").toString().trim();
//     const category = categoryRaw ? categoryRaw.toLowerCase() : "";

//     // optional q search (basic)
//     const qRaw = (req.query.q || "").toString().trim();
//     const q = qRaw;

//     const filter = {};

//     if (category) {
//       // match primary_category exactly (assumes documents store primary_category in lowercase)
//       filter.primary_category = category;
//     }

//     if (q) {
//       // escape regex chars in q
//       const escaped = q.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
//       const r = new RegExp(escaped, "i");
//       filter.$or = [{ product_name: r }, { brands: r }];
//     }

//     const docs = await Food.find(filter)
//       .skip(page * limit)
//       .limit(limit)
//       .lean();

//     return res.json({ ok: true, data: docs });
//   } catch (err) {
//     console.error("getFoods error:", err);
//     return res.status(500).json({ ok: false, error: err.message });
//   }
// };

// /* GET /api/food/barcode/:barcode
//    Returns product (as-is except nutriments filtered) + ingredients + additives
// */
// export const getFoodByBarcode = async (req, res) => {
//   try {
//     const { barcode } = req.params;
//     if (!barcode) return res.status(400).json({ ok: false, error: "barcode required" });

//     // allow string/number candidates
//     const candidates = [barcode];
//     const asNum = Number(barcode);
//     if (!Number.isNaN(asNum)) candidates.push(asNum);

//     const product = await Food.findOne({ barcode: { $in: candidates } }).lean();
//     if (!product) return res.status(404).json({ ok: false, error: "product not found" });

//     // build nutriments filtered object
//     const raw = product.nutriments || {};
//     const nutrimentsFiltered = {
//       energy_kcal: pickNutriment(raw, ["energy-kcal", "energy-kcal_value", "energy-kcal_100g", "energy_kcal", "energy-kcal_value"]),
//       carbohydrates_g: pickNutriment(raw, ["carbohydrates", "carbohydrates_100g", "carbohydrates_value", "carbohydrates_g"]),
//       sugars_g: pickNutriment(raw, ["sugars", "sugars_100g", "sugars_value", "sugars_g"]),
//       fat_g: pickNutriment(raw, ["fat", "fat_100g", "fat_value", "fat_g"]),
//       saturated_fat_g: pickNutriment(raw, ["saturated-fat", "saturated-fat_100g", "saturated-fat_value", "saturated_fat_g"]),
//       proteins_g: pickNutriment(raw, ["proteins", "proteins_100g", "proteins_value", "proteins_g"]),
//       salt_g: pickNutriment(raw, ["salt", "salt_100g", "salt_value", "salt_g"])
//     };

//     // keep API tidy: convert explicit zeroes to null for some keys
//     ['fat_g', 'saturated_fat_g', 'salt_g'].forEach(k => {
//       if (nutrimentsFiltered[k] === 0) nutrimentsFiltered[k] = null;
//     });

//     // ingredients doc where barcodes array contains barcode
//     const ingDoc = await IngredientsInfo.findOne({ barcodes: { $in: candidates } }).lean();
//     const ingredients = (ingDoc && Array.isArray(ingDoc.ingredients)) ? ingDoc.ingredients : [];

//     // additives lookup (preserve DB fields exactly)
//     const additiveCodes = Array.isArray(product.additives) ? product.additives.map(c => String(c).trim().toLowerCase()).filter(Boolean) : [];
//     let additives = [];
//     if (additiveCodes.length) {
//       const docs = await AdditiveInfo.find({ code: { $in: additiveCodes } }).lean();
//       const map = new Map(docs.map(d => [String(d.code).toLowerCase(), d]));
//       additives = additiveCodes.map(c => map.get(c)).filter(Boolean);
//     }

//     const productOut = { ...product, nutriments: nutrimentsFiltered };
//     return res.json({ ok: true, product: productOut, ingredients, additives });
//   } catch (err) {
//     console.error("getFoodByBarcode error:", err);
//     return res.status(500).json({ ok: false, error: err.message });
//   }
// };

// /* GET /api/food/:id/alternatives
//    Return simple "healthier" alternatives within same category.
//    This is a lightweight placeholder: it finds other products sharing any category,
//    orders by nutriscore (A best -> E worst) if present, then returns top N.
// */
// export const getAlternatives = async (req, res) => {
//   try {
//     const { id } = req.params;
//     const limit = Math.min(20, Math.max(1, parseInt(req.query.limit || "5", 10)));

//     // find original product by _id or barcode
//     let original = null;
//     // try as ObjectId fallback or barcode
//     original = await Food.findOne({ _id: id }).lean().catch(() => null);
//     if (!original) {
//       original = await Food.findOne({ barcode: id }).lean();
//     }
//     if (!original) return res.status(404).json({ ok: false, error: "product not found" });

//     const cats = Array.isArray(original.categories) ? original.categories : [];
//     if (!cats.length) return res.json({ ok: true, data: [] });

//     // find other products sharing categories, exclude original
//     const candidates = await Food.find({
//       _id: { $ne: original._id },
//       categories: { $in: cats }
//     }).lean();

//     // Score by nutriscore if present (A best -> E worst). We'll convert A..E to 1..5 (A=1).
//     const scoreFromNutri = (n) => {
//       if (!n) return 999;
//       const s = String(n).toUpperCase();
//       const map = { A: 1, B: 2, C: 3, D: 4, E: 5 };
//       return map[s] ?? 999;
//     };

//     const sorted = candidates
//       .map(p => ({ p, score: scoreFromNutri(p.nutriscore) }))
//       .sort((a, b) => a.score - b.score)
//       .slice(0, limit)
//       .map(x => x.p);

//     return res.json({ ok: true, data: sorted });
//   } catch (err) {
//     console.error("getAlternatives error:", err);
//     return res.status(500).json({ ok: false, error: err.message });
//   }
// };


// controllers/foodController.js
import Food from "../models/Food.js";
import IngredientsInfo from "../models/IngredientsInfo.js";
import AdditiveInfo from "../models/AdditiveInfo.js";

/* Helper to pick nutriment values from several possible keys used in dumps. */
function pickNutriment(n, candidates = []) {
  for (const key of candidates) {
    if (Object.prototype.hasOwnProperty.call(n, key)) {
      const v = n[key];
      return (typeof v === "undefined") ? null : v;
    }
  }
  return null;
}

/* Convert NutriScore letter to numeric rank (A=1 ... E=5). Missing -> large number */
const nutriScoreRank = (s) => {
  if (!s) return 999;
  const map = { A: 1, B: 2, C: 3, D: 4, E: 5 };
  return map[String(s).toUpperCase()] ?? 999;
};

/* GET /api/food
   List products with filters suitable for frontend grid (thumbnails).
   Supported query params:
     - primary_category or category (exact, lowercase expected)
     - q (text search over product_name and brands; basic regex)
     - brands (exact match; can be comma-separated)
     - nutriscore (exact A..E)
     - nova_group (number)
     - min_sugars, max_sugars (numbers, in g per 100g or per 100ml depending on data)
     - page, limit (pagination)
     - sort: relevance (default), sugars_asc, energy_desc, nutriscore_asc, newest
*/
export const getFoods = async (req, res) => {
  try {
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit || "24", 10)));
    const page = Math.max(0, parseInt(req.query.page || "0", 10));

    // canonical category param
    const categoryRaw = (req.query.primary_category || req.query.category || "").toString().trim();
    const category = categoryRaw ? categoryRaw.toLowerCase() : "";

    // basic q search
    const qRaw = (req.query.q || "").toString().trim();
    const q = qRaw;

    // filters
    const brandsRaw = (req.query.brands || "").toString().trim();
    const brands = brandsRaw ? brandsRaw.split(",").map(s => s.trim()).filter(Boolean) : [];

    const nutriscore = (req.query.nutriscore || "").toString().trim(); // A..E
    const novaGroupRaw = req.query.nova_group ?? req.query.nova ? req.query.nova : null;
    const nova_group = (novaGroupRaw !== null && String(novaGroupRaw).trim() !== "") ? Number(novaGroupRaw) : null;

    const min_sugars = req.query.min_sugars ? Number(req.query.min_sugars) : null;
    const max_sugars = req.query.max_sugars ? Number(req.query.max_sugars) : null;

    // sort
    const sortParam = (req.query.sort || "relevance").toString();

    // Build Mongo filter
    const filter = {};

    if (category) filter.primary_category = category;

    if (brands.length) filter.brands = { $in: brands };

    if (nutriscore) filter.nutriscore = String(nutriscore).toUpperCase();

    if (!Number.isNaN(nova_group) && Number.isFinite(nova_group)) filter.nova_group = nova_group;

    if (q) {
      // escape regex chars
      const escaped = q.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      const r = new RegExp(escaped, "i");
      filter.$or = [{ product_name: r }, { brands: r }];
    }

    // Numeric range filters on sugars (note: data may be per 100g/100ml; assume user understands)
    if (min_sugars !== null || max_sugars !== null) {
      // We attempt to check common field names inside nutriments with $expr + $or fallback.
      // Simpler path: use aggregation to compute field value from possible keys.
      // For performance and simplicity, perform a projection after query to filter client-side if nessesary.
      // But we'll add a Mongo-level filter for likely key 'nutriments.sugars_100g' and 'nutriments.sugars' variants:
      const sugarFilters = [];
      if (min_sugars !== null) {
        sugarFilters.push({ "nutriments.sugars_100g": { $gte: min_sugars } });
        sugarFilters.push({ "nutriments.sugars": { $gte: min_sugars } });
      }
      if (max_sugars !== null) {
        sugarFilters.push({ "nutriments.sugars_100g": { $lte: max_sugars } });
        sugarFilters.push({ "nutriments.sugars": { $lte: max_sugars } });
      }
      if (sugarFilters.length) {
        filter.$or = filter.$or ? filter.$or.concat(sugarFilters) : sugarFilters;
      }
    }

    // projection: only what frontend typically needs for listing
    const projection = {
      barcode: 1,
      product_name: 1,
      brands: 1,
      quantity: 1,
      "images.front": 1,
      nutriscore: 1,
      nova_group: 1,
      nutriments: 1
    };

    // simple sorting strategy mapping
    let sort = { _id: 1 }; // default stable order
    if (sortParam === "sugars_asc") {
      // best-effort sort: sort by nutriments.sugars_100g then nutriments.sugars
      sort = { "nutriments.sugars_100g": 1, "nutriments.sugars": 1 };
    } else if (sortParam === "energy_desc") {
      sort = { "nutriments.energy-kcal_100g": -1, "nutriments.energy-kcal": -1, "nutriments.energy_kcal": -1 };
    } else if (sortParam === "nutriscore_asc") {
      // Use a small JS post-sort because letters don't sort as desired; however we'll fetch and then sort in-memory
      sort = {}; // no DB sort
    } else if (sortParam === "newest") {
      sort = { last_updated: -1 };
    } else {
      // relevance or default rely on natural order
      sort = {};
    }

    let docs = await Food.find(filter, projection)
      .skip(page * limit)
      .limit(limit)
      .lean();

    // If nutriscore_asc requested, perform stable JS sort by mapping A->1..E->5
    if (sortParam === "nutriscore_asc") {
      docs.sort((a, b) => nutriScoreRank(a.nutriscore) - nutriScoreRank(b.nutriscore));
    }

    // Post-process items: ensure images.front exists and provide a 'thumbnail' field for convenience
    const data = docs.map(d => {
      const thumbnail = (d.images && d.images.front) ? d.images.front : null;
      // make a compact nutriment summary for list (best-effort)
      const raw = d.nutriments || {};
      const energy = pickNutriment(raw, ["energy-kcal", "energy-kcal_100g", "energy-kcal_value", "energy_100g", "energy"]);
      const sugars = pickNutriment(raw, ["sugars", "sugars_100g", "sugars_value"]);
      return {
        barcode: d.barcode ? String(d.barcode) : null,
        product_name: d.product_name,
        brands: d.brands,
        quantity: d.quantity,
        thumbnail,           // use images.front as thumbnail
        nutriscore: d.nutriscore,
        nova_group: d.nova_group,
        nutriment_summary: {
          energy_kcal: energy ?? null,
          sugars_g: sugars ?? null
        }
      };
    });

    // provide meta: we can return total count separately (cheap approach: estimate)
    const total = await Food.countDocuments(filter);

    return res.json({ ok: true, data, meta: { page, limit, total } });
  } catch (err) {
    console.error("getFoods error:", err);
    return res.status(500).json({ ok: false, error: err.message });
  }
};

/* GET /api/food/facets
   Return aggregated facet counts to populate filter UI for a given category.
   Query params:
     - primary_category (or category)
     - optional limit for top brands
*/
export const getFacets = async (req, res) => {
  try {
    const categoryRaw = (req.query.primary_category || req.query.category || "").toString().trim();
    const category = categoryRaw ? categoryRaw.toLowerCase() : "";

    const match = {};
    if (category) match.primary_category = category;

    const brandLimit = Math.min(50, Math.max(5, parseInt(req.query.brand_limit || "20", 10)));

    // Aggregation pipeline to compute counts for nutriscore, nova_group, brands
    const pipeline = [
      { $match: match },
      {
        $facet: {
          nutriscore: [
            { $match: { nutriscore: { $exists: true, $ne: null } } },
            { $group: { _id: "$nutriscore", count: { $sum: 1 } } },
            { $sort: { _id: 1 } }
          ],
          nova_group: [
            { $match: { nova_group: { $exists: true, $ne: null } } },
            { $group: { _id: "$nova_group", count: { $sum: 1 } } },
            { $sort: { _id: 1 } }
          ],
          brands: [
            { $match: { brands: { $exists: true, $ne: null } } },
            { $group: { _id: "$brands", count: { $sum: 1 } } },
            { $sort: { count: -1 } },
            { $limit: brandLimit }
          ],
          counts: [
            { $count: "total" }
          ]
        }
      }
    ];

    const agg = await Food.aggregate(pipeline).allowDiskUse(true);
    const resObj = agg[0] || { nutriscore: [], nova_group: [], brands: [], counts: [] };

    return res.json({
      ok: true,
      facets: {
        nutriscore: resObj.nutriscore.map(x => ({ key: x._id, count: x.count })),
        nova_group: resObj.nova_group.map(x => ({ key: x._id, count: x.count })),
        brands: resObj.brands.map(x => ({ key: x._id, count: x.count })),
        total: (resObj.counts[0] && resObj.counts[0].total) ? resObj.counts[0].total : 0
      }
    });
  } catch (err) {
    console.error("getFacets error:", err);
    return res.status(500).json({ ok: false, error: err.message });
  }
};

/* GET /api/food/barcode/:barcode
   Returns product (as-is except nutriments filtered) + ingredients + additives
*/
export const getFoodByBarcode = async (req, res) => {
  try {
    const { barcode } = req.params;
    if (!barcode) return res.status(400).json({ ok: false, error: "barcode required" });

    // allow string/number candidates
    const candidates = [barcode];
    const asNum = Number(barcode);
    if (!Number.isNaN(asNum)) candidates.push(asNum);

    const product = await Food.findOne({ barcode: { $in: candidates } }).lean();
    if (!product) return res.status(404).json({ ok: false, error: "product not found" });

    // build nutriments filtered object
    const raw = product.nutriments || {};
    const nutrimentsFiltered = {
      energy_kcal: pickNutriment(raw, ["energy-kcal", "energy-kcal_value", "energy-kcal_100g", "energy_kcal", "energy-kcal_value", "energy_100g"]),
      carbohydrates_g: pickNutriment(raw, ["carbohydrates", "carbohydrates_100g", "carbohydrates_value", "carbohydrates_g"]),
      sugars_g: pickNutriment(raw, ["sugars", "sugars_100g", "sugars_value", "sugars_g"]),
      fat_g: pickNutriment(raw, ["fat", "fat_100g", "fat_value", "fat_g"]),
      saturated_fat_g: pickNutriment(raw, ["saturated-fat", "saturated-fat_100g", "saturated-fat_value", "saturated_fat_g"]),
      proteins_g: pickNutriment(raw, ["proteins", "proteins_100g", "proteins_value", "proteins_g"]),
      salt_g: pickNutriment(raw, ["salt", "salt_100g", "salt_value", "salt_g"])
    };

    // keep API tidy: convert explicit zeroes to null for some keys
    ['fat_g', 'saturated_fat_g', 'salt_g'].forEach(k => {
      if (nutrimentsFiltered[k] === 0) nutrimentsFiltered[k] = null;
    });

    // ingredients doc where barcodes array contains barcode
    const ingDoc = await IngredientsInfo.findOne({ barcodes: { $in: candidates } }).lean();
    const ingredients = (ingDoc && Array.isArray(ingDoc.ingredients)) ? ingDoc.ingredients : [];

    // additives lookup (preserve DB fields exactly)
    const additiveCodes = Array.isArray(product.additives) ? product.additives.map(c => String(c).trim().toLowerCase()).filter(Boolean) : [];
    let additives = [];
    if (additiveCodes.length) {
      const docs = await AdditiveInfo.find({ code: { $in: additiveCodes } }).lean();
      const map = new Map(docs.map(d => [String(d.code).toLowerCase(), d]));
      additives = additiveCodes.map(c => map.get(c)).filter(Boolean);
    }

    // Ensure images are present in a predictable structure
    const images = {
      front: (product.images && product.images.front) ? product.images.front : null,
      ingredients: (product.images && product.images.ingredients) ? product.images.ingredients : null,
      nutrition: (product.images && product.images.nutrition) ? product.images.nutrition : null
    };

    // Build final product payload (do not mutate DB object)
    const productOut = {
      barcode: product.barcode ? String(product.barcode) : null,
      product_name: product.product_name,
      brands: product.brands,
      quantity: product.quantity,
      packaging: product.packaging,
      categories: product.categories,
      primary_category: product.primary_category,
      images,
      nutriments: nutrimentsFiltered,
      nutriscore: product.nutriscore,
      nova_group: product.nova_group,
      additives: product.additives || []
    };

    return res.json({ ok: true, product: productOut, ingredients, additives });
  } catch (err) {
    console.error("getFoodByBarcode error:", err);
    return res.status(500).json({ ok: false, error: err.message });
  }
};

/* GET /api/food/:id/alternatives
   Return simple "healthier" alternatives within same category.
   Kept the same as previously implemented.
*/
export const getAlternatives = async (req, res) => {
  try {
    const { id } = req.params;
    const limit = Math.min(20, Math.max(1, parseInt(req.query.limit || "5", 10)));

    // find original product by _id or barcode
    let original = null;
    original = await Food.findOne({ _id: id }).lean().catch(() => null);
    if (!original) {
      original = await Food.findOne({ barcode: id }).lean();
    }
    if (!original) return res.status(404).json({ ok: false, error: "product not found" });

    const cats = Array.isArray(original.categories) ? original.categories : [];
    if (!cats.length) return res.json({ ok: true, data: [] });

    // find other products sharing categories, exclude original
    const candidates = await Food.find({
      _id: { $ne: original._id },
      categories: { $in: cats }
    }).lean();

    // Score by nutriscore if present (A best -> E worst). We'll convert A..E to 1..5 (A=1).
    const scoreFromNutri = (n) => {
      if (!n) return 999;
      const s = String(n).toUpperCase();
      const map = { A: 1, B: 2, C: 3, D: 4, E: 5 };
      return map[s] ?? 999;
    };

    const sorted = candidates
      .map(p => ({ p, score: scoreFromNutri(p.nutriscore) }))
      .sort((a, b) => a.score - b.score)
      .slice(0, limit)
      .map(x => x.p);

    return res.json({ ok: true, data: sorted });
  } catch (err) {
    console.error("getAlternatives error:", err);
    return res.status(500).json({ ok: false, error: err.message });
  }
};
