import ProductVariant from "../models/productVariant.model.js";

export async function findProductByBarcode(barcode) {
  return ProductVariant.findOne({ barcodes: barcode })
    .populate({
      path: "ingredient_summary.ingredient_id",
      select: "canonical_name description source_tag category",
      strictPopulate: false
    })
    .populate({
      path: "additives._id",
      select: "code name description source_tag category",
      strictPopulate: false
    })
    .populate({
      path: "category_ids",
      select: "name slug level parent_id",
      strictPopulate: false
    })
    .lean();
}
