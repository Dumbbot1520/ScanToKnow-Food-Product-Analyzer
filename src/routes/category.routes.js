import express from "express";
import * as CategoryController from "../controllers/category.controller.js";

const router = express.Router();

router.get("/", CategoryController.listTopCategories);
router.get("/:id", CategoryController.getCategoryById);

export default router;
