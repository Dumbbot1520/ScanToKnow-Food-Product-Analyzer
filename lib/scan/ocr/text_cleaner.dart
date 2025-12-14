// lib/utils/text_cleaner.dart
class TextCleaner {
  /// SAFER cleaning — keeps structure, commas, line breaks
  static String clean(String text) {
    if (text.isEmpty) return "";

    String cleaned = text;

    // Lowercase for consistent matching
    cleaned = cleaned.toLowerCase();

    // KEEP parentheses because additives are inside them (e338)
    // Remove weird OCR characters but DO NOT remove () or letters inside them
    cleaned = cleaned.replaceAll(RegExp(r'[^\na-z0-9,().:; -]'), '');

    // Normalize spacing line by line
    cleaned = cleaned
        .split("\n")
        .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
        .join("\n");

    // Normalize comma spacing
    cleaned = cleaned.replaceAll(RegExp(r'\s*,\s*'), ', ');

    return cleaned.trim();
  }

  /// Extracts letters + numbers only
  static String lettersOnly(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '').trim();
  }

  /// Remove repeated words caused by OCR duplication.
  static String removeDuplicateWords(String text) {
    final words = text.split(" ");
    final uniqueWords = <String>{};
    final buffer = StringBuffer();

    for (final word in words) {
      if (!uniqueWords.contains(word)) {
        uniqueWords.add(word);
        buffer.write("$word ");
      }
    }

    return buffer.toString().trim();
  }

  /// Normalize ingredient names for DB matching
  static String normalizeIngredient(String ing) {
    String out = ing.toLowerCase().trim();

    // IMPORTANT — Do NOT remove parentheses, they may contain additives
    // Remove only trailing punctuation
    out = out.replaceAll(RegExp(r'[.,;:]$'), '').trim();

    return out;
  }
}
