import express from "express";
import productRoutes from "./routes/product.routes.js";

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// API routes
app.use("/api/products", productRoutes);

export default app;
