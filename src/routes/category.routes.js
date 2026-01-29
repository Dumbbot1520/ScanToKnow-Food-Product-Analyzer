// src/routes/category.routes.js
import express from "express";
import * as CategoryController from "../controllers/category.controller.js";

const router = express.Router();

// list top-level
router.get("/", CategoryController.listCategories);

// get single
router.get("/:id", CategoryController.getCategory);

// get children
router.get("/:id/children", CategoryController.getChildren);

// products for category (descendants included)
router.get("/:id/products", CategoryController.getProductsForCategory);

export default router;
