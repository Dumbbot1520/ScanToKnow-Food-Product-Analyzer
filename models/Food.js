
// models/Food.js
import mongoose from "mongoose";

const NutrimentsSchema = new mongoose.Schema({}, { strict: false, _id: false });

const FoodSchema = new mongoose.Schema({
  barcode: { type: String, index: true, sparse: true },
  product_name: { type: String, required: true },
  brands: { type: String },
  quantity: { type: String },
  packaging: [String],
  categories: [String],
  labels: [String],
  additives: [String],        // e.g. ["e150d","e338"]
  allergens: [String],
  traces: [String],
  nutriscore: String,
  nova_group: Number,
  ecoscore: mongoose.Schema.Types.Mixed,
  nutriments: { type: NutrimentsSchema, default: {} },
  images: {
    front: String,
    ingredients: String,
    nutrition: String
  },

  // Canonical, normalized category used for UI filtering (e.g. "drinks", "biscuits")
  // Stored lowercase for predictable filtering. Make sure your migration adds this field.
  primary_category: { type: String, lowercase: true, index: true },

  last_updated: { type: Date, default: Date.now }
}, { timestamps: true });

// Explicit collection name (matches your DB)
export default mongoose.models.Food || mongoose.model("Food", FoodSchema, "food");
