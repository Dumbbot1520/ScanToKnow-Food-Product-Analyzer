import mongoose from "mongoose";

const CategorySchema = new mongoose.Schema({
  code: String,
  name: String,
  slug: String,
  level: Number,
  parent_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Category",
    default: null
  },
  path: String,
  display_order: Number,
  icon: String,
  description: String
});

export default mongoose.model(
  "Category",
  CategorySchema,
  "categories"
);
