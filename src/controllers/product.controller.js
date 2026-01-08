import { findProductByBarcode } from "../services/product.service.js";

export async function scanByBarcode(req, res) {
  try {
    const { barcode } = req.query;

    if (!barcode) {
      return res.status(400).json({
        error: {
          code: "BARCODE_REQUIRED",
          message: "Barcode query parameter is required"
        }
      });
    }

    const product = await findProductByBarcode(barcode);

    if (!product) {
      return res.status(404).json({
        error: {
          code: "PRODUCT_NOT_FOUND",
          message: "No product found for this barcode"
        }
      });
    }

    return res.json({
      data: product,
      meta: {
        source: "barcode"
      }
    });

  } catch (err) {
    console.error("Barcode scan error:", err);
    return res.status(500).json({
      error: {
        code: "SERVER_ERROR",
        message: "Internal server error"
      }
    });
  }
}
