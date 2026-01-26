// src/services/product.service.js
import mongoose from "mongoose";
import Category from "../models/category.model.js";
import ProductVariant from "../models/productVariant.model.js";

/**
 * Product listing service (category + filters + facets)
 * Robust handling of category descendant resolution using $graphLookup.
 */

// sugar buckets thresholds (g per 100g or per 100ml as your dataset uses)
const SUGAR_BUCKETS = [0, 5, 12, 1000];

/**
 * Resolve categoryId which might be:
 * - an ObjectId string
 * - a category code or slug
 * Returns an ObjectId or null
 */
async function resolveCategoryObjectId(categoryId) {
  if (!categoryId) return null;

  // if already a valid ObjectId
  if (mongoose.Types.ObjectId.isValid(categoryId)) {
    return new mongoose.Types.ObjectId(categoryId);
  }

  // try find by code or slug or name
  const cat = await Category.findOne({
    $or: [{ code: categoryId }, { slug: categoryId }, { name: categoryId }]
  }).select("_id").lean();

  if (cat && cat._id) return cat._id;
  return null;
}

/**
 * Returns array of ObjectId for the given category and all descendants
 * Uses aggregation with $graphLookup so it works regardless of how 'path' is stored.
 */
async function getDescendantCategoryIds(categoryId) {
  if (!categoryId) return [];

  const catObjectId = await resolveCategoryObjectId(categoryId);
  if (!catObjectId) return [];

  const res = await Category.aggregate([
    { $match: { _id: catObjectId } },
    {
      $graphLookup: {
        from: "categories",
        startWith: "$_id",
        connectFromField: "_id",
        connectToField: "parent_id",
        as: "descendants",
        depthField: "depth"
      }
    },
    {
      $project: {
        ids: {
          $concatArrays: [
            ["$_id"],
            { $map: { input: "$descendants", as: "d", in: "$$d._id" } }
          ]
        }
      }
    }
  ]).allowDiskUse(true);

  if (!res || res.length === 0) return [];
  return res[0].ids; // array of ObjectId
}

export async function getProductsByCategory({
  categoryId,
  filters = {},
  page = 1,
  limit = 20,
  skip = 0,
  sort = "relevance:desc",
  withFacets = true
}) {
  // Resolve descendant category ids (includes the original category id)
  const descendantIds = categoryId ? await getDescendantCategoryIds(categoryId) : [];

  // Build base match
  const match = {};
  if (descendantIds && descendantIds.length) {
    match["category_ids"] = { $in: descendantIds };
  } else if (categoryId) {
    // if categoryId provided but couldn't resolve to ObjectId, try using raw value (unlikely)
    match["category_ids"] = { $in: [categoryId] };
  }

  // Filters
  if (filters.min_sugar !== undefined || filters.max_sugar !== undefined) {
    match["nutriments.sugar_g_100g"] = {};
    if (filters.min_sugar !== undefined) match["nutriments.sugar_g_100g"].$gte = filters.min_sugar;
    if (filters.max_sugar !== undefined) match["nutriments.sugar_g_100g"].$lte = filters.max_sugar;
  }

  if (filters.brand && filters.brand.length) {
    match["brand.name"] = { $in: filters.brand };
  }

  if (filters.nova_group && filters.nova_group.length) {
    match["nova_group"] = { $in: filters.nova_group };
  }

  if (filters.nutri_score && filters.nutri_score.length) {
    match["nutri_score"] = { $in: filters.nutri_score.map(s => s.toLowerCase()) };
  }

  if (filters.has_additive && filters.has_additive.length) {
    match["additives.code"] = { $in: filters.has_additive };
  }

  const pipeline = [];

  // If textual search present, prefer $text if available (fallback)
  if (filters.q) {
    // NOTE: for production / better ranking use Atlas Search.
    pipeline.push({ $match: { $text: { $search: filters.q } } });
  } else if (Object.keys(match).length) {
    pipeline.push({ $match: match });
  }

  // Lookup parent product
  pipeline.push({
    $lookup: {
      from: "products",
      localField: "parent_product_id",
      foreignField: "_id",
      as: "product"
    }
  }, { $unwind: { path: "$product", preserveNullAndEmptyArrays: true } });

  // Projection for listing
  pipeline.push({
    $project: {
      title: "$title",
      sku: "$sku",
      barcodes: "$barcodes",
      brand: "$brand",
      quantity_value: "$quantity_value",
      quantity_unit: "$quantity_unit",
      image: "$images.front",
      sugar_per_100g: "$nutriments.sugar_g_100g",
      nova_group: "$nova_group",
      nutri_score: "$nutri_score",
      has_additives: { $gt: [{ $size: { $ifNull: ["$additives", []] } }, 0] },
      additives: "$additives.code",
      parent_product: { id: "$product._id", name: "$product.product_name" }
    }
  });

  // Sorting
  let sortStage = {};
  const [sortField, sortDir] = (sort || "relevance:desc").split(":");
  if (sortField === "sugar") sortStage["sugar_per_100g"] = sortDir === "asc" ? 1 : -1;
  else if (sortField === "nova") sortStage["nova_group"] = sortDir === "asc" ? 1 : -1;
  else sortStage["_id"] = -1; // default

  // Facet pipeline
  const facetPipeline = {
    $facet: {
      data: [
        { $sort: sortStage },
        { $skip: skip },
        { $limit: limit }
      ],
      totalCount: [{ $count: "count" }],
      brandCounts: [
        { $group: { _id: "$brand.name", count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ],
      novaCounts: [
        { $group: { _id: "$nova_group", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ],
      nutriCounts: [
        { $group: { _id: "$nutri_score", count: { $sum: 1 } } },
        { $sort: { _id: 1 } }
      ],
      sugarBuckets: [
        {
          $bucket: {
            groupBy: "$sugar_per_100g",
            boundaries: SUGAR_BUCKETS,
            default: "Unknown",
            output: { count: { $sum: 1 } }
          }
        }
      ],
      additiveCounts: [
        { $unwind: { path: "$additives", preserveNullAndEmptyArrays: true } },
        { $group: { _id: "$additives", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 50 }
      ]
    }
  };

  pipeline.push(facetPipeline);

  const agg = ProductVariant.aggregate(pipeline).allowDiskUse(true);
  const res = await agg.exec();
  const buckets = (res && res[0]) ? res[0] : {};

  const total = (buckets.totalCount && buckets.totalCount[0]) ? buckets.totalCount[0].count : 0;
  const items = (buckets.data || []).map(v => ({
    id: v._id,
    title: v.title,
    sku: v.sku,
    barcodes: v.barcodes,
    image: v.image,
    brand: v.brand && v.brand.name,
    quantity_value: v.quantity_value,
    quantity_unit: v.quantity_unit,
    sugar_per_100g: v.sugar_per_100g,
    nova_group: v.nova_group,
    nutri_score: v.nutri_score,
    has_additives: v.has_additives,
    parent_product: v.parent_product
  }));

  const facets = {
    brands: (buckets.brandCounts || []).map(b => ({ brand: b._id || "Unknown", count: b.count })),
    nova_groups: (buckets.novaCounts || []).map(n => ({ group: n._id, count: n.count })),
    nutri_scores: (buckets.nutriCounts || []).map(n => ({ score: n._id, count: n.count })),
    sugar_buckets: (buckets.sugarBuckets || []).map(b => ({ range: b._id, count: b.count })),
    additives: (buckets.additiveCounts || []).map(a => ({ code: a._id, count: a.count }))
  };

  const meta = { total, page, limit, pages: limit ? Math.ceil(total / limit) : 0 };

  return { items, facets, meta };
}
