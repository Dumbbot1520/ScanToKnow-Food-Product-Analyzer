// src/services/category.service.js
import mongoose from "mongoose";
import Category from "../models/category.model.js";
import ProductVariant from "../models/productVariant.model.js";

/** Accept slug or ObjectId */
async function findCategoryByIdOrSlug(idOrSlug) {
  if (!idOrSlug) return null;
  if (mongoose.Types.ObjectId.isValid(idOrSlug)) {
    const byId = await Category.findById(idOrSlug).lean();
    if (byId) return byId;
  }
  return await Category.findOne({ slug: idOrSlug }).lean();
}

/** level optional */
export async function listCategories({ level } = {}) {
  const q = {};
  if (level) q.level = level;
  const cats = await Category.find(q)
    .select("_id code name slug level parent_id display_order icon description path")
    .sort({ display_order: 1, name: 1 })
    .lean();
  return cats;
}

export async function getCategoryByIdOrSlug(idOrSlug) {
  return findCategoryByIdOrSlug(idOrSlug);
}

export async function getImmediateChildren(idOrSlug) {
  const cat = await findCategoryByIdOrSlug(idOrSlug);
  if (!cat) return [];
  return await Category.find({ parent_id: cat._id })
    .select("_id code name slug level parent_id display_order icon description path")
    .sort({ display_order: 1, name: 1 })
    .lean();
}

/** Get all descendant category IDs (including selected category) using path prefix */
async function getDescendantCategoryIds(cat) {
  if (!cat) return [];
  const prefix = cat.path || ("," + cat.slug + ",");
  const escaped = prefix.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
  const regex = new RegExp("^" + escaped);
  const cats = await Category.find({ path: { $regex: regex } }).select("_id").lean();
  return cats.map(c => c._id);
}

/** products listing */
export async function getProductsForCategory({ id, page = 1, limit = 24, sort = "popular" }) {
  const cat = await findCategoryByIdOrSlug(id);
  if (!cat) return { total: 0, page, limit, products: [] };

  const descendantIds = await getDescendantCategoryIds(cat);
  if (!descendantIds.length) return { total: 0, page, limit, products: [] };

  // Sorting - sample: popular => sort by scan_stats.total_scans desc
  const sortMap = {
    popular: { "scan_stats.total_scans": -1 },
    new: { created_at: -1 },
    alpha: { title: 1 }
  };
  const sortSpec = sortMap[sort] || sortMap.popular;

  // count then fetch
  const filter = { category_ids: { $in: descendantIds } };
  const total = await ProductVariant.countDocuments(filter);
  const products = await ProductVariant.find(filter)
    .select("_id sku title barcodes images quantity_value quantity_unit brand nutri_score nova_group cphs_final")
    .sort(sortSpec)
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  return { total, page, limit, products };
}
