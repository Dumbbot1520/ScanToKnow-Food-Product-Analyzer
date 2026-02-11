/* =========================================================
   Ingredient & Additive Extractor (OCR)
   Ported from Flutter (final logic)
   ========================================================= */

const MIN_E = 100;
const MAX_E = 1520;

const CONTEXT_WORDS = [
  "preserv",
  "regulator",
  "acidity",
  "stabilizer",
  "emulsifier",
  "color",
  "colour",
  "additive",
  "antioxidant",
  "agent",
  "class",
  "treatment",
  "acid",
  "ins",
  "e"
];

const NAME_BASED_ADDITIVES = {
  "sorbic acid": "e200",
  "benzoic acid": "e210",
  "citric acid": "e330",
  "sodium citrate": "e331",
  "ascorbic acid": "e300",
  "riboflavin": "e101",
  "sucralose": "e955",
  "acesulfame potassium": "e950",
  "calcium propionate": "e282",
  "monoglyceride": "e471",
  "diglyceride": "e471",
  "lecithin": "e322"
};

/* -------------------- TEXT CLEANER -------------------- */

function cleanText(text) {
  if (!text) return "";

  let cleaned = text.toLowerCase();

  cleaned = cleaned.replace(/[^a-z0-9,().:;\n -]/g, "");

  cleaned = cleaned
    .split("\n")
    .map(line => line.trim().replace(/\s+/g, " "))
    .join("\n");

  cleaned = cleaned.replace(/\s*,\s*/g, ", ");

  return cleaned.trim();
}

/* ---------------- INGREDIENT SECTION ---------------- */

function extractIngredientsSection(text) {
  const cleaned = cleanText(text);
  const lower = cleaned.toLowerCase();

  const words = lower.split(/[\s,:;.]+/);
  let startIndex = -1;

  for (const w of words) {
    if (similar(w, "ingredient") >= 0.7) {
      startIndex = lower.indexOf(w);
      break;
    }
  }

  if (startIndex === -1) return "";

  let after = cleaned.substring(startIndex);

  const stopWords = [
    "nutrition",
    "allergen",
    "warning",
    "expiry",
    "manufact"
  ];

  let end = after.length;
  for (const stop of stopWords) {
    const idx = after.toLowerCase().indexOf(stop);
    if (idx !== -1 && idx < end) end = idx;
  }

  let section = after.substring(0, end).trim();
  section = section.replace(/ingredi\w*/i, "").replace(":", "").trim();

  return section;
}

/* -------------------- SPLITTER -------------------- */

function splitIngredients(raw) {
  if (!raw) return [];

  return raw
    .replace(/\n/g, ",")
    .replace(/;/g, ",")
    .replace(/\s+/g, " ")
    .toLowerCase()
    .split(",")
    .map(e => e.trim())
    .filter(Boolean);
}

/* ---------------- CLASSIFICATION ---------------- */

function classifyItems(items) {
  const ingredients = new Set();
  const additives = new Set();

  for (const rawItem of items) {
    const s = rawItem
  .toLowerCase()
  .replace(/[()\.]$/g, "") // 🔥 remove trailing ), .
  .trim();

  // Ignore junk numeric leftovers
if (/^\d{1,4}$/.test(s)) continue;

// Ignore long cosmetic flavor text
if (s.includes("flavoring substances")) continue;


    const p = extractParenthesisAdditive(s);
    if (p) {
      additives.add(finalizeCode(p));
      continue;
    }

    const ins = extractINSCode(s);
    if (ins) {
      additives.add(finalizeCode(ins));
      continue;
    }

    const messy = extractMessyECandidate(s);
    if (messy) {
      const normalized = normalizeCandidate(messy);
      const resolved = resolveHybrid(normalized, s);
      if (resolved) {
        additives.add(resolved);
        continue;
      }
    }

    const numeric = detectBareNumberAdditive(s);
    if (numeric) {
      additives.add(numeric);
      continue;
    }

    const name = detectByName(s);
    if (name) {
      additives.add(name);
      continue;
    }

    ingredients.add(rawItem);
  }

  return {
    ingredients: Array.from(ingredients),
    additives: Array.from(additives)
  };
}

/* ---------------- HELPERS ---------------- */

function extractParenthesisAdditive(s) {
  const m = s.match(/\(\s*(e?\d{3,4}[a-z]?)\s*\)/i);
  if (!m) return null;

  let code = m[1].toLowerCase();
  const digits = code.replace("e", "");
  if (digits.length < 3) return null;

  if (!code.startsWith("e")) code = "e" + code;
  return code;
}

function extractINSCode(s) {
  const m = s.match(/ins\s*[-:]?\s*(\d{3,4}[a-z]?)/i);
  return m ? "e" + m[1].toLowerCase() : null;
}

function extractMessyECandidate(s) {
  const m = s.match(/\be[\da-z\-\s]{1,10}\b/i);
  return m ? m[0] : null;
}

function normalizeCandidate(candidate) {
  let c = candidate.toLowerCase().replace(/[^a-z0-9]/g, "");
  c = c.replace(/o/g, "0").replace(/l/g, "1");

  const m = c.match(/(\d{3,4}[a-z]?)/);
  return m ? "e" + m[1] : "e";
}

function resolveHybrid(normalized, original) {
  const m = normalized.match(/e(\d{3,4})([a-z]?)/);
  if (!m) return null;

  const num = parseInt(m[1], 10);
  const letter = m[2];

  if (num >= MIN_E && num <= MAX_E) {
    return letter ? `e${num}${letter}` : `e${num}`;
  }

  const fallback = original.match(/(\d{3,4})/);
  if (fallback) {
    const n = parseInt(fallback[1], 10);
    if (n >= MIN_E && n <= MAX_E) return `e${n}`;
  }

  return null;
}

function detectBareNumberAdditive(s) {
  const m = s.match(/\b(\d{3,4})\b/);
  if (!m) return null;

  const n = parseInt(m[1], 10);
  if (n >= MIN_E && n <= MAX_E && hasContext(s)) {
    return `e${n}`;
  }
  return null;
}

function detectByName(s) {
  for (const name in NAME_BASED_ADDITIVES) {
    if (s.includes(name)) return NAME_BASED_ADDITIVES[name];
  }
  return null;
}

function hasContext(s) {
  return CONTEXT_WORDS.some(w => s.includes(w));
}

function finalizeCode(code) {
  const m = code.toLowerCase().match(/e(\d{3,4}[a-z]?)/);
  return m ? `e${m[1]}` : code;
}

function similar(a, b) {
  let score = 0;
  const len = Math.min(a.length, b.length);
  for (let i = 0; i < len; i++) {
    if (a[i] === b[i]) score++;
  }
  return score / b.length;
}

/* ---------------- PUBLIC API ---------------- */

export function extractIngredientsAndAdditives(rawText) {
  const section = extractIngredientsSection(rawText);
  const items = splitIngredients(section || rawText);
  return classifyItems(items);
}
