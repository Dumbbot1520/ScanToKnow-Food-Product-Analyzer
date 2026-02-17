// lib/features/variants/presentation/variant_detail_page.dart

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

  // Expansion states
  bool _novaExpanded = false;
  bool _nutriExpanded = false;
  bool _cphsExpanded = false;

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
    if (v == null) return fallback;
    final s = v.toString();
    if (s.isEmpty) return fallback;
    return s;
  }

  String _formatValue(dynamic v, {int decimals = 1, String fallback = '—'}) {
    if (v == null) return fallback;
    if (v is num) {
      if (decimals == 0) return v.round().toString();
      return v.toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '');
    }
    final parsed = double.tryParse(v.toString());
    if (parsed != null) {
      if (decimals == 0) return parsed.round().toString();
      return parsed.toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '');
    }
    return v.toString();
  }

  /// Try multiple possible OFF / DB keys for the same nutriment.
  dynamic _getNutriment(Map<String, dynamic>? nutriments, List<String> keys) {
    if (nutriments == null) return null;
    for (final k in keys) {
      if (nutriments.containsKey(k)) {
        final val = nutriments[k];
        if (val != null) return val;
      }
    }
    return null;
  }

  /// Convert cphs_final (0-1) to score (0-100)
  int _cphsScore(dynamic cphsFinal) {
    if (cphsFinal == null) return 0;
    final double? n = (cphsFinal is num)
        ? (cphsFinal as num).toDouble()
        : double.tryParse(cphsFinal.toString());
    if (n == null) return 0;
    final int value = (n * 100).round();
    return value.clamp(0, 100);
  }

  /// Tag name from emoji
  String _tagName(String emoji) {
    switch (emoji) {
      case '🔵':
        return 'Optimal';
      case '🟢':
        return 'Safe';
      case '🟡':
        return 'Moderate';
      case '🟠':
        return 'Caution';
      case '🔴':
        return 'Hazard';
      default:
        return 'Unknown';
    }
  }

  /// Tag color from emoji
  Color _tagColor(String emoji) {
    switch (emoji) {
      case '🔵':
        return const Color(0xFF1E88E5); // Blue
      case '🟢':
        return const Color(0xFF43A047); // Green
      case '🟡':
        return const Color(0xFFFDD835); // Yellow
      case '🟠':
        return const Color(0xFFFF9800); // Orange
      case '🔴':
        return const Color(0xFFE53935); // Red
      default:
        return Colors.grey;
    }
  }

  /// Health label display text
  String _healthLabelText(String? label) {
    if (label == null) return 'Not Rated';
    switch (label.toLowerCase()) {
      case 'very_good':
        return 'Very Good';
      case 'good':
        return 'Good';
      case 'okay':
        return 'Okay';
      case 'poor':
        return 'Poor';
      case 'very_poor':
        return 'Very Poor';
      default:
        return label;
    }
  }

  /// Health label color
  Color _healthLabelColor(String? label) {
    if (label == null) return Colors.grey;
    switch (label.toLowerCase()) {
      case 'very_good':
        return const Color(0xFF2E7D32);
      case 'good':
        return const Color(0xFF558B2F);
      case 'okay':
        return const Color(0xFFF9A825);
      case 'poor':
        return const Color(0xFFEF6C00);
      case 'very_poor':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Product Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snap.error}', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final d = snap.data!;
          final Map<String, dynamic> nutriments =
          Map<String, dynamic>.from(d['nutriments'] ?? {});

          // Extract nutriments
          final energy =
          _getNutriment(nutriments, ['energy_kcal_100g', 'energy-kcal_100g', 'energy_100g', 'energy_kcal']);
          final sugar = _getNutriment(nutriments, ['sugar_g_100g', 'sugars_100g', 'sugars']);
          final fat = _getNutriment(nutriments, ['fat_g_100g', 'fat_100g', 'fat']);
          final protein = _getNutriment(nutriments, ['protein_g_100g', 'proteins_100g', 'proteins']);
          final salt = _getNutriment(nutriments, ['salt_g_100g', 'salt_100g', 'salt']);
          final fiber = _getNutriment(nutriments, ['fiber_g_100g', 'fiber_100g', 'fiber']);
          final saturatedFat = _getNutriment(nutriments, [
            'saturated_fat_g_100g',
            'saturated-fat_100g',
            'saturated-fat',
            'saturated_fat',
            'saturated_fat_100g'
          ]);
          final sodium =
          _getNutriment(nutriments, ['sodium_g_100g', 'sodium_100g', 'sodium']);

          // CPHS data
          final cphsScore = _cphsScore(d['cphs_final']);
          final healthLabel = d['health_label']?.toString();
          final healthStars = d['health_stars'] is num ? (d['health_stars'] as num).toInt() : (int.tryParse(d['health_stars']?.toString() ?? '') ?? 0);

          // Precompute colors safely (avoid calling withOpacity directly)
          final Color healthPrimary = _healthLabelColor(healthLabel);
          final Color healthPrimaryAlpha =
          healthPrimary.withAlpha((0.7 * 255).round());

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════════════════════
                // SECTION 1: CPHS HERO CARD (CHANGE 1 - New large score display)
                // ═══════════════════════════════════════════════════════════════
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        healthPrimary,
                        healthPrimaryAlpha,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    children: [
                      // Large circular score
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.15 * 255).round()),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cphsScore.toString(),
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                  color: _healthLabelColor(healthLabel),
                                ),
                              ),
                              const Text(
                                '/100',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Label + Stars
                      Text(
                        _healthLabelText(healthLabel),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                              (i) => Icon(
                            i < (healthStars ?? 0) ? Icons.star : Icons.star_border,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // "How is this calculated?" expandable
                      InkWell(
                        onTap: () => setState(() => _cphsExpanded = !_cphsExpanded),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'How is this score calculated?',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _cphsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Explanation dropdown
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CPHS Score Breakdown',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'The Comprehensive Product Health Score (CPHS) is calculated on a 0-100 scale based on:',
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              _buildBullet('Nutrition quality (Nutri-Score algorithm)'),
                              _buildBullet('Ingredient quality (whole foods vs refined)'),
                              _buildBullet('Sugar content penalty'),
                              _buildBullet('Processing level (NOVA classification)'),
                              _buildBullet('Additive safety ratings'),
                              const SizedBox(height: 12),
                              const Text(
                                'Score Ranges:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              _buildScoreRange('85-100', 'Very Good', const Color(0xFF2E7D32)),
                              _buildScoreRange('60-84', 'Good', const Color(0xFF558B2F)),
                              _buildScoreRange('40-59', 'Okay', const Color(0xFFF9A825)),
                              _buildScoreRange('20-39', 'Poor', const Color(0xFFEF6C00)),
                              _buildScoreRange('0-19', 'Very Poor', const Color(0xFFC62828)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: const Text(
                                  'Disclaimer: This score is for informational and educational purposes only. It is not a substitute for professional medical or nutritional advice. Always consult a healthcare provider for personalized dietary guidance.',
                                  style: TextStyle(fontSize: 12, height: 1.4, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                        crossFadeState: _cphsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 2: PRODUCT IDENTITY
                // ═══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Product image
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.network(
                              d['images']?['front'] ?? '',
                              height: 160,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            d['title'] ?? 'Unknown Product',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _safe(d['brand']),
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_safe(d['quantity_value'])} ${_safe(d['quantity_unit'])}',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 3: NOVA + NUTRI-SCORE (CHANGE 2 - Improved layout)
                // ═══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // NOVA card (full width, cleaner design)
                      _buildMetricCard(
                        title: 'NOVA Processing Level',
                        value: _safe(d['nova_group'], fallback: 'N/A'),
                        valueColor: _novaColor(d['nova_group']),
                        isExpanded: _novaExpanded,
                        onTap: () => setState(() => _novaExpanded = !_novaExpanded),
                        icon: Icons.factory_outlined,
                        explanation: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NOVA classifies foods by processing level:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            _buildNovaBadge('1', 'Unprocessed/Minimally Processed',
                                'Fresh fruits, vegetables, milk', const Color(0xFF2E7D32)),
                            const SizedBox(height: 6),
                            _buildNovaBadge('2', 'Culinary Ingredients', 'Oils, butter, sugar, salt',
                                const Color(0xFF558B2F)),
                            const SizedBox(height: 6),
                            _buildNovaBadge(
                                '3', 'Processed Foods', 'Canned vegetables, cheeses, bread', const Color(0xFFF9A825)),
                            const SizedBox(height: 6),
                            _buildNovaBadge('4', 'Ultra-Processed',
                                'Soft drinks, packaged snacks, instant noodles', const Color(0xFFE53935)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nutri-Score card (full width, cleaner design)
                      _buildMetricCard(
                        title: 'Nutri-Score Grade',
                        value: _safe(d['nutri_score'], fallback: 'N/A').toUpperCase(),
                        valueColor: _nutriScoreColor(d['nutri_score']),
                        isExpanded: _nutriExpanded,
                        onTap: () => setState(() => _nutriExpanded = !_nutriExpanded),
                        icon: Icons.star_half_outlined,
                        explanation: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nutri-Score grades nutritional quality from A (best) to E (worst):',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            _buildNutriBadge('A', 'Excellent', const Color(0xFF2E7D32)),
                            const SizedBox(height: 4),
                            _buildNutriBadge('B', 'Good', const Color(0xFF66BB6A)),
                            const SizedBox(height: 4),
                            _buildNutriBadge('C', 'Fair', const Color(0xFFFDD835)),
                            const SizedBox(height: 4),
                            _buildNutriBadge('D', 'Poor', const Color(0xFFFF9800)),
                            const SizedBox(height: 4),
                            _buildNutriBadge('E', 'Very Poor', const Color(0xFFE53935)),
                            const SizedBox(height: 8),
                            const Text(
                              'Calculated by balancing negative factors (sugar, salt, saturated fat, energy) against positive factors (fiber, protein, fruits/vegetables).',
                              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 4: NUTRIMENTS (CHANGE 3 - Visual bars + table)
                // ═══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nutritional Values',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Per 100g / 100ml',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      // Visual nutriment cards with progress bars
                      _buildNutrimentBar('Energy', energy, 'kcal', 2000, Colors.orange),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Sugar', sugar, 'g', 50, Colors.red),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Fat', fat, 'g', 70, Colors.amber),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Saturated Fat', saturatedFat, 'g', 20, Colors.deepOrange),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Protein', protein, 'g', 50, Colors.green),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Salt', salt, 'g', 6, Colors.blueGrey),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Fiber', fiber, 'g', 25, Colors.brown),
                      const SizedBox(height: 12),
                      _buildNutrimentBar('Sodium', sodium, 'g', 2.4, Colors.indigo),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 5: INGREDIENTS (CHANGE 4 - Tag legend + improved UI)
                // ═══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingredients',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Tag legend
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                const SizedBox(width: 6),
                                Text(
                                  'Health Rating Tags',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                _buildTagLegendItem('🔵', 'Optimal', const Color(0xFF1E88E5)),
                                _buildTagLegendItem('🟢', 'Safe', const Color(0xFF43A047)),
                                _buildTagLegendItem('🟡', 'Moderate', const Color(0xFFFDD835)),
                                _buildTagLegendItem('🟠', 'Caution', const Color(0xFFFF9800)),
                                _buildTagLegendItem('🔴', 'Hazard', const Color(0xFFE53935)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ingredients list
                      ...List.from(d['ingredient_summary'] ?? []).map((i) {
                        final tag = i['source_tag']?.toString() ?? '⚪';
                        final tagName = _tagName(tag);
                        final tagColor = _tagColor(tag);

                        // compute alpha variants safely
                        final tagColorAlpha = tagColor.withAlpha((0.1 * 255).round());
                        final tagColorAlphaSide = tagColor.withAlpha((0.3 * 255).round());

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: tagColorAlphaSide, width: 2),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: tagColorAlpha,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(tag, style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              title: Text(
                                (i['canonical_name'] ?? 'Unknown').toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              subtitle: Text(
                                tagName,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tagColor),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (i['percentage'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.pie_chart_outline, size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${_formatValue(i['percentage'], decimals: 1)}% of product',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        _safe(i['description']),
                                        style: const TextStyle(fontSize: 14, height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 6: ADDITIVES (CHANGE 5 - Fixed source_tag reading)
                // ═══════════════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additives',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if ((d['additives'] as List?)?.isEmpty ?? true)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'No additives detected — this product uses only whole food ingredients.',
                                  style: TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.from(d['additives'] ?? []).map((a) {
                          // CRITICAL FIX: Read source_tag from API response, NOT from notes parsing
                          final tag = a['source_tag']?.toString() ?? '⚪';
                          final tagName = _tagName(tag);
                          final tagColor = _tagColor(tag);

                          final tagColorAlpha = tagColor.withAlpha((0.1 * 255).round());
                          final tagColorAlphaSide = tagColor.withAlpha((0.3 * 255).round());

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: tagColorAlphaSide, width: 2),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: tagColorAlpha,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(tag, style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                title: Text(
                                  '${a['code']} — ${a['name']}'.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                subtitle: Text(
                                  tagName,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tagColor),
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (a['description'] != null) ...[
                                          const Text(
                                            'What it is:',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _safe(a['description']),
                                            style: const TextStyle(fontSize: 14, height: 1.5),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                        if (a['notes'] != null) ...[
                                          const Text(
                                            'Safety notes:',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _safe(a['notes']),
                                            style: const TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                        if (a['synonyms'] != null && (a['synonyms'] as List).isNotEmpty) ...[
                                          const Text(
                                            'Also known as:',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (a['synonyms'] as List).join(', '),
                                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════════
                // SECTION 7: VARIANT SWITCHER
                // ═══════════════════════════════════════════════════════════════
                if ((d['parent_product']?['variants'] as List?)?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Other Sizes',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...List.from(d['parent_product']?['variants'] ?? []).map(
                              (v) => Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  v['image'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, size: 24, color: Colors.grey),
                                  ),
                                ),
                              ),
                              title: Text(
                                v['title'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                '${v['quantity_value']} ${v['quantity_unit']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // HELPER WIDGETS

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, height: 1.4)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildScoreRange(String range, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$range — ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color valueColor,
    required bool isExpanded,
    required VoidCallback onTap,
    required IconData icon,
    required Widget explanation,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: valueColor.withAlpha((0.1 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: valueColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: valueColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: explanation,
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildNovaBadge(String level, String name, String example, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(example, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutriBadge(String grade, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: Text(grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildNutrimentBar(String label, dynamic value, String unit, double referenceValue, Color color) {
    final numValue = (value is num) ? value.toDouble() : (double.tryParse(value?.toString() ?? '0') ?? 0.0);
    final percentage = (numValue / referenceValue).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(
                value != null ? '${_formatValue(value)} $unit' : '—',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reference: ~${referenceValue.toStringAsFixed(0)}$unit per day',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTagLegendItem(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Color _novaColor(dynamic nova) {
    final int n = (nova is int)
        ? nova
        : (int.tryParse(nova?.toString() ?? '') ?? 4);
    switch (n) {
      case 1:
        return const Color(0xFF2E7D32);
      case 2:
        return const Color(0xFF558B2F);
      case 3:
        return const Color(0xFFF9A825);
      case 4:
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  Color _nutriScoreColor(dynamic score) {
    final String s = (score ?? 'e').toString().toLowerCase();
    switch (s) {
      case 'a':
        return const Color(0xFF2E7D32);
      case 'b':
        return const Color(0xFF66BB6A);
      case 'c':
        return const Color(0xFFFDD835);
      case 'd':
        return const Color(0xFFFF9800);
      case 'e':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }
}