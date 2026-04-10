// /* =========================================================
//    ingredientExtractor.service.js — v4.0
   
//    KEY CHANGES FROM v3:
//    1. Line-join healing: merges lines where a word is split
//       across line boundaries (e.g. "ACIDITY\nREGULATORS")
//    2. Entity rule: "LABEL (code1, code2)" → single entity.
//       The label name + each bracket item are ALL candidates.
//    3. Descriptive bracket: "FLAVOURS (NATURAL FLAVOURING
//       SUBSTANCES)" → try "Flavours" AND "Natural Flavouring
//       Substances" against DB (OR logic, first match wins)
//    4. Bare numbers in brackets (330, 211) treated as E-codes
//    5. REMOVED: nutriments extraction (moved out of scope)
//    ========================================================= */

// const MIN_E = 100;
// const MAX_E = 1520;

// /* =========================================================
//    NOISE LINE PATTERNS
//    ========================================================= */
// const NOISE_PATTERNS = [
//   /^may contain/i,
//   /^contains no /i,
//   /^allergen/i,
//   /^allergy/i,
//   /manufactured\s*(by|in)/i,
//   /packed\s*(by|in)/i,
//   /best before/i,
//   /use before/i,
//   /expiry/i,
//   /net\s*wt/i,
//   /net\s*weight/i,
//   /serving size/i,
//   /per\s*100\s*(ml|g)/i,
//   /per\s*serve/i,
//   /%\s*rda/i,
//   /based on.*kcal/i,
//   /approx.*val/i,
//   /nutrition(al)?\s*(info|fact|value)/i,
//   /^\s*energy\s*[\d]/i,
//   /^\s*carbohydrate/i,
//   /^\s*total fat/i,
//   /^\s*protein\s*[\d]/i,
//   /^\s*sodium\s*[\d]/i,
//   /^\s*dietary\s*fib/i,
//   /product of/i,
//   /imported by/i,
//   /distributed by/i,
//   /marketed by/i,
//   /fssai/i,
//   /lic(ence|ense|\.)\s*no/i,
//   /batch\s*no/i,
//   /mfg\s*date/i,
//   /^\s*vegetarian\s*$/i,
//   /^\s*vegan\s*$/i,
//   /^\s*halal\s*$/i,
//   /^\s*kosher\s*$/i,
//   /contains no fruit/i,
//   /sweetened carbonated/i,
//   /^\s*\d+(\.\d+)?\s*(ml|g|kg|l)\s*$/i,
//   /^\s*\d+(\.\d+)?%\s*$/i,
//   /contient\s*:/i,
//   /ingr[eé]dients\s*:/i,
//   /^\s*[a-z]{1,2}\s*$/i,
//   // Nutrition table rows
//   /^\s*total sugars/i,
//   /^\s*added sugars/i,
//   /^\s*\*based on/i,
//   /^\s*serving\s*=/i,
//   /^\s*per\s*\d/i,
//   /^\s*%rda/i,
//   /^\s*\d+(\.\d+)?\s*kcal/i,
//   /^\s*\d+(\.\d+)?\s*kj/i,
// ];

// /* =========================================================
//    STOP PHRASES — everything after these is discarded
//    ========================================================= */
// const STOP_PHRASES = [
//   "allergen",
//   "allergy advice",
//   "may contain",
//   "contains no",
//   "nutrition information",
//   "nutritional information",
//   "nutrition facts",
//   "nutritional value",
//   "nutrition value",
//   "manufactured by",
//   "manufactured in",
//   "packed by",
//   "best before",
//   "expiry date",
//   "net weight",
//   "net wt",
//   "fssai",
//   "customer care",
//   "for more information",
//   "contient :",
//   "ingrédients :",
//   "zutaten",
//   "ingredienti",
//   // Nutrition table triggers
//   "nutrition information",
//   "approximate values",
//   "serving =",
//   "per 100",
//   "*based on",
// ];

// /* =========================================================
//    INGREDIENTS SECTION HEADER PATTERNS
//    ========================================================= */
// const HEADER_PATTERNS = [
//   /ingredi[ea]nts?\s*:/i,
//   /ingr[ei]di[ea]nts?\s*:/i,
//   /lngredients?\s*:/i,
//   /lngr[ei]di[ea]nts?\s*:/i,
//   /composition\s*:/i,
//   /made\s+with\s*:/i,
//   /ingredi[ea]nts?\s*\n/i,
//   /ingredi[ea]nts\s+include/i,
// ];

// /* =========================================================
//    STEP 1 — OCR TEXT CLEANUP + LINE-JOIN HEALING
   
//    THE CORE PROBLEM: OCR returns text line by line.
//    "ACIDITY\nREGULATORS (330, 331(iii))" are on separate
//    lines. We need to join them intelligently.
   
//    RULE: If a line ends WITHOUT a comma AND the next line
//    does NOT start a new sentence/section, join them with
//    a space. We then let the comma-splitter handle the rest.
   
//    We only split on newlines if:
//    - Previous line ended with comma, or
//    - Next line starts with a known section keyword
//    ========================================================= */
// function cleanOCRText(raw) {
//   if (!raw) return "";

