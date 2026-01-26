import mongoose from "mongoose";

const categorySchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    slug: { type: String },
    description: { type: String },
    parent_id: { type: mongoose.Schema.Types.ObjectId, ref: "Category", default: null },
    level: { type: Number, default: 1 },
    path: [{ type: mongoose.Schema.Types.ObjectId, ref: "Category" }],
    display_order: { type: Number, default: 0 },
    icon: { type: String },
  },
  { timestamps: true }
);

categorySchema.index({ parent_id: 1 });
categorySchema.index({ path: 1 });
categorySchema.index({ code: 1, name: 1 });

const Category = mongoose.model("Category", categorySchema);
export default Category;
