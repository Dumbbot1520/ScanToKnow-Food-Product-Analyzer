// src/controllers/scan.controller.js
import * as ProductDetailService from "../services/productDetail.service.js";

/**
 * GET /v1/scan/:barcode
 * Finds variant by barcode, increments scan stats, and returns merged DTO.
 */
export const scanByBarcode = async (req, res, next) => {
  try {
    const barcode = req.params.barcode;
    if (!barcode) return res.status(400).json({ error: "Barcode required" });

    const result = await ProductDetailService.getVariantDetailByBarcode(barcode);
    if (!result || !result.dto) return res.status(404).json({ error: "Product not found for barcode" });

    // increment scans (best-effort)
    try {
      await ProductDetailService.incrementVariantScanStats(result.variantDoc._id);
    } catch (e) {
      // log and continue
      console.error("scan stats update failed", e.message);
    }

    res.json({ status: "ok", data: result.dto });
  } catch (err) {
    next(err);
  }
};