//   let text = raw;

//   // Normalize line endings
//   text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");

//   // Fix common OCR character confusions in E-codes
//   text = text.replace(/\b[lI](\d{3,4}[a-z]?)\b/g, (_, n) => {
//     const num = parseInt(n, 10);
//     if (num >= MIN_E && num <= MAX_E) return `e${n}`;
//     return _;
//   });

//   // "lns" or "LNS" → "ins"
//   text = text.replace(/\b[lL][nN][sS]\b/g, "ins");

//   // Normalize per-line whitespace
//   const lines = text
//     .split("\n")
//     .map(line => line.trim().replace(/\s+/g, " "))
//     .filter(Boolean);

//   // ── LINE-JOIN HEALING ──────────────────────────────────
//   // Join lines that belong to the same ingredient token.
//   // A line break is KEPT (becomes comma-equivalent) only if:
//   //   (a) The previous line ends with "," or "." or ";"
//   //   (b) The next line looks like a new section header
//   //   (c) The previous line ends with ")" — closed bracket
//   // Otherwise, join with a space (the word was just wrapped).
//   const healed = [];
//   for (let i = 0; i < lines.length; i++) {
//     const cur  = lines[i];
//     const prev = healed[healed.length - 1];

//     if (!prev) {
//       healed.push(cur);
//       continue;
//     }

//     const prevEndsWithDelimiter = /[,\.;]\s*$/.test(prev);
//     const prevEndsWithClose     = /\)\s*$/.test(prev);
//     const curStartsNewSection   = HEADER_PATTERNS.some(p => p.test(cur));
//     const curStartsWithCapWord  = /^[A-Z][A-Z\s]{4,}:/.test(cur); // "NUTRITION INFORMATION:"

//     // If the previous line has an unclosed bracket, always join
//     const openCount  = (prev.match(/\(/g) || []).length;
//     const closeCount = (prev.match(/\)/g) || []).length;
//     const hasUnclosedBracket = openCount > closeCount;

//     if (
//       hasUnclosedBracket ||
//       (!prevEndsWithDelimiter && !prevEndsWithClose && !curStartsNewSection && !curStartsWithCapWord)
//     ) {
//       // Join with space — this was a wrapped word
//       healed[healed.length - 1] = prev + " " + cur;
//     } else {
//       // Treat as a separate line (potential new token group)
//       healed.push(cur);
//     }
//   }

//   return healed.join("\n").trim();
// }

// /* =========================================================
//    STEP 2 — ISOLATE INGREDIENTS SECTION
//    ========================================================= */
// function isolateSection(text) {
//   // Find header
//   let headerEnd = -1;
//   for (const pattern of HEADER_PATTERNS) {
//     const match = text.match(pattern);
//     if (match && match.index !== undefined) {
//       headerEnd = match.index + match[0].length;
//       break;
//     }
//   }

//   // No header found — check if text looks like a raw ingredients list
//   if (headerEnd === -1) {
//     const commas  = (text.match(/,/g)  || []).length;
//     const bullets = (text.match(/•/g)  || []).length;
//     if (commas > 2 || bullets > 2) {
//       headerEnd = 0;
//     } else {
//       return "";
//     }
//   }

//   let section = text.substring(headerEnd);

//   // Cut at stop phrases
//   const sectionLower = section.toLowerCase();
//   let cutAt = section.length;

//   for (const stop of STOP_PHRASES) {
//     const idx = sectionLower.indexOf(stop);
//     if (idx > 0 && idx < cutAt) {
//       cutAt = idx;
//     }
//   }

//   section = section.substring(0, cutAt).trim();
//   section = section.replace(/\.\s*$/, "").trim();

//   return section;
// }

// /* =========================================================
//    STEP 3 — SMART SPLIT (respects bracket depth)
//    Splits on commas at depth 0 only.
//    ========================================================= */
// function smartSplit(text) {
//   const tokens = [];
//   let depth = 0;
//   let current = "";

//   for (let i = 0; i < text.length; i++) {
//     const ch = text[i];
//     if (ch === "(" || ch === "[") {
//       depth++;
//       current += ch;
//     } else if (ch === ")" || ch === "]") {
//       depth = Math.max(0, depth - 1);
//       current += ch;
//     } else if (ch === "," && depth === 0) {
//       const t = current.trim();
//       if (t) tokens.push(t);
//       current = "";
//     } else {
//       current += ch;
//     }
//   }

//   const t = current.trim();
//   if (t) tokens.push(t);
//   return tokens;
// }

// function splitIntoTokens(section) {
//   if (!section) return [];

//   let text = section;

//   // Bullets → comma
//   text = text.replace(/•/g, ",");
//   // Semicolons → comma
//   text = text.replace(/;/g, ",");
//   // Newlines → comma (join lines as separate token groups)
//   text = text
//     .split("\n")
//     .map(l => l.trim())
//     .filter(Boolean)
//     .join(", ");

//   // Clean up multiple commas
//   text = text.replace(/,\s*,+/g, ",");

//   return smartSplit(text)
//     .map(t => t.trim())
//     .filter(Boolean);
// }

