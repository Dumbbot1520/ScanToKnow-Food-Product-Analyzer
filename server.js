// server.js
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/db.js";

import foodRoutes from "./routes/foodRoutes.js";
import additiveRoutes from "./routes/additiveRoutes.js";
import ingredientRoutes from "./routes/ingredientRoutes.js";

dotenv.config();
await connectDB();

const app = express();
app.use(cors());
app.use(express.json({ limit: "10mb" }));

app.get("/", (req, res) => res.send("🚀 Scan2Know Backend API"));

app.use("/api/food", foodRoutes);
app.use("/api/additives", additiveRoutes);
app.use("/api/ingredients", ingredientRoutes);

const PORT = process.env.PORT || 5000;
app.listen(5000, "0.0.0.0", () => {
    console.log("Server running on port 5000");
});
