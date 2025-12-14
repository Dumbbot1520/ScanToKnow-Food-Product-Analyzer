// import 'text_cleaner.dart';
//
// class IngredientExtractor {
//   /// ============================================================
//   /// CONFIG
//   /// ============================================================
//   // Supported numeric range for E-codes (broad EU range)
//   static const int _minE = 100;
//   static const int _maxE = 1520;
//
//   // Context words that indicate a nearby number is an additive code
//   static final List<String> _contextWords = [
//     "preserv",
//     "regulator",
//     "acidity",
//     "stabilizer",
//     "emulsifier",
//     "color",
//     "colour",
//     "additive",
//     "antioxidant",
//     "agent",
//     "class",
//     "treatment",
//     "acid",
//     "ins",
//     "e"
//   ];
//
//   // Name-based additive map (common ones). You can expand this.
//   static final Map<String, String> _nameAdditives = {
//     "sorbic acid": "e200",
//     "potassium sorbate": "e202",
//     "sodium benzoate": "e211",
//     "benzoic acid": "e210",
//     "citric acid": "e330",
//     "sodium citrate": "e331",
//     "sucralose": "e955",
//     "riboflavin": "e101",
//     "maltodextrin": "e1400",
//     "ascorbic acid": "e300",
//     "calcium propionate": "e282",
//     "potassium sorbate": "e202",
//     "caramel": "e150",
//     "caramel color": "e150",
//     "monoglycerides": "e471",
//     "diglycerides": "e471",
//     "lecithin": "e322",
//     "sodium nitrite": "e250",
//     "sodium nitrate": "e251",
//   };
//
//   /// ============================================================
//   /// STEP 1 — Extract the "Ingredients" section with FUZZY MATCHING
//   /// ============================================================
//   static String extractIngredientsSection(String text) {
//     if (text.trim().isEmpty) return "";
//
//     String cleaned = TextCleaner.clean(text);
//     String lower = cleaned.toLowerCase();
//
//     final words = lower.split(RegExp(r'[\s,:;.]+'));
//     int startIndex = -1;
//
//     for (var w in words) {
//       if (_similar(w, "ingredient") >= 0.70) {
//         startIndex = lower.indexOf(w);
//         break;
//       }
//     }
//
//     if (startIndex == -1) return "";
//
//     String after = cleaned.substring(startIndex);
//
//     final stopWords = [
//       "nutrition",
//       "allergen",
//       "warning",
//       "expiry",
//       "manufact",
//     ];
//
//     int end = after.length;
//     for (var stop in stopWords) {
//       int idx = after.toLowerCase().indexOf(stop);
//       if (idx != -1 && idx < end) end = idx;
//     }
//
//     String section = after.substring(0, end).trim();
//
//     section = section.replaceAll(RegExp(r'ingredi\w*', caseSensitive: false), "");
//     section = section.replaceAll(":", "").trim();
//
//     return section.trim();
//   }
//
//   /// ============================================================
//   /// STEP 2 — Split ingredients on commas/newlines and clean items
//   /// ============================================================
//   static List<String> splitIngredients(String raw) {
//     if (raw.isEmpty) return [];
//
//     String text = raw.toLowerCase()
//         .replaceAll("\n", ",")
//         .replaceAll(";", ",")
//         .replaceAll(RegExp(r'\s+'), " ");
//
//     return text.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//   }
//
//   /// ============================================================
//   /// STEP 3 — Classify ingredients vs additives (HYBRID A2)
//   /// ============================================================
//   static Map<String, List<String>> classify(List<String> items) {
//     final Set<String> ingredients = {};
//     final Set<String> additives = {};
//
//     for (var rawItem in items) {
//       final s = rawItem.trim().toLowerCase();
//
//       // 1) Parentheses detection (e.g. "(e330)" or "(330)")
//       final p = _extractAdditiveFromParentheses(s);
//       if (p != null) {
//         additives.add(_finalizeCode(p));
//         continue;
//       }
//
//       // 2) INS detection (ins330)
//       final ins = _extractInsCode(s);
//       if (ins != null) {
//         additives.add(_finalizeCode(ins));
//         continue;
//       }
//
//       // 3) Direct messy E-candidate extraction (e200sorbic, e 330, e-330)
//       final candidate = _extractMessyECandidate(s);
//       if (candidate != null) {
//         final normalized = _normalizeCandidateToE(candidate);
//         final resolved = _resolveECodeHybrid(normalized, s);
//         if (resolved != null) {
//           additives.add(resolved);
//           continue;
//         }
//       }
//
//       // 4) Bare numeric additive with context (e.g., "preservative 282" or "(282)")
//       final numericContext = _detectBareNumberAdditive(s);
//       if (numericContext != null) {
//         additives.add(numericContext);
//         continue;
//       }
//
//       // 5) Name-based detection (citric acid → e330)
//       final name = _detectByName(s);
//       if (name != null) {
//         additives.add(name);
//         continue;
//       }
//
//       // Otherwise treat as ingredient text
//       ingredients.add(rawItem.trim());
//     }
//
//     return {
//       "ingredients": ingredients.toList(),
//       "additives": additives.toList(),
//     };
//   }
//
//   /// ============================================================
//   /// Detect additive inside parentheses, e.g. (e338) or (330)
//   /// ============================================================
//   static String? _extractAdditiveFromParentheses(String s) {
//     // (e330), (330), (E330), ( 330 )
//     final match = RegExp(r'\(\s*(e?\d{2,4}[a-z]?)\s*\)', caseSensitive: false).firstMatch(s);
//     if (match != null) {
//       var code = match.group(1)!.toLowerCase();
//       // If it lacks 'e' prefix, add it
//       if (!code.startsWith('e')) code = 'e' + code;
//       return code;
//     }
//     return null;
//   }
//
//   /// ============================================================
//   /// Extract INS codes like "ins330" or "ins 330"
//   /// ============================================================
//   static String? _extractInsCode(String s) {
//     final match = RegExp(r'ins\s*[-:]?\s*(\d{2,4}[a-z]?)', caseSensitive: false).firstMatch(s);
//     if (match != null) {
//       return 'e' + match.group(1)!.toLowerCase();
//     }
//     return null;
//   }
//
//   /// ============================================================
//   /// Extract any messy E-candidate: e200sorbic, e 330, e-330, e33o
//   /// Returns the raw candidate string (may contain chars)
//   /// ============================================================
//   static String? _extractMessyECandidate(String s) {
//     // Try to find tokens that start with 'e' + mixed chars/digits
//     // or patterns like 'e 2 3 0' collapsed
//     final match = RegExp(r'\be[\d\w\-\s]{1,8}\b', caseSensitive: false).firstMatch(s);
//     if (match != null) {
//       return match.group(0);
//     }
//     return null;
//   }
//
//   /// ============================================================
//   /// Normalize candidate to a more digit-focused 'e###' or 'e####' string
//   /// Fix common OCR mistakes (o->0, l->1), remove hyphens/spaces
//   /// ============================================================
//   static String _normalizeCandidateToE(String candidate) {
//     String c = candidate.toLowerCase();
//     c = c.replaceAll(RegExp(r'[^\da-z]'), ''); // remove hyphens/spaces/punct
//     // common OCR fixes
//     c = c.replaceAll('o', '0'); // letter O -> zero
//     c = c.replaceAll('l', '1'); // letter l -> 1
//     c = c.replaceAll('i', '1'); // sometimes i -> 1
//     c = c.replaceAll('s', '5'); // optionally but careful; we won't rely solely on this
//     // Extract digits
//     final digitMatch = RegExp(r'(\d{2,4})').firstMatch(c);
//     if (digitMatch != null) {
//       String digits = digitMatch.group(1)!;
//       // If it is 2 digits (rare), keep as-is; we'll try matching numerically
//       return 'e' + digits;
//     }
//     // fallback: return cleaned candidate
//     return c;
//   }
//
//   /// ============================================================
//   /// Resolve normalized candidate to a final E-code using HYBRID logic:
//   /// 1) If normalized exists within supported numeric range, accept eNNN
//   /// 2) If candidate isn't numeric, try to extract digits and apply numeric mapping
//   /// 3) As a fallback, use numeric proximity (closest numeric code)
//   /// ============================================================
//   static String? _resolveECodeHybrid(String normalizedCandidate, String originalItem) {
//     // normalizedCandidate ideally looks like 'e330' or 'e150d' or 'e1400'
//     final lower = normalizedCandidate.toLowerCase();
//
//     // If it starts with 'e' followed by digits
//     final dMatch = RegExp(r'e(\d{2,4})').firstMatch(lower);
//     if (dMatch != null) {
//       int parsed = int.parse(dMatch.group(1)!);
//
//       // If parsed within supported range, accept directly (A2 prefers numeric mapping)
//       if (parsed >= _minE && parsed <= _maxE) {
//         return 'e$parsed';
//       }
//
//       // If parsed smaller (like 30, 50) but context suggests additive, map via proximity
//       if (_hasAdditiveContext(originalItem)) {
//         final prox = _closestNumericE(parsed);
//         return 'e$prox';
//       }
//     }
//
//     // If normalizedCandidate didn't produce digits, try to extract any digits from originalItem
//     final digits = RegExp(r'(\d{2,4})').firstMatch(originalItem)?.group(1);
//     if (digits != null) {
//       final parsed = int.parse(digits);
//       if (parsed >= _minE && parsed <= _maxE) return 'e$parsed';
//       if (_hasAdditiveContext(originalItem)) {
//         final prox = _closestNumericE(parsed);
//         return 'e$prox';
//       }
//     }
//
//     // No resolution
//     return null;
//   }
//
//   /// ============================================================
//   /// Detect bare numeric additive when context words present:
//   /// e.g., "preservative 282", "antioxidant 300"
//   /// ============================================================
//   static String? _detectBareNumberAdditive(String s) {
//     final match = RegExp(r'\b(\d{2,4})\b').firstMatch(s);
//     if (match == null) return null;
//     final digits = int.parse(match.group(1)!);
//
//     // If digits fall into supported range and context present -> accept
//     if (digits >= _minE && digits <= _maxE && _hasAdditiveContext(s)) {
//       return 'e$digits';
//     }
//
//     return null;
//   }
//
//   /// ============================================================
//   /// Determine if a string contains additive-related context words
//   /// ============================================================
//   static bool _hasAdditiveContext(String s) {
//     final lower = s.toLowerCase();
//     for (var kw in _contextWords) {
//       if (lower.contains(kw)) return true;
//     }
//     return false;
//   }
//
//   /// ============================================================
//   /// Find the closest numeric E-code between min and max (by absolute diff)
//   /// ============================================================
//   static int _closestNumericE(int x) {
//     if (x <= _minE) return _minE;
//     if (x >= _maxE) return _maxE;
//     // For A2 hybrid we simply return the number clamped into range
//     // but attempt to find a sensible 3-digit if x too large by modulo
//     if (x >= 100 && x <= 999) return x;
//     // if x is 4-digit, try to reduce to 3-digit by modulo 1000 if in range
//     int reduced = x % 1000;
//     if (reduced >= _minE && reduced <= 999) return reduced;
//     // fallback: clamp to min
//     return _minE;
//   }
//
//   /// ============================================================
//   /// Name-based detection (chemical names → E-codes)
//   /// ============================================================
//   static String? _detectByName(String item) {
//     final text = item.toLowerCase();
//     for (var entry in _nameAdditives.entries) {
//       if (text.contains(entry.key)) return entry.value;
//     }
//     return null;
//   }
//
//   /// ============================================================
//   /// Final normalization: ensure lowercase 'e###' format,
//   /// remove duplicates etc.
//   /// ============================================================
//   static String _finalizeCode(String code) {
//     var c = code.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
//     if (!c.startsWith('e') && RegExp(r'^\d{2,4}$').hasMatch(c)) c = 'e' + c;
//     // Ensure digits only after e
//     final match = RegExp(r'e(\d{2,4})').firstMatch(c);
//     if (match != null) {
//       return 'e' + match.group(1)!;
//     }
//     return c;
//   }
//
//   /// ============================================================
//   /// Simple similarity for fuzzy header detection
//   /// ============================================================
//   static double _similar(String a, String b) {
//     if (a.isEmpty || b.isEmpty) return 0;
//     int matches = 0;
//     int len = a.length < b.length ? a.length : b.length;
//     for (int i = 0; i < len; i++) {
//       if (a[i] == b[i]) matches++;
//     }
//     return matches / b.length;
//   }
// }


