//
// import 'package:flutter/material.dart';
// import 'package:main_project_files/utils/nova_input_normalizer.dart';
// import 'package:main_project_files/scan/ocr/nova_classifier.dart';
// import 'package:main_project_files/utils/nova_explainer.dart';
//
// class OCRProductDetailPage extends StatelessWidget {
//   final List<dynamic> ingredients;
//   final List<dynamic> additives;
//   final int? novaScore;
//
//   const OCRProductDetailPage({
//     super.key,
//     required this.ingredients,
//     required this.additives,
//     this.novaScore,
//   });
//
//   Color tagColor(String? tag) {
//     if (tag == null) return Colors.grey;
//     switch (tag) {
//       case "🟢":
//         return Colors.green;
//       case "🟠":
//         return Colors.orange;
//       case "🔴":
//         return Colors.redAccent;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   Color overallRiskColor(int safe, int caution, int harmful) {
//     if (harmful > 0) return Colors.redAccent;
//     if (caution > safe) return Colors.orange;
//     return Colors.green;
//   }
//
//   String summaryMessage(int safe, int caution, int harmful) {
//     if (harmful > 0) {
//       return "Contains harmful additives/ingredients. Consume cautiously.";
//     }
//     if (caution > safe) {
//       return "Contains cautionary ingredients. Moderate consumption advised.";
//     }
//     return "Mostly safe ingredients. Good overall profile.";
//   }
//
//   String novaScoreText(int group) {
//     switch (group) {
//       case 1:
//         return "(Unprocessed / Minimally Processed)";
//       case 2:
//         return "(Processed Culinary Ingredient)";
//       case 3:
//         return "(Processed)";
//       case 4:
//         return "(Ultra-Processed)";
//       default:
//         return "";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // -------------------- OCR DATA CHECK --------------------
//     final ingredientNames = ingredients
//         .map((i) => i['name']?.toString() ?? '')
//         .where((e) => e.isNotEmpty)
//         .toList();
//
//     final additiveCodes = additives
//         .map((a) => a['code']?.toString() ?? a['name']?.toString() ?? '')
//         .where((e) => e.isNotEmpty)
//         .toList();
//
//     final bool hasOCRData =
//         ingredientNames.isNotEmpty || additiveCodes.isNotEmpty;
//
//     // -------------------- NOVA COMPUTATION (OCR SAFE) --------------------
//     int? computedNovaScore;
//     List<String> novaReasons = [];
//
//     if (hasOCRData) {
//       final novaInput = normalizeForNOVA(
//         ingredients: ingredientNames,
//         additives: additiveCodes,
//       );
//
//       final computedNovaLabel = classifyNOVA(novaInput);
//       novaReasons = explainNOVA(novaInput);
//
//       if (computedNovaLabel.contains('NOVA 1')) {
//         computedNovaScore = 1;
//       } else if (computedNovaLabel.contains('NOVA 2')) {
//         computedNovaScore = 2;
//       } else if (computedNovaLabel.contains('NOVA 3')) {
//         computedNovaScore = 3;
//       } else if (computedNovaLabel.contains('NOVA 4')) {
//         computedNovaScore = 4;
//       }
//
//       debugPrint("NOVA INPUT (OCR): $novaInput");
//       debugPrint("NOVA RESULT: $computedNovaLabel");
//       debugPrint("NOVA REASONS: $novaReasons");
//     } else {
//       debugPrint("⚠ NOVA skipped: No OCR data detected");
//     }
//
//     // -------------------- RISK COUNTS --------------------
//     int safeCount = ingredients.where((i) => i["tag"] == "🟢").length +
//         additives.where((a) => a["tag"] == "🟢").length;
//
//     int cautionCount = ingredients.where((i) => i["tag"] == "🟠").length +
//         additives.where((a) => a["tag"] == "🟠").length;
//
//     int harmfulCount = ingredients.where((i) => i["tag"] == "🔴").length +
//         additives.where((a) => a["tag"] == "🔴").length;
//
//     Color headerColor =
//     overallRiskColor(safeCount, cautionCount, harmfulCount);
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Ingredients & Additives"),
//         backgroundColor: Colors.orangeAccent,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // -------------------- SUMMARY --------------------
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: headerColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Summary",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Ingredients detected: ${ingredients.length}",
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   Text(
//                     "Additives detected: ${additives.length}",
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   if (computedNovaScore != null) ...[
//                     const SizedBox(height: 6),
//                     Text(
//                       "NOVA Group: $computedNovaScore ${novaScoreText(computedNovaScore!)}",
//                       style:
//                       const TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("🟢 Safe: $safeCount",
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 16)),
//                       Text("🟠 Caution: $cautionCount",
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 16)),
//                       Text("🔴 Harmful: $harmfulCount",
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 16)),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     summaryMessage(safeCount, cautionCount, harmfulCount),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 25),
//
//             // -------------------- INGREDIENTS --------------------
//             Text("Ingredients",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orangeAccent)),
//             const SizedBox(height: 10),
//             if (ingredients.isEmpty)
//               const Text("No ingredients detected."),
//             ...ingredients.map((i) => Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: tagColor(i["tag"]),
//                   child: Text(i["tag"] ?? "",
//                       style: const TextStyle(fontSize: 22)),
//                 ),
//                 title: Text(i['name'] ?? '',
//                     style:
//                     const TextStyle(fontWeight: FontWeight.w600)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (i['description'] != null)
//                       Text(i['description']),
//                     if (i['health_note'] != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         "Health Note: ${i['health_note']}",
//                         style: const TextStyle(
//                             color: Colors.deepOrange,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             )),
//
//             const SizedBox(height: 25),
//
//             // -------------------- ADDITIVES --------------------
//             Text("Additives",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.redAccent)),
//             const SizedBox(height: 10),
//             if (additives.isEmpty) const Text("No additives detected."),
//             ...additives.map((a) => Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: tagColor(a["tag"]),
//                   child: Text(a["tag"] ?? "",
//                       style: const TextStyle(fontSize: 22)),
//                 ),
//                 title: Text(
//                   a['code'] != null && a['name'] != null
//                       ? "${a['code'].toString().toUpperCase()} – ${a['name']}"
//                       : a['name'] ?? a['code'] ?? "",
//                   style:
//                   const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(a['description'] ?? ''),
//                     if (a['health_note'] != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         "Health Note: ${a['health_note']}",
//                         style: const TextStyle(
//                             color: Colors.deepOrange,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             )),
//
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:main_project_files/utils/nova_input_normalizer.dart';
import 'package:main_project_files/scan/ocr/nova_classifier.dart';
import 'package:main_project_files/utils/nova_explainer.dart';

