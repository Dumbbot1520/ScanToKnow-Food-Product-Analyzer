import 'nova_database.dart';

String classifyNOVA(List<String> scannedItems) {
  final items = scannedItems.map((e) => e.toLowerCase().trim()).toList();

  // NOVA 4 – Ultra-processed
  bool hasNOVA4 = items.any((item) =>
      nova4List.any((novaItem) => item.contains(novaItem)));
  if (hasNOVA4) return "NOVA 4 – Ultra-Processed";

  // NOVA 3 – Processed
  bool hasNOVA3 = items.any((item) =>
      nova3List.any((novaItem) => item.contains(novaItem)));
  if (hasNOVA3) return "NOVA 3 – Processed";

  // NOVA 2 – Culinary ingredients
  bool hasNOVA2 = items.any((item) =>
      nova2List.any((novaItem) => item.contains(novaItem)));

  bool hasNOVA1 = items.any((item) =>
      nova1List.any((novaItem) => item.contains(novaItem)));

  if (hasNOVA2 && !hasNOVA1) {
    return "NOVA 2 – Culinary Ingredients";
  }

  // NOVA 1 – Unprocessed / minimal
  return "NOVA 1 – Unprocessed / Minimal";
}