import 'package:main_project_files/scan/ocr/text_cleaner.dart';


class IngredientExtractor {
  /// ============================================================
  /// CONFIG
  /// ============================================================
  static const int _minE = 100;
  static const int _maxE = 1520;

  static final List<String> _contextWords = [
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

  static final Map<String, String> _nameAdditives = {
    "sorbic acid": "e200",
    "benzoic acid": "e210",
    "citric acid": "e330",
    "sodium citrate": "e331",
    "sodium citrates": "e331",
    "ascorbic acid": "e300",
    "riboflavin": "e101",
    "sucralose": "e955",
    "acesulfame potassium": "e950",
    "calcium propionate": "e282",
    "monoglyceride": "e471",
    "diglyceride": "e471",
    "lecithin": "e322",
  };

  /// ============================================================
  /// STEP 1 — Extract the actual ingredient section
  /// ============================================================
  static String extractIngredientsSection(String text) {
    if (text.trim().isEmpty) return "";

    String cleaned = TextCleaner.clean(text);
    String lower = cleaned.toLowerCase();

    final words = lower.split(RegExp(r'[\s,:;.]+'));
    int startIndex = -1;

    for (var w in words) {
      if (_similar(w, "ingredient") >= 0.70) {
        startIndex = lower.indexOf(w);
        break;
      }
    }

    if (startIndex == -1) return "";

    String after = cleaned.substring(startIndex);

    final stopWords = ["nutrition", "allergen", "warning", "expiry", "manufact"];
    int end = after.length;

    for (var stop in stopWords) {
      int idx = after.toLowerCase().indexOf(stop);
      if (idx != -1 && idx < end) end = idx;
    }

    String section = after.substring(0, end).trim();
    section = section.replaceAll(RegExp(r'ingredi\w*', caseSensitive: false), "");
    section = section.replaceAll(":", "").trim();

    return section;
  }

  /// ============================================================
  /// STEP 2 — Split into usable items
  /// ============================================================
  static List<String> splitIngredients(String raw) {
    if (raw.isEmpty) return [];

    String text = raw
        .toLowerCase()
        .replaceAll("\n", ",")
        .replaceAll(";", ",")
        .replaceAll(RegExp(r'\s+'), " ");

    return text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// ============================================================
  /// STEP 3 — Classify ingredients vs additives
  /// ============================================================
  static Map<String, List<String>> classify(List<String> items) {
    final Set<String> ingredients = {};
    final Set<String> additives = {};

    for (String rawItem in items) {
      String s = rawItem.trim().toLowerCase();

      // 1. Parentheses (330), (150d), (e330)
      final p = _extractParenthesisAdditive(s);
      if (p != null) {
        additives.add(_finalizeCode(p));
        continue;
      }

      // 2. INS codes (ins330)
      final ins = _extractInsCode(s);
      if (ins != null) {
        additives.add(_finalizeCode(ins));
        continue;
      }

      // 3. Messy E-code candidate (e150d, e-150d, e 150 d, e150dcaramel)
      final messy = _extractMessyECandidate(s);
      if (messy != null) {
        final normalized = _normalizeCandidate(messy);
        final resolved = _resolveHybrid(normalized, s);
        if (resolved != null) {
          additives.add(resolved);
          continue;
        }
      }

      // 4. Bare number with context: “preservative 282”
      final numeric = _detectBareNumberAdditive(s);
      if (numeric != null) {
        additives.add(numeric);
        continue;
      }

      // 5. Name-based additive matching
      final name = _detectByName(s);
      if (name != null) {
        additives.add(name);
        continue;
      }

      // If nothing matched: treat as ingredient
      ingredients.add(rawItem.trim());
    }

    return {
      "ingredients": ingredients.toList(),
      "additives": additives.toList(),
    };
  }

  /// ============================================================
  /// PARENTHESIS PARSING
  /// ============================================================
  static String? _extractParenthesisAdditive(String s) {
    final match =
    RegExp(r'\(\s*(e?\d{3,4}[a-z]?)\s*\)', caseSensitive: false).firstMatch(s);

    if (match == null) return null;

    String code = match.group(1)!.toLowerCase();

    // IGNORE incomplete codes like (33)
    final digits = code.replaceAll("e", "");
    if (digits.length < 3) return null;

    if (!code.startsWith("e")) code = "e$code";
    return code;
  }

  /// ============================================================
  /// INS CODE PARSER
  /// ============================================================
  static String? _extractInsCode(String s) {
    final match =
    RegExp(r'ins\s*[-:]?\s*(\d{3,4}[a-z]?)', caseSensitive: false).firstMatch(s);
    if (match != null) {
      return "e${match.group(1)!.toLowerCase()}";
    }
    return null;
  }

  /// ============================================================
  /// EXTRACT MESSY E-CANDIDATE
  /// ============================================================
  static String? _extractMessyECandidate(String s) {
    final match =
    RegExp(r'\be[\da-z\-\s]{1,10}\b', caseSensitive: false).firstMatch(s);
    return match?.group(0);
  }

  /// ============================================================
  /// NORMALIZE CANDIDATE (remove OCR noise)
  /// ============================================================
  static String _normalizeCandidate(String candidate) {
    String c = candidate.toLowerCase();
    c = c.replaceAll(RegExp(r'[^\da-z]'), "");
    c = c.replaceAll("o", "0");
    c = c.replaceAll("l", "1");

    final match = RegExp(r'(\d{3,4}[a-z]?)').firstMatch(c);
    if (match != null) return "e${match.group(1)!}";

    return "e";
  }

  /// ============================================================
  /// RESOLVE NORMALIZED CODE → FINAL CODE
  /// ============================================================
  static String? _resolveHybrid(String normalized, String original) {
    final match = RegExp(r'e(\d{3,4})([a-z]?)').firstMatch(normalized);
    if (match == null) return null;

    int number = int.parse(match.group(1)!);
    String letter = match.group(2)!;

    if (number >= _minE && number <= _maxE) {
      return letter.isEmpty ? "e$number" : "e$number$letter";
    }

    // Try fallback: extract digits from original text
    final origNum = RegExp(r'(\d{3,4})').firstMatch(original)?.group(1);
    if (origNum != null) {
      int n = int.parse(origNum);
      if (n >= _minE && n <= _maxE) return "e$n";
    }

    return null;
  }

  /// ============================================================
  /// DETECT BARE NUMBER + CONTEXT (“preservative 282”)
  /// ============================================================
  static String? _detectBareNumberAdditive(String s) {
    final match = RegExp(r'\b(\d{3,4})\b').firstMatch(s);
    if (match == null) return null;

    int n = int.parse(match.group(1)!);
    if (n >= _minE && n <= _maxE && _hasAdditiveContext(s)) {
      return "e$n";
    }
    return null;
  }

  /// ============================================================
  /// NAME-BASED MATCHING (chemical ingredient → E-code)
  /// ============================================================
  static String? _detectByName(String s) {
    for (final entry in _nameAdditives.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// ============================================================
  /// CONTEXT CHECKER
  /// ============================================================
  static bool _hasAdditiveContext(String s) {
    for (var word in _contextWords) {
      if (s.contains(word)) return true;
    }
    return false;
  }

  /// ============================================================
  /// FINAL NORMALIZER
  /// ============================================================
  static String _finalizeCode(String code) {
    code = code.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), "");
    final m = RegExp(r'e(\d{3,4}[a-z]?)').firstMatch(code);
    return m != null ? "e${m.group(1)!}" : code;
  }

  /// ============================================================
  /// SIMPLE FUZZY MATCHER
  /// ============================================================
  static double _similar(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    int len = a.length < b.length ? a.length : b.length;
    int score = 0;
    for (int i = 0; i < len; i++) {
      if (a[i] == b[i]) score++;
    }
    return score / b.length;
  }
}
