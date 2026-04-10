// // src/services/ocrSpace.service.js
// import axios from "axios";
// import FormData from "form-data";

// export async function extractTextFromImage(imageBuffer) {
//   const apiKey = process.env.OCR_SPACE_API_KEY;
//   if (!apiKey) {
//     throw new Error("OCR_SPACE_API_KEY missing in env");
//   }

//   const form = new FormData();
//   form.append("file", imageBuffer, "scan.jpg");
//   form.append("language", "eng");
//   form.append("OCREngine", "2");
//   form.append("scale", "true");
//   form.append("isTable", "false");

//   const response = await axios.post(
//     "https://api.ocr.space/parse/image",
//     form,
//     {
//       headers: {
//         ...form.getHeaders(),
//         apikey: apiKey
//       },
//       maxBodyLength: Infinity
//     }
//   );

//   const data = response.data;

//   if (data.IsErroredOnProcessing) {
//     console.error("OCR.Space error:", data.ErrorMessage);
//     return "";
//   }

//   return data.ParsedResults?.[0]?.ParsedText?.trim() || "";
// }

/* =========================================================
   ocrSpace.service.js — v2.0
   Base64 upload (more reliable than buffer)
   Retry on timeout, better OCR params
   ========================================================= */

import axios from "axios";

const OCR_API_URL = "https://api.ocr.space/parse/image";
const TIMEOUT_MS  = 30000; // 30s
const MAX_RETRIES = 2;

export async function extractTextFromImage(imageBuffer) {
  const apiKey = process.env.OCR_SPACE_API_KEY;
  if (!apiKey) throw new Error("OCR_SPACE_API_KEY missing in env");

  // Convert buffer to base64 data URI
  const base64 = imageBuffer.toString("base64");
  const dataURI = `data:image/jpeg;base64,${base64}`;

  const payload = new URLSearchParams();
  payload.append("base64Image",        dataURI);
  payload.append("language",           "eng");
  payload.append("OCREngine",          "2");
  payload.append("scale",              "true");
  payload.append("isTable",            "false");
  payload.append("isOverlayRequired",  "false");
  payload.append("detectOrientation",  "true");  // handles rotated labels
  payload.append("filetype",           "jpg");

  let lastError;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      const response = await axios.post(OCR_API_URL, payload, {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "apikey":        apiKey,
        },
        timeout: TIMEOUT_MS,
      });

      const data = response.data;

      if (data.IsErroredOnProcessing) {
        const msg = Array.isArray(data.ErrorMessage)
          ? data.ErrorMessage.join(", ")
          : data.ErrorMessage;
        throw new Error(`OCR.Space error: ${msg}`);
      }

      const text = data.ParsedResults?.[0]?.ParsedText?.trim() ?? "";
      return text;

    } catch (err) {
      lastError = err;
      const isTimeout = err.code === "ECONNABORTED" || err.message?.includes("timeout");
      if (!isTimeout || attempt === MAX_RETRIES) throw err;
      // Wait briefly before retry
      await new Promise(r => setTimeout(r, 1500));
    }
  }

  throw lastError;
}