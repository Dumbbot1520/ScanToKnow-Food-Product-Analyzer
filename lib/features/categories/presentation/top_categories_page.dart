// // lib/features/categories/presentation/top_categories_page.dart
//
// import 'package:flutter/material.dart';
// import '../../../core/network/api_service.dart';
// import '../../../core/ui/widgets/top_categories.dart' show CategoryItem;
// import '../../../core/ui/category_image_resolver.dart';
//
// /// TopCategoriesPage
// /// Fetches all level-1 categories from the backend and shows them in a grid.
// /// Tapping a category opens a placeholder page (Category -> products).
// class TopCategoriesPage extends StatefulWidget {
//   const TopCategoriesPage({super.key});
//
//   @override
//   State<TopCategoriesPage> createState() => _TopCategoriesPageState();
// }
//
// class _TopCategoriesPageState extends State<TopCategoriesPage> {
//   late Future<List<CategoryItem>> _futureCategories;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureCategories = _fetchTopCategories();
//   }
//
//   Future<List<CategoryItem>> _fetchTopCategories() async {
//     final response = await ApiService.get('/v1/categories?level=1&limit=100');
//
//     // Defensive logging
//     // ignore: avoid_print
//     print('TopCategoriesPage: raw response -> $response');
//
//     if (response is Map && response.containsKey('data')) {
//       final data = response['data'];
//       if (data is List) {
//         final items = data.map<CategoryItem>((c) {
//           final id = c['_id'] ?? c['id'] ?? '';
//           final slug = (c['slug'] ?? c['code'] ?? '').toString();
//           final name = (c['name'] ?? c['title'] ?? '').toString();
//
//           return CategoryItem(
//             id: id.toString(),
//             slug: slug,
//             title: name,
//             imageUrl: null, // backend currently sends no image field
//             productCount: null,
//           );
//         }).toList();
//
//         // ignore: avoid_print
//         print('TopCategoriesPage: parsed ${items.length} categories');
//         return items;
//       } else {
//         throw Exception('Unexpected "data" shape: ${data.runtimeType}');
//       }
//     } else if (response is List) {
//       // defensive fallback (unlikely)
//       final items = response.map<CategoryItem>((c) {
//         final id = c['_id'] ?? c['id'] ?? '';
//         final slug = (c['slug'] ?? c['code'] ?? '').toString();
//         final name = (c['name'] ?? c['title'] ?? '').toString();
//
//         return CategoryItem(
//           id: id.toString(),
//           slug: slug,
//           title: name,
//           imageUrl: null,
//           productCount: null,
//         );
//       }).toList();
//       return items;
//     } else {
//       throw Exception('Unexpected response type: ${response.runtimeType}');
//     }
//   }
//
//   void _openCategoryProducts(CategoryItem item) {
//     // placeholder: implement products list later
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           appBar: AppBar(title: Text(item.title)),
//           body: Center(child: Text('Products for "${item.title}" (todo)')),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard(CategoryItem item) {
//     final String? localAsset = assetForCategorySlug(item.slug);
//     final bool useNetwork = item.imageUrl != null && item.imageUrl!.isNotEmpty;
//
//     return GestureDetector(
//       onTap: () => _openCategoryProducts(item),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
//         ),
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   color: Colors.grey.shade100,
//                   alignment: Alignment.center,
//                   child: useNetwork
//                       ? Image.network(item.imageUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
//                       : (localAsset != null
//                       ? Image.asset(localAsset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
//                       : const Icon(Icons.image_not_supported)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               item.title,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (item.productCount != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Text('${item.productCount} items', style: const TextStyle(fontSize: 12, color: Colors.black54)),
//               )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceholderCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         children: [
//           Expanded(child: Container(color: Colors.grey.shade100)),
//           const SizedBox(height: 10),
//           const Text('Coming soon', style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Responsive columns: 2 on phones, 3 on wide screens
//     final width = MediaQuery.of(context).size.width;
//     final crossAxisCount = width > 700 ? 3 : 2;
//     const int minTiles = 6; // show at least 6 tiles if empty
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Top Categories'),
//         backgroundColor: Colors.teal.shade600,
//       ),
//       body: SafeArea(
//         child: FutureBuilder<List<CategoryItem>>(
//           future: _futureCategories,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.hasError) {
//               final err = snapshot.error.toString();
//               return Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
//                     const SizedBox(height: 12),
//                     const Text('Failed to load top categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Text(err, textAlign: TextAlign.center),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () => setState(() => _futureCategories = _fetchTopCategories()),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             final items = snapshot.data ?? [];
//
//             // Prepare grid children: show all items (sorted by display_order if you want), then fill placeholders.
//             final children = <Widget>[];
//             for (final it in items) children.add(_buildCard(it));
//
//             // ensure minimum tiles so grid looks balanced
//             while (children.length < minTiles) {
//               children.add(_buildPlaceholderCard());
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: GridView.builder(
//                 itemCount: children.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 0.95,
//                 ),
//                 itemBuilder: (_, index) => children[index],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// lib/features/categories/presentation/top_categories_page.dart

import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/ui/widgets/top_categories.dart' show CategoryItem;
import '../../../core/ui/category_image_resolver.dart';
import 'category_page.dart'; // <--- new

class TopCategoriesPage extends StatefulWidget {
  const TopCategoriesPage({super.key});

  @override
  State<TopCategoriesPage> createState() => _TopCategoriesPageState();
}

class _TopCategoriesPageState extends State<TopCategoriesPage> {
  late Future<List<CategoryItem>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = _fetchTopCategories();
  }

  Future<List<CategoryItem>> _fetchTopCategories() async {
    final response = await ApiService.get('/v1/categories?level=1&limit=100');

    // ignore: avoid_print
    print('TopCategoriesPage: raw response -> $response');

    if (response is Map && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) {
        final items = data.map<CategoryItem>((c) {
          final id = c['_id'] ?? c['id'] ?? '';
          final slug = (c['slug'] ?? c['code'] ?? '').toString();
          final name = (c['name'] ?? c['title'] ?? '').toString();

          return CategoryItem(
            id: id.toString(),
            slug: slug,
            title: name,
            imageUrl: null,
            productCount: null,
          );
        }).toList();

        // ignore: avoid_print
        print('TopCategoriesPage: parsed ${items.length} categories');
        return items;
      } else {
        throw Exception('Unexpected "data" shape: ${data.runtimeType}');
      }
    } else if (response is List) {
      final items = response.map<CategoryItem>((c) {
        final id = c['_id'] ?? c['id'] ?? '';
        final slug = (c['slug'] ?? c['code'] ?? '').toString();
        final name = (c['name'] ?? c['title'] ?? '').toString();

        return CategoryItem(
          id: id.toString(),
          slug: slug,
          title: name,
          imageUrl: null,
          productCount: null,
        );
      }).toList();
      return items;
    } else {
      throw Exception('Unexpected response type: ${response.runtimeType}');
    }
  }

  // NAVIGATE to CategoryPage
  void _openCategoryProducts(CategoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(topSlug: item.slug, topTitle: item.title),
      ),
    );
  }

  Widget _buildCard(CategoryItem item) {
    final String? localAsset = assetForCategorySlug(item.slug);
    final bool useNetwork = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => _openCategoryProducts(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: useNetwork
                      ? Image.network(item.imageUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                      : (localAsset != null
                      ? Image.asset(localAsset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                      : const Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.productCount != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${item.productCount} items', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.grey.shade100)),
          const SizedBox(height: 10),
          const Text('Coming soon', style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 700 ? 3 : 2;
    const int minTiles = 6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Categories'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: SafeArea(
        child: FutureBuilder<List<CategoryItem>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final err = snapshot.error.toString();
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    const Text('Failed to load top categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(err, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _futureCategories = _fetchTopCategories()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data ?? [];

            final children = <Widget>[];
            for (final it in items) children.add(_buildCard(it));

            while (children.length < minTiles) {
              children.add(_buildPlaceholderCard());
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: children.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (_, index) => children[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
