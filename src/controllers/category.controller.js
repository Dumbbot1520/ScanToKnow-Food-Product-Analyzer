import * as CategoryService from "../services/category.service.js";

export const listTopCategories = async (req, res, next) => {
  try {
    const categories = await CategoryService.getTopLevelCategories();
    res.json(categories);
  } catch (err) {
    next(err);
  }
};

export const getCategoryById = async (req, res, next) => {
  try {
    const result = await CategoryService.getCategoryWithChildren(req.params.id);
    res.json(result);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
};
