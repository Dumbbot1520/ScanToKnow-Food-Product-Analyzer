// import app from "./app.js";
// import mongoose from "mongoose";

// const PORT = process.env.PORT || 5000;
// const MONGO_URI = process.env.MONGO_URI;

// mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
//   .then(() => {
//     console.log("MongoDB connected");
//     app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
//   })
//   .catch((err) => console.error("DB connection error:", err));


// src/server.js
import app from "./app.js";
import mongoose from "mongoose";

const PORT = process.env.PORT || 4000; // stays as-is
const MONGO_URI = process.env.MONGO_URI;

mongoose
  .connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => {
    console.log("MongoDB connected");
    app.listen(PORT, () =>
      console.log(`Server running on port ${PORT}`)
    );
  })
  .catch((err) => console.error("DB connection error:", err));


// // src/server.js
// import path from "path";
// import { fileURLToPath } from "url";
// import dotenv from "dotenv";
// import mongoose from "mongoose";
// import app from "./app.js";

// // 🔐 Resolve absolute path to project root
// const __filename = fileURLToPath(import.meta.url);
// const __dirname = path.dirname(__filename);

// // ✅ FORCE load .env from backend root
// dotenv.config({ path: path.resolve(__dirname, "../.env") });

// // 🔍 Confirm once (you can remove later)
// console.log("ENV CHECK:", {
//   PORT: process.env.PORT,
//   MONGO_URI: process.env.MONGO_URI,
// });

// const PORT = process.env.PORT || 4000;
// const MONGO_URI = process.env.MONGO_URI;

// mongoose
//   .connect(MONGO_URI)
//   .then(() => {
//     console.log("✅ MongoDB connected");
//     app.listen(PORT, () =>
//       console.log(`🚀 Server running on port ${PORT}`)
//     );
//   })
//   .catch((err) => console.error("❌ DB connection error:", err));
