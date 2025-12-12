// // routes/foodRoutes.js
// import express from "express";
// import { getFoods, getFoodByBarcode, getAlternatives } from "../controllers/foodController.js";
// const router = express.Router();

// router.get("/", getFoods);
// router.get("/barcode/:barcode", getFoodByBarcode);
// router.get("/:id/alternatives", getAlternatives);

// export default router;


// routes/foodRoutes.js
import express from "express";
import { getFoods, getFoodByBarcode, getAlternatives, getFacets } from "../controllers/foodController.js";
const router = express.Router();

router.get("/facets", getFacets);            // new: facets for filters
router.get("/", getFoods);                   // list / search
router.get("/barcode/:barcode", getFoodByBarcode); // detail by barcode
router.get("/:id/alternatives", getAlternatives);  // alternatives (existing)

export default router;