// /* =========================================================
//    STEP 4 — PARSE BRACKET CONTENT
   
//    NEW RULEBOOK for bracket content:
   
//    Case A — NUMERIC CODES: "(330, 331(iii), 211)"
//      → Extract each number as an E-code
//      → The parent label (e.g. "ACIDITY REGULATORS") also
//        becomes a candidate name for DB matching
   
//    Case B — DESCRIPTIVE TEXT: "(NATURAL FLAVOURING SUBSTANCES)"
//      → The parent label "FLAVOURS" is a candidate
//      → The bracket content "NATURAL FLAVOURING SUBSTANCES"
//        is ALSO a candidate (OR logic — whichever DB matches)
   
//    Case C — MIXED: "(COLOUR (150d))"
//      → Extract 150d as E-code, "COLOUR" as name candidate
//    ========================================================= */

// function isNumericCodeContent(content) {
//   // Content is mostly numbers/codes like "330, 331(iii), 211"
//   // At least one valid E-code range number present
//   return /\d{3,4}/.test(content);
// }

// function isDescriptiveBracket(content) {
//   const hasCode = /\d{3,4}/.test(content);
//   const wordCount = content.trim().split(/\s+/).length;
//   return !hasCode && wordCount >= 1;
// }

// /* =========================================================
//    Extract E-codes from bracket content like "330, 331(iii)"
//    ========================================================= */
// function extractCodesFromBracket(content) {
//   const codes = [];
//   // Split on comma or & at top level inside bracket
//   const parts = smartSplit(content);

//   for (let part of parts) {
//     part = part.trim().toLowerCase();
//     if (!part) continue;

//     // Strip Roman numeral qualifiers like "(iii)" "(ii)" from end
//     part = part.replace(/\s*\([ivxIVX]+\)\s*$/, "").trim();
//     part = part.replace(/[ivx]+$/, "").trim(); // "331iii" → "331"

//     // INS pattern: "ins 330", "ins330"
//     const insMatch = part.match(/ins\s*[-:]?\s*(\d{3,4})/i);
//     if (insMatch) {
//       const n = parseInt(insMatch[1], 10);
//       if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
//     }

//     // E-code: "e330", "E331"
//     const eCodeMatch = part.match(/^e(\d{3,4})/i);
//     if (eCodeMatch) {
//       const n = parseInt(eCodeMatch[1], 10);
//       if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
//     }

//     // Bare number: "330", "211"
//     const bareMatch = part.match(/^(\d{3,4})/);
//     if (bareMatch) {
//       const n = parseInt(bareMatch[1], 10);
//       if (n >= MIN_E && n <= MAX_E) { codes.push(`e${n}`); continue; }
//     }
//   }

//   return [...new Set(codes)]; // deduplicate
// }

// /* =========================================================
//    STEP 5 — STRIP PERCENTAGE PREFIX
//    ========================================================= */
// function stripPercentagePrefix(s) {
//   return s
//     .replace(/^(and\s+)?(less\s+than|more\s+than|at\s+least)?\s*\d+(\.\d+)?\s*%\s*(or\s+less\s+)?(of\s*:?\s*)?/i, "")
//     .replace(/^\d+(\.\d+)?\s*%\s*(or\s+less\s+(of\s*)?:?\s*)?/i, "")
//     .trim();
// }

// /* =========================================================
//    UTILITY
//    ========================================================= */
// function toTitleCase(str) {
//   return str
//     .toLowerCase()
//     .replace(/\b\w/g, c => c.toUpperCase())
//     .trim();
// }

// /* =========================================================
//    STEP 6 — CLASSIFY TOKENS
   
//    NEW ENTITY RULE:
//    A token like "ACIDITY REGULATORS (330, 331(iii))" is ONE
//    entity. We should:
//    1. Extract E-codes from brackets → eCodes[]
//    2. Add the base name "Acidity Regulators" to unresolvedNames
//       (in case it's also in DB as an ingredient/additive)
   
//    A token like "FLAVOURS (NATURAL FLAVOURING SUBSTANCES)":
//    1. No numeric codes in bracket
//    2. Add "Flavours" to unresolvedNames
//    3. ALSO add each part of the bracket content to unresolvedNames
//       → "Natural Flavouring Substances"
//       (pipeline will try to match both; first match wins)
   
//    Returns { eCodes[], unresolvedNames[] }
//    where unresolvedNames preserves GROUPS for OR-matching:
//    Each entry is either a string OR an array of strings
//    (the array means "match any one of these").
   
//    We flatten to strings but mark bracket alternatives with
//    a special structure so ocrPipeline can try them in order.
//    ========================================================= */
// function classifyTokens(tokens) {
//   const eCodes = new Set();
//   // Each entry: string (single candidate) or string[] (OR group)
//   const candidateGroups = [];

//   for (let rawToken of tokens) {
//     rawToken = rawToken.trim();
//     if (!rawToken) continue;

//     // ── NOISE FILTER ─────────────────────────────────────
//     if (NOISE_PATTERNS.some(p => p.test(rawToken))) continue;

