// src/services/productDetail.service.js
import mongoose from "mongoose";
import Product from "../models/product.model.js";
import ProductVariant from "../models/productVariant.model.js";
import Ingredient from "../models/ingredient.model.js";
import Additive from "../models/additive.model.js";
import Category from "../models/category.model.js";

/**
 * Assemble a merged product/variant detail DTO from your existing collections.
 * No schema changes. Uses only reads and a small scan_stats update when requested.
 */

// Helper: safe new ObjectId
function toObjectId(id) {
  if (!id) return null;
  if (mongoose.Types.ObjectId.isValid(id)) return new mongoose.Types.ObjectId(id);
  return null;
}

// Build breadcrumb for a category by walking parent_id (small depth expected)
async function buildBreadcrumbForCategory(catId) {
  if (!catId) return [];
  const breadcrumb = [];
  let cur = await Category.findById(catId).select("_id name slug parent_id").lean();
  const seen = new Set();
  while (cur && !seen.has(String(cur._id))) {
    breadcrumb.unshift({ id: cur._id, name: cur.name, slug: cur.slug || null });
    seen.add(String(cur._id));
    if (cur.parent_id) {
      cur = await Category.findById(cur.parent_id).select("_id name slug parent_id").lean();
    } else break;
  }
  return breadcrumb;
}

// Resolve ingredient details for an ingredient_summary entry
async function resolveIngredientSummaryEntry(item) {
  // item: { ingredient_id, name, percentage }
  if (!item) return null;
  let info = null;
  if (item.ingredient_id) {
    info = await Ingredient.findById(item.ingredient_id).lean();
  }
  // Fallback: try matching by name (case-insensitive) if not found
  if (!info && item.name) {
    const regex = new RegExp(`^${item.name.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}$`, "i");
    info = await Ingredient.findOne({
      $or: [{ canonical_name: regex }, { aliases: regex }]
    }).lean();
  }
  return {
    ingredient_id: info ? info._id : (item.ingredient_id || null),
    name_in_text: item.name || null,
    canonical_name: info ? info.canonical_name : (item.name || null),
    percentage: item.percentage == null ? null : item.percentage,
    health_rating: info ? info.health_rating || null : null,
    source_tag: info ? info.source_tag || null : null,
    description: info ? info.description || null : null
  };
}

// Resolve additive entry (variant.additives entries may be { _id, code, percentage, confidence })
async function resolveAdditiveEntry(addRef) {
  if (!addRef) return null;
  const code = (addRef.code || (addRef._id && String(addRef._id)) || null);
  let info = null;
  if (code) {
    info = await Additive.findOne({ code: code }).lean();
  }
  // Fallback: if _id present and not a code, try by _id
  if (!info && addRef._id && mongoose.Types.ObjectId.isValid(addRef._id)) {
    info = await Additive.findById(addRef._id).lean();
  }
  return {
    code: info ? info.code : (code || null),
    name: info ? info.name : null,
    percentage: addRef.percentage == null ? null : addRef.percentage,
    confidence: addRef.confidence == null ? null : addRef.confidence,
    health_rating: info ? info.health_rating || null : null,
    notes: info ? info.notes || null : null,
    synonyms: info ? info.synonyms || [] : []
  };
}

// Simple heuristic to compute a compact health score if not present
function computeSimpleHealthScore(variantDoc, additiveInfos = []) {
  // variantDoc.nutriments.sugar_g_100g assumed numeric
  const nutr = variantDoc.nutriments || {};
  const sugar = (nutr.sugar_g_100g == null) ? 0 : Number(nutr.sugar_g_100g);
  const nova = variantDoc.nova_group == null ? 0 : Number(variantDoc.nova_group);
  // additive penalty: count of additives rated 'high' or 'bad'
  let additivePenalty = 0;
  for (const a of additiveInfos) {
    if (!a) continue;
    const hr = (a.health_rating || "").toLowerCase();
    if (hr === "high" || hr === "bad") additivePenalty += 1;
    else if (hr === "moderate") additivePenalty += 0.5;
  }
  // base 100, subtract weighted factors
  let score = 100;
  score -= sugar * 2.5;      // sugar penalty
  score -= nova * 4;         // nova penalty
  score -= additivePenalty * 6;
  score = Math.max(0, Math.min(100, Math.round(score)));
  const label = score > 75 ? "Healthy" : (score > 50 ? "Moderate" : "Unhealthy");
  const stars = Math.max(0, Math.min(5, Math.round((score / 100) * 5)));
  return { cphs_final: score, health_label: label, health_stars: stars };
}

