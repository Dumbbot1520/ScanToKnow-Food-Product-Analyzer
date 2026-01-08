import express from "express";
import { scanByBarcode } from "../controllers/product.controller.js";

const router = express.Router();

// Barcode scan (Fanta testing standard)
router.get("/scan", scanByBarcode);

export default router;