//     // Strip percentage prefix
//     const dePercent = stripPercentagePrefix(rawToken);
//     const working   = dePercent || rawToken;

//     // Discard if pure number or too short
//     if (/^\d+(\.\d+)?%?$/.test(working)) continue;
//     if (working.length < 2) continue;

//     // ── EXTRACT ALL BRACKET CONTENTS ─────────────────────
//     // We process outermost brackets; nested handled by extractCodesFromBracket
//     const bracketRegex = /\(([^()]*(?:\([^()]*\)[^()]*)*)\)/g;
//     const brackets = [];
//     let bMatch;
//     while ((bMatch = bracketRegex.exec(working)) !== null) {
//       brackets.push(bMatch[1]);
//     }

//     // Base token with all brackets removed
//     const base = working.replace(/\([^()]*(?:\([^()]*\)[^()]*)*\)/g, "").trim();
//     const baseNorm = toTitleCase(base);

//     // ── PROCESS BRACKETS ──────────────────────────────────
//     const nameCandidates = []; // names to try for DB matching (OR logic)

//     // The base name is always a primary candidate (if non-trivial)
//     if (baseNorm.length > 2 && !NOISE_PATTERNS.some(p => p.test(baseNorm))) {
//       // Check if base is a direct E-code first
//       const directE = base.match(/^e(\d{3,4}[a-z]?)$/i);
//       if (directE) {
//         const n = parseInt(directE[1], 10);
//         if (n >= MIN_E && n <= MAX_E) {
//           eCodes.add(`e${directE[1].toLowerCase()}`);
//           continue; // don't add to names
//         }
//       }

//       const insInBase = base.match(/ins\s*[-:]?\s*(\d{3,4})/i);
//       if (insInBase) {
//         const n = parseInt(insInBase[1], 10);
//         if (n >= MIN_E && n <= MAX_E) {
//           eCodes.add(`e${n}`);
//           continue;
//         }
//       }

//       const bareNum = base.match(/^(\d{3,4})$/);
//       if (bareNum) {
//         const n = parseInt(bareNum[1], 10);
//         if (n >= MIN_E && n <= MAX_E) {
//           eCodes.add(`e${n}`);
//           continue;
//         }
//       }

//       nameCandidates.push(baseNorm);
//     }

//     // Process each bracket
//     for (const bracketContent of brackets) {
//       if (isNumericCodeContent(bracketContent)) {
//         // Extract E-codes
//         const codes = extractCodesFromBracket(bracketContent);
//         codes.forEach(c => eCodes.add(c));
//         // Also check if the bracket has sub-names mixed with codes
//         // e.g. "(COLOUR 150d)" — "COLOUR" is a name candidate
//         const bracketWords = bracketContent.replace(/\d{3,4}[a-z]*/gi, "")
//           .replace(/[,()]/g, " ").trim();
//         if (bracketWords.length > 2) {
//           const bwNorm = toTitleCase(bracketWords.replace(/\s+/g, " "));
//           if (bwNorm.length > 2 && !NOISE_PATTERNS.some(p => p.test(bwNorm))) {
//             nameCandidates.push(bwNorm);
//           }
//         }
//       } else if (isDescriptiveBracket(bracketContent)) {
//         // "NATURAL FLAVOURING SUBSTANCES" — split on & and add each part
//         const parts = bracketContent.split(/[&+]/);
//         for (const part of parts) {
//           const p = toTitleCase(part.trim());
//           if (p.length > 2 && !NOISE_PATTERNS.some(p2 => p2.test(p))) {
//             nameCandidates.push(p);
//           }
//         }
//       }
//     }

//     // ── REGISTER CANDIDATES ───────────────────────────────
//     if (nameCandidates.length === 1) {
//       // Single candidate
//       candidateGroups.push(nameCandidates[0]);
//     } else if (nameCandidates.length > 1) {
//       // OR group — pipeline tries each in order, stops at first match
//       candidateGroups.push(nameCandidates);
//     }
//   }

//   return {
//     eCodes:          Array.from(eCodes),
//     candidateGroups, // array of (string | string[])
//   };
// }

// /* =========================================================
//    PUBLIC API
   
//    Returns:
//    {
//      eCodes: string[],          // "e330", "e211" etc
//      candidateGroups: (string | string[])[]
//        // Each entry is either a single name string,
//        // or an array of name strings to try in OR-order.
//        // e.g. ["Carbonated Water", "Sugar",
//        //        ["Flavours", "Natural Flavouring Substances"],
//        //        ["Acidity Regulators"]]
//    }
//    ========================================================= */
// export function extractIngredientsAndAdditives(rawText) {
//   const cleaned       = cleanOCRText(rawText);
//   const section       = isolateSection(cleaned);
//   const tokens        = splitIntoTokens(section || cleaned);
//   const { eCodes, candidateGroups } = classifyTokens(tokens);
//   return { eCodes, candidateGroups };
// }



