// //lib/features/variants/presentation/variant_detail_page.dart
//
// import 'package:flutter/material.dart';
// import '../../../core/network/api_service.dart';
//
// class VariantDetailPage extends StatefulWidget {
//   final String variantId;
//
//   const VariantDetailPage({super.key, required this.variantId});
//
//   @override
//   State<VariantDetailPage> createState() => _VariantDetailPageState();
// }
//
// class _VariantDetailPageState extends State<VariantDetailPage> {
//   late Future<Map<String, dynamic>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _fetchVariant();
//   }
//
//   Future<Map<String, dynamic>> _fetchVariant() async {
//     final res = await ApiService.get('/v1/variants/${widget.variantId}');
//     if (res is Map && res['data'] is Map) {
//       return Map<String, dynamic>.from(res['data']);
//     }
//     throw Exception('Invalid variant response');
//   }
//
//   String _safe(dynamic v, {String fallback = 'Coming soon'}) {
//     if (v == null || v.toString().isEmpty) return fallback;
//     return v.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Product Details')),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _future,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snap.hasError) {
//             return Center(child: Text(snap.error.toString()));
//           }
//
//           final d = snap.data!;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 // ───────────────── Health Summary ─────────────────
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _healthCard('CPHS', _safe(d['cphs_final'])),
//                     _healthCard('Label', _safe(d['health_label'])),
//                     _healthCard('Stars', _safe(d['health_stars'])),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // ───────────────── Product Identity ─────────────────
//                 Center(
//                   child: Column(
//                     children: [
//                       Image.network(
//                         d['images']?['front'] ?? '',
//                         height: 160,
//                         errorBuilder: (_, __, ___) =>
//                         const Icon(Icons.image_not_supported, size: 80),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(d['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       Text(_safe(d['brand'])),
//                       Text('${_safe(d['quantity_value'])} ${_safe(d['quantity_unit'])}'),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // ───────────────── NOVA + Nutri ─────────────────
//                 Row(
//                   children: [
//                     Expanded(child: _infoCard(
//                       title: 'NOVA Group',
//                       value: _safe(d['nova_group']),
//                       description: '''
// NOVA 1 – Unprocessed
// NOVA 2 – Culinary ingredients
// NOVA 3 – Processed foods
// NOVA 4 – Ultra-processed
// ''',
//                     )),
//                     const SizedBox(width: 12),
//                     Expanded(child: _infoCard(
//                       title: 'Nutri-Score',
//                       value: _safe(d['nutri_score']),
//                       description: '''
// A – Best
// B – Good
// C – Moderate
// D – Poor
// E – Worst
// ''',
//                     )),
//                   ],
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // ───────────────── Ingredients ─────────────────
//                 const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//
//                 Wrap(
//                   spacing: 8,
//                   children: const [
//                     Chip(label: Text('🟢 Safe')),
//                     Chip(label: Text('🟠 Moderate')),
//                     Chip(label: Text('🔴 Harmful')),
//                   ],
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 ...List.from(d['ingredient_summary'] ?? []).map((i) => Card(
//                   child: ListTile(
//                     title: Text(i['canonical_name'] ?? ''),
//                     leading: Text(i['source_tag'] ?? ''),
//                     subtitle: Text(_safe(i['description'])),
//                   ),
//                 )),
//
//                 const SizedBox(height: 24),
//
//                 // ───────────────── Additives ─────────────────
//                 const Text('Additives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//
//                 ...List.from(d['additives'] ?? []).map((a) => ExpansionTile(
//                   title: Text('${a['code']} – ${a['name']}'),
//                   subtitle: Text(_safe(a['notes'])),
//                   children: [
//                     if (a['synonyms'] != null)
//                       Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Text('Synonyms: ${a['synonyms'].join(', ')}'),
//                       ),
//                   ],
//                 )),
//
//                 const SizedBox(height: 24),
//
//                 // ───────────────── Alternatives ─────────────────
//                 const Text('Better Alternatives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 const Text('Healthier alternatives are being evaluated.'),
//
//                 const SizedBox(height: 24),
//
//                 // ───────────────── Variant Switcher ─────────────────
//                 const Text('Other Variants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//
//                 ...List.from(d['parent_product']?['variants'] ?? []).map((v) => ListTile(
//                   leading: Image.network(v['image'], width: 40, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
//                   title: Text(v['title']),
//                   subtitle: Text('${v['quantity_value']} ${v['quantity_unit']}'),
//                   onTap: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => VariantDetailPage(variantId: v['id']),
//                       ),
//                     );
//                   },
//                 )),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _healthCard(String label, String value) {
//     return Expanded(
//       child: Card(
//         color: Colors.teal.shade50,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 6),
//               Text(value, style: const TextStyle(fontSize: 16)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _infoCard({
//     required String title,
//     required String value,
//     required String description,
//   }) {
//     return Card(
//       child: ExpansionTile(
//         title: Text(title),
//         subtitle: Text(value),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Text(description),
//           )
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class VariantDetailPage extends StatefulWidget {
  final String variantId;

  const VariantDetailPage({super.key, required this.variantId});

  @override
  State<VariantDetailPage> createState() => _VariantDetailPageState();
}

class _VariantDetailPageState extends State<VariantDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchVariant();
  }

  Future<Map<String, dynamic>> _fetchVariant() async {
    final res = await ApiService.get('/v1/variants/${widget.variantId}');
    if (res is Map && res['data'] is Map) {
      return Map<String, dynamic>.from(res['data']);
    }
    throw Exception('Invalid variant response');
  }

  String _safe(dynamic v, {String fallback = 'Coming soon'}) {
    if (v == null || v.toString().isEmpty) return fallback;
    return v.toString();
  }

  /// UI-only additive risk tagging
  String _additiveRiskTag(String notes) {
    final n = notes.toLowerCase();
    if (n.contains('restricted') ||
        n.contains('hyperactivity') ||
        n.contains('benzene') ||
        n.contains('ultra-processed')) {
      return '🔴 High Risk';
    }
    if (n.contains('erosive') || n.contains('warning') || n.contains('limit')) {
      return '🟠 Moderate';
    }
    return '🟢 Low Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }

          final d = snap.data!;
          final nutriments = d['nutriments'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ───────── Health Summary ─────────
              Row(children: [
                _healthCard('CPHS', _safe(d['cphs_final'])),
                _healthCard('Label', _safe(d['health_label'])),
                _healthCard('Stars', _safe(d['health_stars'])),
              ]),

              const SizedBox(height: 20),

              // ───────── Product Identity ─────────
              Center(
                child: Column(children: [
                  Image.network(
                    d['images']?['front'] ?? '',
                    height: 160,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 80),
                  ),
                  const SizedBox(height: 10),
                  Text(d['title'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_safe(d['brand'])),
                  Text('${_safe(d['quantity_value'])} ${_safe(d['quantity_unit'])}'),
                ]),
              ),

              const SizedBox(height: 24),

              // ───────── NOVA + Nutri ─────────
              Row(children: [
                Expanded(child: _infoCard(
                  title: 'NOVA Group',
                  value: _safe(d['nova_group']),
                  description: '''
NOVA 1 – Unprocessed
NOVA 2 – Culinary ingredients
NOVA 3 – Processed foods
NOVA 4 – Ultra-processed
''',
                )),
                const SizedBox(width: 12),
                Expanded(child: _infoCard(
                  title: 'Nutri-Score',
                  value: _safe(d['nutri_score']),
                  description: '''
A – Best
B – Good
C – Moderate
D – Poor
E – Worst
''',
                )),
              ]),

              const SizedBox(height: 24),

              // ───────── Nutriments ─────────
              const Text('Nutritional Values (per 100g)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _nutrientRow('Energy', nutriments['energy_kcal_100g'], 'kcal'),
              _nutrientRow('Sugar', nutriments['sugar_g_100g'], 'g'),
              _nutrientRow('Fat', nutriments['fat_g_100g'], 'g'),
              _nutrientRow('Protein', nutriments['protein_g_100g'], 'g'),
              _nutrientRow('Salt', nutriments['salt_g_100g'], 'g'),
              _nutrientRow('Fiber', nutriments['fiber_g_100g'], 'g'),

              const SizedBox(height: 24),

              // ───────── Ingredients ─────────
              const Text('Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ...List.from(d['ingredient_summary'] ?? []).map((i) => Card(
                child: ListTile(
                  leading: Text(i['source_tag'] ?? ''),
                  title: Text(i['canonical_name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i['name_in_text'] != null)
                        Text('Appears as: ${i['name_in_text']}'),
                      const SizedBox(height: 4),
                      Text(_safe(i['description'])),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // ───────── Additives ─────────
              const Text('Additives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ...List.from(d['additives'] ?? []).map((a) {
                final risk = _additiveRiskTag(_safe(a['notes'], fallback: ''));
                return ExpansionTile(
                  title: Text('${a['code']} – ${a['name']}'),
                  subtitle: Text(risk),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_safe(a['notes'])),
                    ),
                    if (a['synonyms'] != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Also known as: ${a['synonyms'].join(', ')}'),
                      ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // ───────── Alternatives ─────────
              const Text('Better Alternatives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Healthier alternatives are being evaluated.'),

              const SizedBox(height: 24),

              // ───────── Variant Switcher (RESTORED) ─────────
              const Text('Other Variants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ...List.from(d['parent_product']?['variants'] ?? []).map((v) => ListTile(
                leading: Image.network(
                  v['image'],
                  width: 40,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                ),
                title: Text(v['title']),
                subtitle: Text('${v['quantity_value']} ${v['quantity_unit']}'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VariantDetailPage(variantId: v['id']),
                    ),
                  );
                },
              )),
            ]),
          );
        },
      ),
    );
  }

  Widget _healthCard(String label, String value) {
    return Expanded(
      child: Card(
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value),
          ]),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required String description,
  }) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text(value),
        children: [Padding(padding: const EdgeInsets.all(12), child: Text(description))],
      ),
    );
  }

  Widget _nutrientRow(String name, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(value != null ? '$value $unit' : 'Coming soon'),
        ],
      ),
    );
  }
}
