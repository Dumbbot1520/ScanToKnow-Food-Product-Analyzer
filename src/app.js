// src/app.js
import express from "express";
import cors from "cors";
import morgan from "morgan";
import helmet from "helmet";
import dotenv from "dotenv";

// Load .env variables
dotenv.config();

import categoryRoutes from "./routes/category.routes.js";
import productRoutes from "./routes/product.routes.js";
import variantRoutes from "./routes/variant.routes.js";
import scanRoutes from "./routes/scan.routes.js";
// Future placeholders
// import searchRoutes from "./routes/search.routes.js";
// import additiveRoutes from "./routes/additive.routes.js";
// import ingredientRoutes from "./routes/ingredient.routes.js";

const app = express();

// Basic security headers
app.use(helmet());

// Logging - skip logs in test env
if (process.env.NODE_ENV !== "test") {
  app.use(morgan("dev"));
}

// Request parsing
app.use(express.json({ limit: "5mb" }));
app.use(express.urlencoded({ extended: true }));

// CORS configuration
const allowedOrigins = (process.env.CORS_ORIGINS || "")
  .split(",")
  .map(s => s.trim())
  .filter(Boolean);

if (allowedOrigins.length > 0) {
  app.use(cors({
    origin: function(origin, callback) {
      if (!origin) return callback(null, true); // allow curl, mobile
      if (allowedOrigins.includes(origin)) return callback(null, true);
      return callback(new Error("CORS: Origin not allowed"), false);
    }
  }));
} else {
  app.use(cors()); // Open CORS for local/dev
}

// Health & readiness
app.get("/health", (req, res) => {
  res.json({ status: "ok", env: process.env.NODE_ENV || "dev" });
});
app.get("/ready", (req, res) => {
  res.json({ ready: true });
});

// API Versioned Routes
app.use("/v1/categories", categoryRoutes);
app.use("/v1/products", productRoutes);
app.use("/v1/variants", variantRoutes);
app.use("/v1/scan", scanRoutes);
// Uncomment below when ready:
// app.use("/v1/search", searchRoutes);
// app.use("/v1/additives", additiveRoutes);
// app.use("/v1/ingredients", ingredientRoutes);

// 404 fallback for /v1/*
app.use("/v1/*", (req, res) => {
  res.status(404).json({ error: "Not found", path: req.originalUrl });
});

// Global error handler
app.use((err, req, res, next) => {
  const status = err.status || 500;
  const payload = {
    error: err.message || "Internal Server Error"
  };
  if (process.env.NODE_ENV !== "production") {
    payload.stack = err.stack;
  }
  console.error("Unhandled error:", err.message);
  res.status(status).json(payload);
});

export default app;
