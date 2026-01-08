import mongoose from "mongoose";

const IngredientSchema = new mongoose.Schema({
  canonical_name: { type: String, required: true },
  aliases: [String],
  description: String,
  health_rating: String,
  source_tag: String,
  category: String
});

export default mongoose.model(
  "Ingredient",
  IngredientSchema,
  "ingredients"
);
