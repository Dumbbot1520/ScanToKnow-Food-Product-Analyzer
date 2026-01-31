// lib/features/categories/presentation/category_page.dart

import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/ui/category_image_resolver.dart';
import '../../products/presentation/product_list_page.dart';

class CategoryChild {
  final String id;
  final String slug;
  final String name;
  final int level;
  final String? parentId;
  final int? displayOrder;

  CategoryChild({
    required this.id,
    required this.slug,
    required this.name,
    required this.level,
    this.parentId,
    this.displayOrder,
  });

  factory CategoryChild.fromMap(Map m) {
    return CategoryChild(
      id: (m['_id'] ?? m['id'] ?? '').toString(),
      slug: (m['slug'] ?? m['code'] ?? '').toString(),
      name: (m['name'] ?? m['title'] ?? '').toString(),
      level: (m['level'] is int) ? m['level'] as int : int.tryParse((m['level'] ?? '').toString()) ?? 0,
      parentId: (m['parent_id'] ?? m['parentId'])?.toString(),
      displayOrder: m['display_order'] is int ? m['display_order'] as int : (m['display_order'] != null ? int.tryParse(m['display_order'].toString()) : null),
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String topSlug;
  final String topTitle;

  const CategoryPage({super.key, required this.topSlug, required this.topTitle});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<CategoryChild>> _futureChildren;

  @override
  void initState() {
    super.initState();
    _futureChildren = _fetchChildren();
  }

  Future<List<CategoryChild>> _fetchChildren() async {
    final resp = await ApiService.get('/v1/categories/${widget.topSlug}/children');

    // ignore: avoid_print
    print('CategoryPage: children raw -> $resp');

    if (resp is Map && resp.containsKey('data')) {
      final data = resp['data'];
      if (data is List) {
        final list = data.map<CategoryChild>((m) => CategoryChild.fromMap(m as Map)).toList();

        // sort by displayOrder if present (stable)
        list.sort((a, b) {
          final da = a.displayOrder ?? 9999;
          final db = b.displayOrder ?? 9999;
          return da.compareTo(db);
        });

        return list;
      } else {
        throw Exception('Unexpected "data" type: ${data.runtimeType}');
      }
    } else {
      throw Exception('Unexpected response: ${resp.runtimeType}');
    }
  }

  void _openProductsForSubcategory(CategoryChild child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListPage(subSlug: child.slug, title: child.name),
      ),
    );
  }

  Widget _buildTile(CategoryChild c) {
    final localAsset = assetForCategorySlug(c.slug);
    return GestureDetector(
      onTap: () => _openProductsForSubcategory(c),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: localAsset != null
                  ? Image.asset(localAsset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade100))
                  : Container(color: Colors.grey.shade100),
            ),
            const SizedBox(height: 10),
            Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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
      appBar: AppBar(title: Text(widget.topTitle), backgroundColor: Colors.teal.shade600),
      body: SafeArea(
        child: FutureBuilder<List<CategoryChild>>(
          future: _futureChildren,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) {
              final err = snapshot.error.toString();
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    const Text('Failed to load subcategories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(err, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => setState(() => _futureChildren = _fetchChildren()), child: const Text('Retry')),
                  ],
                ),
              );
            }

            final children = snapshot.data ?? [];

            if (children.isEmpty) {
              return const Center(child: Text('No subcategories found.'));
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: children.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95),
                itemBuilder: (context, idx) => _buildTile(children[idx]),
              ),
            );
          },
        ),
      ),
    );
  }
}
