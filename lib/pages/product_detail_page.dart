// import 'package:flutter/material.dart';
//
// class ProductDetailPage extends StatelessWidget {
//   final Map<String, dynamic> productData;
//
//   const ProductDetailPage({Key? key, required this.productData})
//       : super(key: key);
//
//   // --------------------------- COLOR HELPERS ---------------------------
//   Color novaColor(int? nova) {
//     switch (nova) {
//       case 1:
//         return Colors.green.shade600;
//       case 2:
//         return Colors.lightGreen;
//       case 3:
//         return Colors.orange;
//       case 4:
//         return Colors.redAccent;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String novaDescription(int? nova) {
//     switch (nova) {
//       case 1:
//         return "Unprocessed or minimally processed";
//       case 2:
//         return "Processed culinary ingredients";
//       case 3:
//         return "Processed foods";
//       case 4:
//         return "Ultra-processed foods";
//       default:
//         return "No data available";
//     }
//   }
//
//   Color nutriColor(String? score) {
//     switch (score?.toUpperCase()) {
//       case "A":
//         return Colors.green.shade700;
//       case "B":
//         return Colors.green;
//       case "C":
//         return Colors.yellow.shade700;
//       case "D":
//         return Colors.orange;
//       case "E":
//         return Colors.redAccent;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String nutriDescription(String? score) {
//     switch (score?.toUpperCase()) {
//       case "A":
//         return "Excellent nutritional quality";
//       case "B":
//         return "Good nutritional quality";
//       case "C":
//         return "Moderate nutritional quality";
//       case "D":
//         return "Poor nutritional quality";
//       case "E":
//         return "Very poor nutritional quality";
//       default:
//         return "No NutriScore available";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product = productData['product'] ?? {};
//     final ingredients = productData['ingredients'] as List<dynamic>? ?? [];
//     final additives = productData['additives'] as List<dynamic>? ?? [];
//
//     final nutriScore = product['nutriscore']?.toString().toUpperCase();
//     final nova = product['nova_group'];
//
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(product['name'] ?? 'Product Detail'),
//         backgroundColor: Colors.orangeAccent,
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             //---------------------------- PRODUCT IMAGE CARD ----------------------------
//             Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Center(
//                   child: product['images'] != null &&
//                       product['images']['front'] != null
//                       ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       product['images']['front'],
//                       height: 220,
//                       fit: BoxFit.contain,
//                     ),
//                   )
//                       : Container(
//                     height: 200,
//                     alignment: Alignment.center,
//                     child: const Text("No Image Available"),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             //---------------------------- ROW OF SCORE BOXES ----------------------------
//             Row(
//               children: [
//                 // ---------------------------- NOVA BOX ----------------------------
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: novaColor(nova),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         Text("NOVA",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 6),
//                         Text(nova?.toString() ?? "-",
//                             style: const TextStyle(
//                                 fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 6),
//                         Text(novaDescription(nova),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(color: Colors.white, fontSize: 13)),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 // ---------------------------- NUTRISCORE BOX ----------------------------
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: nutriColor(nutriScore),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         Text("NutriScore",
//                             style: const TextStyle(
//                                 fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 6),
//                         Text(nutriScore ?? "-",
//                             style: const TextStyle(
//                                 fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 6),
//                         Text(nutriDescription(nutriScore),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(color: Colors.white, fontSize: 13)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 18),
//
//             //---------------------------- NEW: NOVA INFO DROPDOWN ----------------------------
//             ExpansionTile(
//               title: const Text(
//                 "What is NOVA?",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     "NOVA tells you how processed a food is.\n\n"
//                         "1 → Natural or minimally processed (fruits, milk, eggs)\n"
//                         "2 → Cooking ingredients (sugar, oils)\n"
//                         "3 → Processed foods (bread, cheese, canned veggies)\n"
//                         "4 → Ultra-processed foods (chips, soft drinks, instant noodles)\n\n"
//                         "Higher number = more processed, less healthy.",
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             //---------------------------- NEW: NUTRISCORE INFO DROPDOWN ----------------------------
//             ExpansionTile(
//               title: const Text(
//                 "What is Nutri-Score?",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     "Nutri-Score shows the overall healthiness of a food.\n\n"
//                         "A = Very healthy\n"
//                         "B = Healthy\n"
//                         "C = Moderate\n"
//                         "D = Less healthy\n"
//                         "E = Least healthy\n\n"
//                         "Based on sugar, salt, fats, calories, fibre, protein, and ingredients.",
//                     style: const TextStyle(fontSize: 15),
//                   ),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 22),
//
//             //---------------------------- BASIC INFO CARD ----------------------------
//             Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     InfoRow(label: "Brand", value: product['brands']),
//                     InfoRow(label: "Quantity", value: product['quantity']),
//                     InfoRow(label: "NutriScore", value: nutriScore),
//                     InfoRow(label: "Nova Group", value: nova?.toString()),
//                     if (product['labels'] != null &&
//                         (product['labels'] as List).isNotEmpty)
//                       InfoRow(
//                         label: "Labels",
//                         value: (product['labels'] as List).join(', '),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 22),
//
//             //---------------------------- INGREDIENTS SECTION ----------------------------
//             Text(
//               "Ingredients",
//               style: TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
//             ),
//
//             const SizedBox(height: 10),
//
//             if (ingredients.isEmpty) const Text("No ingredients available."),
//
//             ...ingredients.map(
//                   (i) => Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: ListTile(
//                   title: Text(
//                     i['name'] ?? '',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (i['description'] != null) Text(i['description'] ?? ''),
//                       if (i['health_note'] != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           "Health Note: ${i['health_note']}",
//                           style: const TextStyle(
//                               color: Colors.deepOrange, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ],
//                   ),
//                   trailing: Text(i['tag'] ?? ''),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 22),
//
//             //---------------------------- ADDITIVES SECTION ----------------------------
//             Text(
//               "Additives",
//               style: TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
//             ),
//
//             const SizedBox(height: 10),
//
//             if (additives.isEmpty) const Text("No additives available."),
//
//             ...additives.map(
//                   (a) => Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: ListTile(
//                   title: Text(
//                     a['name'] ?? a['code'] ?? '',
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Text(a['description'] ?? ''),
//                   trailing: Text(a['tag'] ?? ''),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// //---------------------------- SMALL REUSABLE ROW COMPONENT ----------------------------
// class InfoRow extends StatelessWidget {
//   final String label;
//   final String? value;
//
//   const InfoRow({super.key, required this.label, this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Text(
//             "$label:",
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value ?? "-",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:main_project_files/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({Key? key, required this.productData})
      : super(key: key);

  // --------------------------- COLOR HELPERS ---------------------------
  Color novaColor(int? nova) {
    switch (nova) {
      case 1:
        return Colors.green.shade600;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String novaDescription(int? nova) {
    switch (nova) {
      case 1:
        return "Unprocessed or minimally processed";
      case 2:
        return "Processed culinary ingredients";
      case 3:
        return "Processed foods";
      case 4:
        return "Ultra-processed foods";
      default:
        return "No data available";
    }
  }

  Color nutriColor(String? score) {
    switch (score?.toUpperCase()) {
      case "A":
        return Colors.green.shade700;
      case "B":
        return Colors.green;
      case "C":
        return Colors.yellow.shade700;
      case "D":
        return Colors.orange;
      case "E":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String nutriDescription(String? score) {
    switch (score?.toUpperCase()) {
      case "A":
        return "Excellent nutritional quality";
      case "B":
        return "Good nutritional quality";
      case "C":
        return "Moderate nutritional quality";
      case "D":
        return "Poor nutritional quality";
      case "E":
        return "Very poor nutritional quality";
      default:
        return "No NutriScore available";
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = productData['product'] ?? {};
    final ingredients = productData['ingredients'] as List<dynamic>? ?? [];
    final additives = productData['additives'] as List<dynamic>? ?? [];

    final nutriScore = product['nutriscore']?.toString().toUpperCase();
    final nova = product['nova_group'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Detail'),
        backgroundColor: Colors.orangeAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //---------------------------- PRODUCT IMAGE CARD ----------------------------
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: product['images'] != null &&
                      product['images']['front'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product['images']['front'],
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  )
                      : Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text("No Image Available"),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            //---------------------------- ROW OF SCORE BOXES ----------------------------
            Row(
              children: [
                // ---------------------------- NOVA BOX ----------------------------
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: novaColor(nova),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "NOVA",
                          style: TextStyle(
                              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nova?.toString() ?? "-",
                          style: const TextStyle(
                              fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          novaDescription(nova),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ---------------------------- NUTRISCORE BOX ----------------------------
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: nutriColor(nutriScore),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "NutriScore",
                          style: TextStyle(
                              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nutriScore ?? "-",
                          style: const TextStyle(
                              fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nutriDescription(nutriScore),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            //---------------------------- CLEAN NOVA INFO DROPDOWN ----------------------------
            ExpansionTile(
              title: const Text(
                "What is NOVA?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "NOVA shows how processed a food is:\n\n"
                        "• Group 1 → Natural or minimally processed (fruits, milk, eggs)\n"
                        "• Group 2 → Cooking ingredients (sugar, oils)\n"
                        "• Group 3 → Processed foods (bread, cheese, canned veggies)\n"
                        "• Group 4 → Ultra-processed foods (chips, soft drinks, instant noodles)\n\n"
                        "➡ Higher number = more processed and usually less healthy.",
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            //---------------------------- CLEAN NUTRISCORE INFO DROPDOWN ----------------------------
            ExpansionTile(
              title: const Text(
                "What is Nutri-Score?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Nutri-Score shows the overall healthiness of a food:\n\n"
                        "A → Very healthy\n"
                        "B → Healthy\n"
                        "C → Moderate\n"
                        "D → Less healthy\n"
                        "E → Least healthy\n\n"
                        "Based on sugar, salt, fats, calories, fibre, protein, and ingredients.",
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                )
              ],
            ),

            const SizedBox(height: 22),

            //---------------------------- BASIC INFO CARD ----------------------------
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(label: "Brand", value: product['brands']),
                    InfoRow(label: "Quantity", value: product['quantity']),
                    InfoRow(label: "NutriScore", value: nutriScore),
                    InfoRow(label: "Nova Group", value: nova?.toString()),
                    if (product['labels'] != null &&
                        (product['labels'] as List).isNotEmpty)
                      InfoRow(
                        label: "Labels",
                        value: (product['labels'] as List).join(', '),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            //---------------------------- INGREDIENTS SECTION ----------------------------
            Text(
              "Ingredients",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),

            const SizedBox(height: 10),

            if (ingredients.isEmpty) const Text("No ingredients available."),

            ...ingredients.map(
                  (i) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    i['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i['description'] != null) Text(i['description'] ?? ''),
                      if (i['health_note'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Health Note: ${i['health_note']}",
                          style: const TextStyle(
                              color: Colors.deepOrange, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                  trailing: Text(i['tag'] ?? ''),
                ),
              ),
            ),

            const SizedBox(height: 22),

            //---------------------------- ADDITIVES SECTION ----------------------------
            Text(
              "Additives",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),

            const SizedBox(height: 10),

            if (additives.isEmpty) const Text("No additives available."),

            ...additives.map(
                  (a) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    a['name'] ?? a['code'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(a['description'] ?? ''),
                  trailing: Text(a['tag'] ?? ''),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

//---------------------------- SMALL REUSABLE ROW COMPONENT ----------------------------
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

