// lib/features/home/presentation/home_page.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../../core/network/api_service.dart';
// import '../../../core/ui/widgets/top_header.dart';
// import '../../../core/ui/widgets/top_categories.dart';
// import '../../../core/ui/widgets/bottom_nav_bar.dart';
//
// // REAL pages
// import '../../categories/presentation/top_categories_page.dart';
// import '../../categories/presentation/category_page.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _selectedTab = 0;
//
//   // --------------------------------------------------
//   // Fetch top-level categories (level = 1)
//   // --------------------------------------------------
//   Future<List<CategoryItem>> _fetchTopCategories() async {
//     final response = await ApiService.get(
//       '/v1/categories?level=1&limit=6',
//     );
//
//     // DEBUG (keep)
//     // ignore: avoid_print
//     print('HomePage: raw response -> $response');
//
//     if (response is Map && response['data'] is List) {
//       final List data = response['data'];
//
//       final items = data.map<CategoryItem>((c) {
//         return CategoryItem(
//           id: (c['_id'] ?? '').toString(),
//           slug: (c['slug'] ?? '').toString(),
//           title: (c['name'] ?? '').toString(),
//           imageUrl: null, // backend has no images
//           productCount: null,
//         );
//       }).toList();
//
//       // ignore: avoid_print
//       print('HomePage: parsed ${items.length} top categories');
//
//       return items;
//     }
//
//     throw Exception('Invalid category response shape');
//   }
//
//   // --------------------------------------------------
//   // Navigation helpers
//   // --------------------------------------------------
//
//   void _openSearch() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const Scaffold(
//           body: Center(
//             child: Text('Search page (backend pending)'),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// View All / Bottom-nav Categories
//   void _openTopCategories() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const TopCategoriesPage(),
//       ),
//     );
//   }
//
//   /// Tap on a top category tile
//   void _openCategory(CategoryItem category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CategoryPage(
//           topSlug: category.slug,
//           topTitle: category.title,
//         ),
//       ),
//     );
//   }
//
//   // --------------------------------------------------
//   // UI
//   // --------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.teal,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.teal.shade50,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Header
//               TopHeader(
//                 avatarAsset: 'images/home_page_images/user_logo.png',
//                 onSearchTap: _openSearch,
//               ),
//
//               const SizedBox(height: 18),
//
//               // -----------------------------
//               // Top Categories Section
//               // -----------------------------
//               FutureBuilder<List<CategoryItem>>(
//                 future: _fetchTopCategories(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Padding(
//                       padding: EdgeInsets.all(24),
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//
//                   if (snapshot.hasError) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Failed to load categories',
//                             style: TextStyle(color: Colors.red.shade700),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             snapshot.error.toString(),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () => setState(() {}),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   final categories = snapshot.data ?? [];
//
//                   return TopCategories(
//                     categories: categories,
//                     onViewAll: _openTopCategories,
//                     onCategoryTap: _openCategory,
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 20),
//
//               // -----------------------------
//               // Promo carousel (unchanged)
//               // -----------------------------
//               SizedBox(
//                 height: 200,
//                 child: PageView.builder(
//                   controller: PageController(viewportFraction: 0.9),
//                   itemCount: 3,
//                   itemBuilder: (context, index) {
//                     final title = switch (index) {
//                       0 => 'Say hello to Awareness',
//                       1 => 'ScanToKnow — Rewards',
//                       _ => 'Eat Well. Live Well.',
//                     };
//
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.teal.shade100,
//                           borderRadius: BorderRadius.circular(18),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.04),
//                               blurRadius: 8,
//                             )
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     title,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   const Text(
//                                     'Tap to learn more',
//                                     style: TextStyle(fontSize: 13),
//                                   ),
//                                   const Spacer(),
//                                   ElevatedButton(
//                                     onPressed: _openTopCategories,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.teal.shade600,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Explore',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               width: 72,
//                               height: 72,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//
//       // -----------------------------
//       // Bottom Navigation
//       // -----------------------------
//       bottomNavigationBar: BottomNavBar(
//         selectedIndex: _selectedTab,
//         onTabSelected: (index) {
//           setState(() => _selectedTab = index);
//
//           if (index == 1) _openSearch();
//           if (index == 3) _openTopCategories();
//         },
//       ),
//     );
//   }
// }


// lib/features/home/presentation/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/api_service.dart';
import '../../../core/ui/widgets/top_header.dart';
import '../../../core/ui/widgets/top_categories.dart';
import '../../../core/ui/widgets/bottom_nav_bar.dart';

// Pages
import '../../categories/presentation/top_categories_page.dart';
import '../../categories/presentation/category_page.dart';
import '../../scan/presentation/barcode_scan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  // --------------------------------------------------
  // Fetch top-level categories (level = 1)
  // --------------------------------------------------
  Future<List<CategoryItem>> _fetchTopCategories() async {
    final response = await ApiService.get(
      '/v1/categories?level=1&limit=6',
    );

    // Debug
    // ignore: avoid_print
    print('HomePage: raw response -> $response');

    if (response is Map && response['data'] is List) {
      final List data = response['data'];

      return data.map<CategoryItem>((c) {
        return CategoryItem(
          id: (c['_id'] ?? '').toString(),
          slug: (c['slug'] ?? '').toString(),
          title: (c['name'] ?? '').toString(),
          imageUrl: null,
          productCount: null,
        );
      }).toList();
    }

    throw Exception('Invalid category response shape');
  }

  // --------------------------------------------------
  // Navigation helpers
  // --------------------------------------------------

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Search page (backend pending)'),
          ),
        ),
      ),
    );
  }

  void _openScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScanPage(),
      ),
    );
  }

  void _openTopCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TopCategoriesPage(),
      ),
    );
  }

  void _openCategory(CategoryItem category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(
          topSlug: category.slug,
          topTitle: category.title,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.teal,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              TopHeader(
                avatarAsset: 'images/home_page_images/user_logo.png',
                onSearchTap: _openSearch,
              ),

              const SizedBox(height: 18),

              // Top Categories
              FutureBuilder<List<CategoryItem>>(
                future: _fetchTopCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            'Failed to load categories',
                            style: TextStyle(
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style:
                            const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  return TopCategories(
                    categories: categories,
                    onViewAll: _openTopCategories,
                    onCategoryTap: _openCategory,
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // --------------------------------------------------
      // Bottom Navigation (ROUTING LIVES HERE)
      // --------------------------------------------------
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedTab,
        onTabSelected: (index) {
          setState(() => _selectedTab = index);

          if (index == 1) _openSearch();
          if (index == 2) _openScan();          // ✅ Scan
          if (index == 3) _openTopCategories(); // ✅ Categories
        },
      ),
    );
  }
}
