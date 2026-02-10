import axios from "axios";
import FormData from "form-data";

export async function extractTextFromImage(imageBuffer) {
  const apiKey = process.env.OCR_SPACE_API_KEY;
  if (!apiKey) {
    throw new Error("OCR_SPACE_API_KEY missing in env");
  }

  const form = new FormData();
  form.append("file", imageBuffer, "scan.jpg");
  form.append("language", "eng");
  form.append("OCREngine", "2");
  form.append("scale", "true");
  form.append("isTable", "false");

  const response = await axios.post(
    "https://api.ocr.space/parse/image",
    form,
    {
      headers: {
        ...form.getHeaders(),
        apikey: apiKey
      },
      maxBodyLength: Infinity
    }
  );

  const data = response.data;

  if (data.IsErroredOnProcessing) {
    console.error("OCR.Space error:", data.ErrorMessage);
    return "";
  }

  return data.ParsedResults?.[0]?.ParsedText?.trim() || "";
}
