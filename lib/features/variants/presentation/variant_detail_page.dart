// //lib/features/variants/presentation/variant_detail_page.dart

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

  // control expansion for the two compact cards
  bool _novaExpanded = false;
  bool _nutriExpanded = false;

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
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── Health Summary ─────────
                Row(
                  children: [
                    _healthCard('CPHS', _safe(d['cphs_final'])),
                    _healthCard('Label', _safe(d['health_label'])),
                    _healthCard('Stars', _safe(d['health_stars'])),
                  ],
                ),

                const SizedBox(height: 20),

                // ───────── Product Identity ─────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // off-white
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.network(
                          d['images']?['front'] ?? '',
                          height: 160,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 80),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        d['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_safe(d['brand'])),
                      Text(
                        '${_safe(d['quantity_value'])} ${_safe(d['quantity_unit'])}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ───────── Compact NOVA + Nutri-Score Row (directly after product image) ─────────
                Row(
                  children: [
                    // NOVA card
                    Expanded(
                      child: _compactInfoCard(
                        title: 'NOVA Group',
                        value: _safe(d['nova_group']),
                        isExpanded: _novaExpanded,
                        onTap: () => setState(() => _novaExpanded = !_novaExpanded),
                        // formatted dropdown content
                        dropdown: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('NOVA 1  — Unprocessed', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('NOVA 2  — Culinary ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('NOVA 3  — Processed foods', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('NOVA 4  — Ultra-processed', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nutri-Score card
                    Expanded(
                      child: _compactInfoCard(
                        title: 'Nutri-Score',
                        value: _safe(d['nutri_score']),
                        isExpanded: _nutriExpanded,
                        onTap: () => setState(() => _nutriExpanded = !_nutriExpanded),
                        dropdown: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('A — Best: more favourable nutritional profile', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('B — Good', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('C — Moderate', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('D — Poor', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('E — Worst', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ───────── Nutriments ─────────
                const Text(
                  'Nutritional Values (per 100g)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _nutrientRow('Energy', nutriments['energy_kcal_100g'], 'kcal'),
                _nutrientRow('Sugar', nutriments['sugar_g_100g'], 'g'),
                _nutrientRow('Fat', nutriments['fat_g_100g'], 'g'),
                _nutrientRow('Protein', nutriments['protein_g_100g'], 'g'),
                _nutrientRow('Salt', nutriments['salt_g_100g'], 'g'),
                _nutrientRow('Fiber', nutriments['fiber_g_100g'], 'g'),

                const SizedBox(height: 24),

                // ───────── Ingredients ─────────
                Theme(
                  // Removes default lines/borders from ExpansionTile
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text(
                      'INGREDIENTS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900, // Extra heavy bold
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: List.from(d['ingredient_summary'] ?? []).map((i) {
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ExpansionTile(
                                // Use the source_tag directly as the color indicator
                                leading: Text(
                                  i['source_tag'] ?? '⚪',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                title: Text(
                                  (i['canonical_name'] ?? '').toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800, // Heavy and bold inside text
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (i['name_in_text'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Appears as: ${i['name_in_text']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold, // Bold sub-info
                                                fontStyle: FontStyle.italic,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          _safe(i['description']),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500, // Slightly heavier weight for readability
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ───────── Additives ─────────
                Theme(
                  // Removes default lines/borders from ExpansionTile
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: false, // Usually best to keep additives closed until needed
                    title: const Text(
                      'ADDITIVES',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900, // Extra heavy bold
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: List.from(d['additives'] ?? []).map((a) {
                            final risk = _additiveRiskTag(_safe(a['notes']));

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ExpansionTile(
                                // Assuming risk tag or a code-based color indicator here
                                leading: const Icon(Icons.science_outlined, size: 20, color: Colors.blueGrey),
                                title: Text(
                                  '${a['code']} – ${a['name']}'.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800, // Heavy bold for the additive title
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  risk,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent, // Highlights the risk level
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Main notes/description
                                        Text(
                                          _safe(a['notes']),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        if (a['synonyms'] != null) ...[
                                          const SizedBox(height: 10),
                                          const Text(
                                            'ALSO KNOWN AS:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            (a['synonyms'] as List).join(', '),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ───────── Alternatives ─────────
                const Text(
                  'Better Alternatives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text('Healthier alternatives are being evaluated.'),

                const SizedBox(height: 24),

                // ───────── Variant Switcher (RESTORED) ─────────
                const Text(
                  'Other Variants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ...List.from(d['parent_product']?['variants'] ?? []).map(
                      (v) => ListTile(
                    leading: Image.network(
                      v['image'],
                      width: 40,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                    title: Text(v['title']),
                    subtitle: Text(
                      '${v['quantity_value']} ${v['quantity_unit']}',
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VariantDetailPage(variantId: v['id']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _healthCard(String label, String value) {
    return Expanded(
      child: Card(
        elevation: 3,
        color: Colors.teal.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  /// A compact, side-by-side info card that shows label left, value+arrow right,
  /// and expands to reveal formatted dropdown content.
  Widget _compactInfoCard({
    required String title,
    required String value,
    required Widget dropdown,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    // color the value if it's NOVA (numeric) or Nutri-Score (letters)
    final bool isNova = title.toLowerCase().contains('nova');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  // Label on the left
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Value on the right with arrow immediately after
                  Row(
                    children: [
                      // value — slightly large, aligned to right
                      Text(
                        value,
                        style: TextStyle(
                          color: isNova ? Colors.red : Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // small caret placed immediately after the value
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade700,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Animated expansion area with nicely padded and aligned content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Container(
                width: double.infinity,
                // subtle background for the dropdown area
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: dropdown,
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
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