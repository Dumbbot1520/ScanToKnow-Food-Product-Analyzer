// import { extractTextFromImage } from "../services/ocrSpace.service.js";

// export const scanOCR = async (req, res, next) => {
//   try {
//     if (!req.file || !req.file.buffer) {
//       return res.status(400).json({ error: "Image file required" });
//     }

//     const imageBuffer = req.file.buffer;

//     const text = await extractTextFromImage(imageBuffer);

//     return res.json({
//       status: "ok",
//       data: {
//         raw_text: text
//       }
//     });
//   } catch (err) {
//     next(err);
//   }
// };


// import { extractTextFromImage } from "../services/ocrSpace.service.js";
// import {
//   extractIngredientsAndAdditives
// } from "../services/ingredientExtractor.service.js";

// export const scanOCR = async (req, res, next) => {
//   try {
//     if (!req.file || !req.file.buffer) {
//       return res.status(400).json({ error: "Image file required" });
//     }

//     const imageBuffer = req.file.buffer;

//     // 1️⃣ OCR
//     const text = await extractTextFromImage(imageBuffer);

//     // 2️⃣ Ingredient + Additive classification
//     const classified = extractIngredientsAndAdditives(text);

//     // ✅ RETURN MUST BE HERE (inside function)
//     return res.json({
//       status: "ok",
//       data: {
//         raw_text: text,
//         classified
//       }
//     });
//   } catch (err) {
//     next(err);
//   }
// };


import { extractTextFromImage } from "../services/ocrSpace.service.js";
import { runOCRPipeline } from "../services/ocrPipeline.service.js";

export const scanOCR = async (req, res, next) => {
  try {
    if (!req.file || !req.file.buffer) {
      return res.status(400).json({ error: "Image file required" });
    }

    const text = await extractTextFromImage(req.file.buffer);
    const result = await runOCRPipeline(text);

    return res.json({
      status: "ok",
      data: result
    });
  } catch (err) {
    next(err);
  }
};

