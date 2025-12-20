List<String> normalizeForNOVA({
  required List<String> ingredients,
  required List<String> additives,
}) {
  final normalized = <String>[];

  // Clean ingredients
  for (var item in ingredients) {
    final clean = item.toLowerCase().trim();

    // Skip junk OCR tokens
    if (clean.length < 3) continue;
    if (clean == 'added') continue;
    if (clean == 'l-(') continue;

    // Fix common OCR truncations
    if (clean == 'gluco') {
      normalized.add('glucose');
      continue;
    }

    normalized.add(clean);
  }

  // Merge additives (VERY IMPORTANT)
  for (var add in additives) {
    normalized.add(add.toLowerCase().trim());
  }

  return normalized;
}
