import Category from "../models/category.model.js";

export const getTopLevelCategories = async () => {
  return await Category.find({ level: 1 }).sort({ display_order: 1 }).lean();
};

export const getCategoryWithChildren = async (id) => {
  const category = await Category.findById(id).lean();
  if (!category) throw new Error("Category not found");

  const children = await Category.find({ parent_id: id }).sort({ display_order: 1 }).lean();

  return {
    category,
    children,
    type: children.length ? "taxonomy" : "leaf"
  };
};