/* =========================================================
   ingredientExtractor.service.js — v5.0

   RULES ADDED based on product label analysis:

   RULE 1: INS normalization
     "INS 296", "INS296", "ins296", "INS-296" → e296
     "INS 452(i)" → e452
     "INS 331(iii)" → e331

   RULE 2: E-code with space
     "E 460(i)", "E 330" → e460, e330

   RULE 3: Roman numeral qualifier stripping
     "331(iii)", "503(ii)", "341(i)" → 331, 503, 341

   RULE 4: Multiple codes same bracket with INS prefix
     "(INS 296, INS 331, INS 300)" → e296, e331, e300

   RULE 5: Sequestrant/category labels
     "SEQUESTRANTS (452(i), 385)" → e452, e385

   RULE 6: Percentage annotations
     "CAFFEINE (0.03%)" → "Caffeine" (ingredient, not additive)
     "CASHEW NUTS (4.5%)" → "Cashew Nuts"

   RULE 7: Vitamin annotations
     "VITAMINS (NIACIN, VITAMIN B6, VITAMIN B12)" →
       ["Niacin", "Vitamin B6", "Vitamin B12"] as name candidates

   RULE 8: Compound ingredient groups
     "MILK PRODUCTS (MILK SOLIDS & SWEETENED CONDENSED MILK)" →
       ["Milk Products", "Milk Solids"] as candidates

   RULE 9: Seasoning blocks
     "*SEASONING (...long block...)" → parse inner contents
     "++SEASONING (...)" → same

   RULE 10: "CONTAINS PERMITTED..." lines
     → Extract code from bracket, ignore text

   RULE 11: Percentage-only content in brackets
     "(0.03%)" "(4.5%)" → skip bracket, treat base as ingredient

   RULE 12: "COLOUR (CARAMEL E150D)" → extract E150d
   ========================================================= */

const MIN_E = 100;
const MAX_E = 1520;

/* =========================================================
   NOISE PATTERNS — lines/tokens definitely not ingredients
   ========================================================= */
const NOISE_PATTERNS = [
  /^may contain/i,
  /^contains no /i,
  /^allergen/i,
  /^allergy/i,
  /manufactured\s*(by|in)/i,
  /packed\s*(by|in)/i,
  /best before/i,
  /use before/i,
  /expiry/i,
  /net\s*wt/i,
  /net\s*weight/i,
  /serving size/i,
  /per\s*100\s*(ml|g)/i,
  /per\s*serve/i,
  /%\s*rda/i,
  /based on.*kcal/i,
  /approx.*val/i,
  /nutrition(al)?\s*(info|fact|value)/i,
  /^\s*energy\s*[\d]/i,
  /^\s*carbohydrate/i,
  /^\s*total fat/i,
  /^\s*protein\s*[\d]/i,
  /^\s*sodium\s*[\d]/i,
  /^\s*dietary\s*fib/i,
  /product of/i,
  /imported by/i,
  /distributed by/i,
  /marketed by/i,
  /fssai/i,
  /lic(ence|ense|\.)\s*no/i,
  /batch\s*no/i,
  /mfg\s*date/i,
  /^\s*vegetarian\s*$/i,
  /^\s*vegan\s*$/i,
  /^\s*halal\s*$/i,
  /^\s*kosher\s*$/i,
  /contains no fruit/i,
  /sweetened carbonated/i,
  /^\s*\d+(\.\d+)?\s*(ml|g|kg|l)\s*$/i,
  /^\s*\d+(\.\d+)?%\s*$/i,
  /contient\s*:/i,
  /ingr[eé]dients\s*:/i,
  /^\s*[a-z]{1,2}\s*$/i,
  /^\s*total sugars/i,
  /^\s*added sugars/i,
  /^\s*\*based on/i,
  /^\s*serving\s*=/i,
  /^\s*per\s*\d/i,
  /^\s*%rda/i,
  /^\s*\d+(\.\d+)?\s*kcal/i,
  /^\s*\d+(\.\d+)?\s*kj/i,
  /contains a source of/i,         // "Contains a Source of Phenylalanine"
  /numbers in brackets/i,           // "(Numbers in brackets as per INS)"
  /as per international/i,
  /as per ins/i,
  /store in/i,
  /transfer.*container/i,
  /once opened/i,
  /^\s*traces\s*:/i,
  /^\s*gluten\s*,/i,
  /lic\.\s*no\./i,
  /mfg unit/i,
  /for mfg/i,
];

/* =========================================================
   STOP SECTION PHRASES
   ========================================================= */
const STOP_PHRASES = [
  "allergen",
  "allergy advice",
  "may contain",
  "contains no",
  "nutrition information",
  "nutritional information",
  "nutrition facts",
  "nutritional value",
  "nutrition value",
  "manufactured by",
  "manufactured in",
  "packed by",
  "best before",
  "expiry date",
  "net weight",
  "net wt",
  "fssai",
  "customer care",
  "for more information",
  "contient :",
  "ingrédients :",
  "zutaten",
  "ingredienti",
  "nutrition information",
  "approximate values",
  "serving =",
  "per 100",
  "*based on",
  "contains wheat",              // allergen block
  "contains milk",
  "contains soy",
  "contains a source",
  "allergen advice",
  "allergen information",
  "numbers in brackets",         // label footnote
  "as per international numbering",
  "store in a",
];

/* =========================================================
   HEADER PATTERNS
   ========================================================= */
