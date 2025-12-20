import 'package:main_project_files/scan/ocr/nova_database.dart';

List<String> explainNOVA(List<String> scannedItems) {
  final items = scannedItems.map((e) => e.toLowerCase().trim()).toList();
  final reasons = <String>[];

  // ---------- NOVA 4 reasons ----------
  for (final item in items) {
    for (final ultra in nova4List) {
      if (item.contains(ultra)) {
        reasons.add("Contains ultra-processed ingredient ($ultra)");
      }
    }
  }

  if (reasons.isNotEmpty) return reasons;

  // ---------- NOVA 3 reasons ----------
  for (final item in items) {
    for (final p in nova3List) {
      if (item.contains(p)) {
        reasons.add("Processed food ingredient ($p)");
      }
    }
  }

  if (reasons.isNotEmpty) return reasons;

  // ---------- NOVA 2 reasons ----------
  for (final item in items) {
    for (final c in nova2List) {
      if (item.contains(c)) {
        reasons.add("Culinary ingredient ($c)");
      }
    }
  }

  if (reasons.isNotEmpty) return reasons;

  // ---------- NOVA 1 fallback ----------
  reasons.add("Only whole or minimally processed ingredients detected");
  return reasons;
}
