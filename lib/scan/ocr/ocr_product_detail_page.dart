import 'package:flutter/material.dart';


class OCRProductDetailPage extends StatelessWidget {
  final List<dynamic> ingredients;
  final List<dynamic> additives;

  const OCRProductDetailPage({
    super.key,
    required this.ingredients,
    required this.additives,
  });

  // --------------------------------------------------------------
  // TAG COLOR LOGIC
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // SUMMARY COLOR (HEADER BAR)
  // --------------------------------------------------------------
  Color overallRiskColor(int safe, int caution, int harmful) {
    if (harmful > 0) return Colors.redAccent;
    if (caution > safe) return Colors.orange;
    return Colors.green;
  }

  // --------------------------------------------------------------
  // SUMMARY MESSAGE
  // --------------------------------------------------------------
  String summaryMessage(int safe, int caution, int harmful) {
    if (harmful > 0) {
      return "Contains harmful additives/ingredients. Consume cautiously.";
    }
    if (caution > safe) {
      return "Contains cautionary ingredients. Moderate consumption advised.";
    }
    return "Mostly safe ingredients. Good overall profile.";
  }

  @override
  Widget build(BuildContext context) {
    // COUNTING TAGS
    int safeCount = ingredients.where((i) => i["tag"] == "🟢").length +
        additives.where((a) => a["tag"] == "🟢").length;

    int cautionCount = ingredients.where((i) => i["tag"] == "🟠").length +
        additives.where((a) => a["tag"] == "🟠").length;

    int harmfulCount = ingredients.where((i) => i["tag"] == "🔴").length +
        additives.where((a) => a["tag"] == "🔴").length;

    Color headerColor =
    overallRiskColor(safeCount, cautionCount, harmfulCount);

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

            // --------------------------------------------------------------
            // SUMMARY CARD
            // --------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Ingredients detected: ${ingredients.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Additives detected: ${additives.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("🟢 Safe: $safeCount",
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text("🟠 Caution: $cautionCount",
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                      Text("🔴 Harmful: $harmfulCount",
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    summaryMessage(safeCount, cautionCount, harmfulCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --------------------------------------------------------------
            // INGREDIENTS SECTION
            // --------------------------------------------------------------
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

            ...ingredients.map((i) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tagColor(i["tag"]),
                    child: Text(i["tag"] ?? "", style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(
                    i['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i['description'] != null)
                        Text(i['description']),
                      if (i['health_note'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Health Note: ${i['health_note']}",
                          style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 25),

            // --------------------------------------------------------------
            // ADDITIVES SECTION
            // --------------------------------------------------------------
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

            ...additives.map((a) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tagColor(a["tag"]),
                    child: Text(a["tag"] ?? "", style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text(
                    a['name'] ?? a['code'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['description'] ?? ''),
                      if (a['health_note'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Health Note: ${a['health_note']}",
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