class OCRProductDetailPage extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> additives;
  final int? novaScore;

  const OCRProductDetailPage({
    super.key,
    required this.ingredients,
    required this.additives,
    this.novaScore,
  });

  Color tagColor(String? tag) {
    if (tag == null) return Colors.grey;
    switch (tag) {
      case "🟢":
        return Colors.green;
      case "🟠":
        return Colors.orange;
      case "🔴":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String novaScoreText(int group) {
    switch (group) {
      case 1:
        return "NOVA 1 – Unprocessed or Minimally Processed";
      case 2:
        return "NOVA 2 – Processed Culinary Ingredient";
      case 3:
        return "NOVA 3 – Processed Food";
      case 4:
        return "NOVA 4 – Ultra-Processed";
      default:
        return "";
    }
  }

  Color novaColor(int group) {
    switch (group) {
      case 1:
        return Colors.green.shade600;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange.shade600;
      case 4:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // -------------------- OCR DATA --------------------
    final ingredientNames = ingredients
        .map((i) => i['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final additiveCodes = additives
        .map((a) => a['code']?.toString() ?? a['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final bool hasOCRData =
        ingredientNames.isNotEmpty || additiveCodes.isNotEmpty;

    // -------------------- NOVA COMPUTATION --------------------
    int? computedNovaScore;
    List<String> novaReasons = [];

    if (hasOCRData) {
      final novaInput = normalizeForNOVA(
        ingredients: ingredientNames,
        additives: additiveCodes,
      );

      final label = classifyNOVA(novaInput);
      novaReasons = explainNOVA(novaInput);

      if (label.contains('NOVA 1')) computedNovaScore = 1;
      else if (label.contains('NOVA 2')) computedNovaScore = 2;
      else if (label.contains('NOVA 3')) computedNovaScore = 3;
      else if (label.contains('NOVA 4')) computedNovaScore = 4;

      debugPrint("NOVA INPUT: $novaInput");
      debugPrint("NOVA SCORE: $computedNovaScore");
      debugPrint("NOVA REASONS: $novaReasons");
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ingredients & Additives"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= NOVA VERDICT CARD =================
            if (computedNovaScore != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: novaColor(computedNovaScore!),
                    width: 2,
                  ),
                  color: novaColor(computedNovaScore!).withOpacity(0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "NOVA Classification",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      novaScoreText(computedNovaScore!),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: novaColor(computedNovaScore!),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Why this product falls into this group:",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...novaReasons.map(
                          (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ",
                                style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "NOVA classification reflects the level of industrial processing, not nutrition quality.",
                      style:
                      TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // ================= INGREDIENTS =================
            Text(
              "Ingredients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 10),
            if (ingredients.isEmpty)
              const Text("No ingredients detected."),
            ...ingredients.map((i) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tagColor(i["tag"]),
                  child: Text(i["tag"] ?? "",
                      style: const TextStyle(fontSize: 22)),
                ),
                title: Text(i['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                subtitle: i['description'] != null
                    ? Text(i['description'])
                    : null,
              ),
            )),

            const SizedBox(height: 25),

            // ================= ADDITIVES =================
            Text(
              "Additives",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            if (additives.isEmpty)
              const Text("No additives detected."),
            ...additives.map((a) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tagColor(a["tag"]),
                  child: Text(a["tag"] ?? "",
                      style: const TextStyle(fontSize: 22)),
                ),
                title: Text(
                  a['code'] != null && a['name'] != null
                      ? "${a['code'].toString().toUpperCase()} – ${a['name']}"
                      : a['name'] ?? a['code'] ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600),
                ),
                subtitle: a['description'] != null
                    ? Text(a['description'])
                    : null,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

