// // lib/features/products/presentation/product_list_page.dart


import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../variants/presentation/variant_detail_page.dart'; // ✅ NEW

class ProductItem {
  final String id;
  final String title;
  final String? brand;
  final String? thumbnail;
  final int? novaGroup;
  final String? nutriScore;

  ProductItem({
    required this.id,
    required this.title,
    this.brand,
    this.thumbnail,
    this.novaGroup,
    this.nutriScore,
  });

  factory ProductItem.fromMap(Map m) {
    return ProductItem(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      title: (m['title'] ?? m['product_name'] ?? '').toString(),
      brand: (m['brand'] is Map)
          ? (m['brand']['name']?.toString())
          : (m['brand']?.toString()),
      thumbnail: (m['images'] is Map)
          ? (m['images']['front'] ?? m['images']['thumbnail'])?.toString()
          : null,
      novaGroup: m['nova_group'] is int
          ? m['nova_group'] as int
          : int.tryParse(m['nova_group']?.toString() ?? ''),
      nutriScore: m['nutri_score']?.toString(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  final String subSlug;
  final String title;

  const ProductListPage({
    super.key,
    required this.subSlug,
    required this.title,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _page = 1;
  final int _limit = 24;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<ProductItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final resp = await ApiService.get(
        '/v1/categories/${widget.subSlug}/products?page=$_page&limit=$_limit',
      );

      if (resp is Map && resp.containsKey('products')) {
        final List raw = resp['products'];
        final newItems =
        raw.map((m) => ProductItem.fromMap(m as Map)).toList();

        final total = int.tryParse(resp['total']?.toString() ?? '0') ?? 0;

        setState(() {
          _items.addAll(newItems);
          _page++;
          _hasMore = _items.length < total;
        });
      } else {
        throw Exception('Unexpected products response');
      }
    } catch (e) {
      // ignore: avoid_print
      print('ProductListPage error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ SINGLE RESPONSIBILITY: navigation only
  void _openVariant(ProductItem p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VariantDetailPage(variantId: p.id),
      ),
    );
  }

  Widget _buildCard(ProductItem p) {
    return GestureDetector(
      onTap: () => _openVariant(p), // ✅ THIS IS THE KEY LINE
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: p.thumbnail != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.thumbnail!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade100),
                ),
              )
                  : Container(color: Colors.grey.shade100),
            ),
            const SizedBox(height: 8),
            Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (p.nutriScore != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.nutriScore!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                if (p.novaGroup != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NOVA ${p.novaGroup}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 700 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal.shade600,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length + (_hasMore ? 1 : 0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, idx) {
            if (idx < _items.length) {
              return _buildCard(_items[idx]);
            } else {
              if (!_isLoading) _fetchPage();
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