async function assembleVariantDTO(variantDoc) {
  if (!variantDoc) return null;

  // parent product
  let parent = null;
  if (variantDoc.parent_product_id) {
    parent = await Product.findById(variantDoc.parent_product_id).select("_id product_name variant_ids").lean();
  }

  // siblings (variants of same product) - minimal DTOs
  let siblings = [];
  if (parent && parent.variant_ids && parent.variant_ids.length) {
    const rawSibs = await ProductVariant.find({ parent_product_id: parent._id })
      .select("_id title sku barcodes quantity_value quantity_unit images.front")
      .lean();
    siblings = rawSibs.map(s => ({
      id: s._id,
      title: s.title,
      sku: s.sku,
      barcode: (s.barcodes && s.barcodes[0]) || null,
      quantity_value: s.quantity_value || null,
      quantity_unit: s.quantity_unit || null,
      image: s.images && s.images.front ? s.images.front : null
    }));
  }

  // ingredients
  const ingredientSummary = variantDoc.ingredient_summary || [];
  const resolvedIngredients = [];
  for (const ing of ingredientSummary) {
    const r = await resolveIngredientSummaryEntry(ing);
    if (r) resolvedIngredients.push(r);
  }

  // additives
  const additiveRefs = variantDoc.additives || [];
  const resolvedAdditives = [];
  for (const a of additiveRefs) {
    const r = await resolveAdditiveEntry(a);
    if (r) resolvedAdditives.push(r);
  }

  // categories: build breadcrumbs using first category_id if present
  let categories = [];
  if (variantDoc.category_ids && variantDoc.category_ids.length) {
    // take first category id for breadcrumb; you may pick a better selection heuristic if needed
    const firstCat = variantDoc.category_ids[0];
    categories = await buildBreadcrumbForCategory(firstCat);
  }

  // compute health fields (prefer stored computed fields if available)
  let cphs_final = (variantDoc.cphs_final != null) ? variantDoc.cphs_final : null;
  let health_label = (variantDoc.health_label != null) ? variantDoc.health_label : null;
  let health_stars = (variantDoc.health_stars != null) ? variantDoc.health_stars : null;

  if (cphs_final == null) {
    const computed = computeSimpleHealthScore(variantDoc, resolvedAdditives);
    cphs_final = computed.cphs_final;
    health_label = computed.health_label;
    health_stars = computed.health_stars;
  }

  return {
    id: variantDoc._id,
    sku: variantDoc.sku || null,
    title: variantDoc.title || null,
    barcodes: variantDoc.barcodes || [],
    images: variantDoc.images || {},
    brand: (variantDoc.brand && variantDoc.brand.name) ? variantDoc.brand.name : null,
    parent_product: parent ? { id: parent._id, name: parent.product_name, variants: siblings } : null,
    quantity_value: variantDoc.quantity_value || null,
    quantity_unit: variantDoc.quantity_unit || null,
    categories,
    nutriments: variantDoc.nutriments || {},
    nutri_score: variantDoc.nutri_score || null,
    nova_group: variantDoc.nova_group || null,
    cphs_final,
    health_label,
    health_stars,
    ingredient_summary: resolvedIngredients,
    additives: resolvedAdditives,
    tags: [], // placeholder - you can fill from product/variant flavor_tags later
    scan_stats: variantDoc.scan_stats || { total_scans: 0, last_scanned: null }
  };
}

/* Public: get variant by id (full assembled DTO) */
export async function getVariantDetailById(variantId) {
  if (!variantId) return null;
  const _id = toObjectId(variantId) || variantId;
  const variant = await ProductVariant.findById(_id).lean();
  if (!variant) return null;
  const dto = await assembleVariantDTO(variant);
  return dto;
}

/* Public: get variant by barcode */
export async function getVariantDetailByBarcode(barcode) {
  if (!barcode) return null;
  const variant = await ProductVariant.findOne({ barcodes: { $in: [barcode] } }).lean();
  if (!variant) return null;
  const dto = await assembleVariantDTO(variant);
  return { dto, variantDoc: variant }; // return variantDoc if caller wants to update scan stats
}

/* Public: get product-level detail (parent product + full variants list) */
export async function getProductDetailById(productId) {
  if (!productId) return null;
  const _id = toObjectId(productId) || productId;
  const product = await Product.findById(_id).lean();
  if (!product) return null;

  // fetch all variants for this product
  const variants = await ProductVariant.find({ parent_product_id: product._id }).lean();
  const variantDTOs = [];
  for (const v of variants) {
    const dto = await assembleVariantDTO(v);
    variantDTOs.push(dto);
  }

  return {
    id: product._id,
    product_name: product.product_name,
    code: product.code || null,
    brand: product.brand || null,
    flavor_tags: product.flavor_tags || [],
    curated: product.curated || false,
    variants: variantDTOs
  };
}

/* Helper: increment scan stats on a variant (safe inline update) */
export async function incrementVariantScanStats(variantId) {
  if (!variantId) return;
  const _id = toObjectId(variantId) || variantId;
  try {
    await ProductVariant.findByIdAndUpdate(_id, {
      $inc: { "scan_stats.total_scans": 1 },
      $set: { "scan_stats.last_scanned": new Date() }
    });
  } catch (e) {
    console.error("Failed to update scan_stats:", e.message);
  }
}