const HEADER_PATTERNS = [
  /ingredi[ea]nts?\s*:/i,
  /ingr[ei]di[ea]nts?\s*:/i,
  /lngredients?\s*:/i,
  /lngr[ei]di[ea]nts?\s*:/i,
  /composition\s*:/i,
  /made\s+with\s*:/i,
  /ingredi[ea]nts?\s*\n/i,
  /ingredi[ea]nts\s+include/i,
];

/* =========================================================
   CATEGORY LABELS — when these appear as base token with
   codes in brackets, treat codes as primary result
   ========================================================= */
const CATEGORY_LABELS = new Set([
  "acidity regulator", "acidity regulators",
  "stabilizer", "stabilizers", "stabiliser", "stabilisers",
  "preservative", "preservatives",
  "colour", "color", "colours", "colors",
  "permitted synthetic food colour",
  "contains permitted synthetic food colour",
  "synthetic food colour",
  "emulsifier", "emulsifiers",
  "antioxidant", "antioxidants",
  "thickener", "thickeners",
  "flavour", "flavours", "flavor", "flavors",
  "added flavours", "added flavors",
  "sweetener", "sweeteners",
  "humectant", "humectants",
  "raising agent", "raising agents",
  "firming agent", "firming agents",
  "anti-caking agent", "anti caking agent", "anticaking agent",
  "sequestrant", "sequestrants",
  "flour treatment agent", "flour treatment agents",
  "dough conditioner", "dough conditioners",
  "flavour enhancer", "flavour enhancers",
  "flavor enhancer", "flavor enhancers",
  "gelling agent", "gelling agents",
  "natural colour", "natural color",
  "natural flavour", "natural flavor",
  "vitamins",
  "minerals",
]);

/* =========================================================
   STEP 1 — OCR TEXT CLEANUP + LINE-JOIN HEALING
   ========================================================= */
function cleanOCRText(raw) {
  if (!raw) return "";

  let text = raw;
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");

  // Fix OCR confusion: l/I before 3-4 digits in E-code range → e
  text = text.replace(/\b[lI](\d{3,4}[a-z]?)\b/g, (match, n) => {
    const num = parseInt(n, 10);
    if (num >= MIN_E && num <= MAX_E) return `e${n}`;
    return match;
  });

  // Normalize "lns" → "ins"
  text = text.replace(/\b[lL][nN][sS]\b/g, "ins");

  // Remove asterisk prefixes from seasoning blocks: "*Seasoning" "++Seasoning"
  text = text.replace(/^[\*\+]+\s*/gm, "");

  // Normalize per-line whitespace
  const lines = text
    .split("\n")
    .map(line => line.trim().replace(/\s+/g, " "))
    .filter(Boolean);

  // ── LINE-JOIN HEALING ──────────────────────────────────
  const healed = [];
  for (let i = 0; i < lines.length; i++) {
    const cur  = lines[i];
    const prev = healed[healed.length - 1];

    if (!prev) { healed.push(cur); continue; }

    const prevEndsWithDelimiter = /[,\.;\u2022]\s*$/.test(prev);
    const prevEndsWithClose     = /\)\s*$/.test(prev);
    const curStartsNewSection   = HEADER_PATTERNS.some(p => p.test(cur));
    const curStartsAllCaps      = /^[A-Z][A-Z\s]{4,}:/.test(cur);

    const openCount  = (prev.match(/\(/g) || []).length;
    const closeCount = (prev.match(/\)/g) || []).length;
    const hasUnclosedBracket = openCount > closeCount;

    if (
      hasUnclosedBracket ||
      (!prevEndsWithDelimiter && !prevEndsWithClose &&
       !curStartsNewSection && !curStartsAllCaps)
    ) {
      healed[healed.length - 1] = prev + " " + cur;
    } else {
      healed.push(cur);
    }
  }

  return healed.join("\n").trim();
}

/* =========================================================
   STEP 2 — ISOLATE INGREDIENTS SECTION
   ========================================================= */
function isolateSection(text) {
  let headerEnd = -1;
  for (const pattern of HEADER_PATTERNS) {
    const match = text.match(pattern);
    if (match && match.index !== undefined) {
      headerEnd = match.index + match[0].length;
      break;
    }
  }

  if (headerEnd === -1) {
    const commas  = (text.match(/,/g)  || []).length;
    const bullets = (text.match(/•/g)  || []).length;
    if (commas > 2 || bullets > 2) headerEnd = 0;
    else return "";
  }

  let section = text.substring(headerEnd);
  const sectionLower = section.toLowerCase();
  let cutAt = section.length;

  for (const stop of STOP_PHRASES) {
    const idx = sectionLower.indexOf(stop);
    if (idx > 0 && idx < cutAt) cutAt = idx;
  }

  section = section.substring(0, cutAt).trim();
  section = section.replace(/\.\s*$/, "").trim();
  return section;
}

/* =========================================================
   STEP 3 — SMART SPLIT (respects bracket depth)
   ========================================================= */
