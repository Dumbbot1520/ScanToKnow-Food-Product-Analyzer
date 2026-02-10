import 'package:flutter/material.dart';

class OCRResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const OCRResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final ingredients = data["ingredients"] as List<dynamic>;
    final additives = data["additives"] as List<dynamic>;
    final nova = data["nova"];

    return Scaffold(
      appBar: AppBar(title: const Text("OCR Result")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOVA
            Card(
              child: ListTile(
                title: Text(
                  nova["label"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var r in nova["reasons"]) Text("• $r"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Ingredients",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            for (var i in ingredients)
              ListTile(
                title: Text(i["name"]),
                subtitle: Text(i["description"] ?? ""),
                trailing: Text(i["source_tag"] ?? ""),
              ),

            const SizedBox(height: 20),

            const Text("Additives",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            for (var a in additives)
              ListTile(
                title: Text("${a["code"]} – ${a["name"]}"),
                subtitle: Text(a["description"] ?? ""),
                trailing: Text(a["source_tag"] ?? ""),
              ),
          ],
        ),
      ),
    );
  }
}
