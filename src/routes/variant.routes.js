// src/routes/variant.routes.js
import express from "express";
import * as ProductDetailController from "../controllers/productDetail.controller.js";

const router = express.Router();

// GET /v1/variants/:id -> variant-level detail
router.get("/:id", ProductDetailController.getVariantDetail);

export default router;