function smartSplit(text) {
  const tokens = [];
  let depth = 0, current = "";

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (ch === "(" || ch === "[") { depth++; current += ch; }
    else if (ch === ")" || ch === "]") { depth = Math.max(0, depth - 1); current += ch; }
    else if (ch === "," && depth === 0) {
      const t = current.trim();
      if (t) tokens.push(t);
      current = "";
    } else { current += ch; }
  }
  const t = current.trim();
  if (t) tokens.push(t);
  return tokens;
}

function splitIntoTokens(section) {
  if (!section) return [];
  let text = section;
  text = text.replace(/•/g, ",");
  text = text.replace(/;/g, ",");
  text = text.split("\n").map(l => l.trim()).filter(Boolean).join(", ");
  text = text.replace(/,\s*,+/g, ",");
  return smartSplit(text).map(t => t.trim()).filter(Boolean);
}

/* =========================================================
   NORMALIZE INS/E CODE — RULE 1, 2, 3
   Handles all real-world label variants:
   "INS 296", "INS296", "INS-296", "INS 331(iii)",
   "E 330", "E330", "330", "331(iii)", "503(ii)"
   ========================================================= */
function normalizeToECode(raw) {
  let s = raw.toString().trim().toLowerCase();

  // Remove Roman numeral qualifiers in brackets: "331(iii)" → "331"
  // Also "503(ii)", "341(i)", "452(i)"
  s = s.replace(/\(([ivx]+)\)$/i, "");
  // Remove trailing Roman numerals without bracket: "331iii" → "331"
  s = s.replace(/([0-9])([ivx]+)$/i, "$1");

  // INS format: "ins 296", "ins296", "ins-296", "ins331(iii)"
  const insMatch = s.match(/^ins\s*[-:]?\s*(\d{3,4})/i);
  if (insMatch) {
    const n = parseInt(insMatch[1], 10);
    if (n >= MIN_E && n <= MAX_E) return `e${n}`;
  }

  // E-code with optional space: "e 330", "e330", "e150d"
  const eMatch = s.match(/^e\s*(\d{3,4})/i);
  if (eMatch) {
    const n = parseInt(eMatch[1], 10);
    if (n >= MIN_E && n <= MAX_E) return `e${n}`;
  }

  // Bare number: "330", "211"
  const bareMatch = s.match(/^(\d{3,4})$/);
  if (bareMatch) {
    const n = parseInt(bareMatch[1], 10);
    if (n >= MIN_E && n <= MAX_E) return `e${n}`;
  }

  return null;
}

/* =========================================================
   EXTRACT CODES FROM BRACKET CONTENT — RULES 1-5
   Handles: "(330, 331(iii))", "(INS 296, INS 331, INS 300)",
            "(452(i), 385)", "(Caramel E150d)"
   ========================================================= */
function extractCodesFromBracket(content) {
  const codes = [];

  // Special case: "Caramel E150d" — name + code in bracket
  // Extract the code part
  const embeddedCode = content.match(/\bE\s*(\d{3,4}[a-z]?)\b/i);
  if (embeddedCode) {
    const n = parseInt(embeddedCode[1], 10);
    if (n >= MIN_E && n <= MAX_E) codes.push(`e${n}`);
  }

  // Split on comma or & at top level
  const parts = smartSplit(content);

  for (let part of parts) {
    part = part.trim();
    if (!part) continue;
    const code = normalizeToECode(part);
    if (code) codes.push(code);
  }

  return [...new Set(codes)];
}

function isDescriptiveBracket(content) {
  // No 3-4 digit number → descriptive
  // Exception: if it has embedded E-code like "Caramel E150d"
  const hasNumericCode = /\b\d{3,4}\b/.test(content);
  const hasEmbeddedE   = /\bE\s*\d{3,4}/i.test(content);
  if (hasEmbeddedE) return false; // has code, not pure descriptive
  return !hasNumericCode;
}

function isPercentageOnlyBracket(content) {
  // "(0.03%)", "(4.5%)", "(29 mg/100 ml)"
  return /^\s*[\d.]+\s*(%|mg|g|ml|\/)\s*/.test(content.trim());
}

/* =========================================================
   STEP 4 — STRIP PERCENTAGE/QUANTITY PREFIX FROM TOKEN
   ========================================================= */
function stripQuantityPrefix(s) {
  return s
    .replace(/^(and\s+)?(less\s+than|more\s+than|at\s+least)?\s*\d+(\.\d+)?\s*%\s*(or\s+less\s+)?(of\s*:?\s*)?/i, "")
    .replace(/^\d+(\.\d+)?\s*%\s*(or\s+less\s+(of\s*)?:?\s*)?/i, "")
    .trim();
}

/* =========================================================
   UTILITY
   ========================================================= */
function toTitleCase(str) {
  return str.toLowerCase().replace(/\b\w/g, c => c.toUpperCase()).trim();
}

function isCategoryLabel(s) {
  return CATEGORY_LABELS.has(s.toLowerCase().trim());
}

/* =========================================================
   STEP 5 — CLASSIFY TOKENS
   Returns { eCodes[], candidateGroups[] }
   candidateGroups entries: string | string[] (OR groups)
   ========================================================= */
