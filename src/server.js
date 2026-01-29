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