function classifyTokens(tokens) {
  const eCodes         = new Set();
  const candidateGroups = [];
  const seenNames      = new Set();

  function addCandidate(entry) {
    const key = Array.isArray(entry) ? entry.join("|") : entry;
    if (!seenNames.has(key)) {
      seenNames.add(key);
      candidateGroups.push(entry);
    }
  }

  for (let rawToken of tokens) {
    rawToken = rawToken.trim();
    if (!rawToken) continue;

    // ── NOISE CHECK ───────────────────────────────────────
    if (NOISE_PATTERNS.some(p => p.test(rawToken))) continue;

    // ── STRIP QUANTITY PREFIX ─────────────────────────────
    const deQuant = stripQuantityPrefix(rawToken);
    const working = deQuant || rawToken;

    if (/^\d+(\.\d+)?%?$/.test(working)) continue;
    if (working.length < 2) continue;

    // ── EXTRACT BRACKET CONTENTS ──────────────────────────
    const bracketRegex = /\(([^()]*(?:\([^()]*\)[^()]*)*)\)/g;
    const brackets = [];
    let bMatch;
    while ((bMatch = bracketRegex.exec(working)) !== null) {
      brackets.push(bMatch[1]);
    }

    // Base token with brackets removed
    const base     = working.replace(/\([^()]*(?:\([^()]*\)[^()]*)*\)/g, "").trim();
    const baseLower = base.toLowerCase().trim();
    const baseNorm  = toTitleCase(base);

    // ── DIRECT CODE IN BASE ───────────────────────────────
    const directCode = normalizeToECode(base);
    if (directCode) {
      eCodes.add(directCode);
      continue;
    }

    // ── PROCESS BRACKETS ──────────────────────────────────
    const nameCandidates = [];
    let foundCodesInBracket = false;

    for (const bracketContent of brackets) {

      // RULE 11: Percentage-only bracket → skip it, treat base as ingredient
      if (isPercentageOnlyBracket(bracketContent)) {
        continue; // will fall through to add base as name candidate
      }

      // RULE 10 / 12: Has embedded E-code like "Caramel E150d"
      const embeddedCode = bracketContent.match(/\bE\s*(\d{3,4}[a-z]?)\b/i);
      if (embeddedCode) {
        const n = parseInt(embeddedCode[1], 10);
        if (n >= MIN_E && n <= MAX_E) {
          eCodes.add(`e${n}`);
          foundCodesInBracket = true;
          // Also extract text name: "Caramel E150d" → "Caramel"
          const nameOnly = bracketContent.replace(/\bE\s*\d{3,4}[a-z]?\b/gi, "").trim();
          if (nameOnly.length > 2) nameCandidates.push(toTitleCase(nameOnly));
          continue;
        }
      }

      if (!isDescriptiveBracket(bracketContent)) {
        // Has numeric codes
        const codes = extractCodesFromBracket(bracketContent);
        if (codes.length > 0) {
          codes.forEach(c => eCodes.add(c));
          foundCodesInBracket = true;
        }
      } else {
        // RULE 7: Vitamin group — "VITAMINS (NIACIN, VITAMIN B6, VITAMIN B12)"
        // RULE 8: Compound group — "MILK PRODUCTS (MILK SOLIDS & CONDENSED MILK)"
        // Split descriptive bracket content and add each as candidate
        const parts = bracketContent.split(/[&,+]/);
        for (const part of parts) {
          const p = toTitleCase(part.trim());
          if (p.length > 2 && !NOISE_PATTERNS.some(np => np.test(p))) {
            nameCandidates.push(p);
          }
        }
      }
    }

    // ── BASE NAME HANDLING ────────────────────────────────
    if (baseLower.length > 2 && !NOISE_PATTERNS.some(p => p.test(baseLower))) {

      if (isCategoryLabel(baseLower) && foundCodesInBracket) {
        // Pure category label — codes extracted, also add label as candidate
        // (e.g. "ACIDITY REGULATORS" might match "Citric Acid" in DB)
        // But only add if it's a meaningful standalone term
        if (!["colour", "color", "colours", "flavour", "flavours",
              "preservative", "preservatives"].includes(baseLower)) {
          nameCandidates.unshift(baseNorm);
        }
      } else if (isCategoryLabel(baseLower) && nameCandidates.length > 0) {
        // Category with descriptive bracket — add both
        nameCandidates.unshift(baseNorm);
      } else {
        // Regular ingredient/additive name
        nameCandidates.unshift(baseNorm);
      }
    }

    // ── REGISTER CANDIDATES ───────────────────────────────
    if (nameCandidates.length === 1) {
      addCandidate(nameCandidates[0]);
    } else if (nameCandidates.length > 1) {
      addCandidate(nameCandidates); // OR group
    }
  }

  return {
    eCodes:          Array.from(eCodes),
    candidateGroups,
  };
}

/* =========================================================
   PUBLIC API
   ========================================================= */
export function extractIngredientsAndAdditives(rawText) {
  const cleaned  = cleanOCRText(rawText);
  const section  = isolateSection(cleaned);
  const tokens   = splitIntoTokens(section || cleaned);
  return classifyTokens(tokens);
}