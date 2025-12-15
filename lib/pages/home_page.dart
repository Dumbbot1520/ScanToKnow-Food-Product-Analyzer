// // import 'package:main_project_files/widgets/top_header.dart';
// // import 'package:main_project_files/pages/profile_page.dart';
// // import 'package:main_project_files/widgets/top_categories.dart';
// // import 'package:main_project_files/widgets/bottom_nav_unused.dart';
// //
// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});
// //
// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }
// //
// // class _HomePageState extends State<HomePage> {
// //   int _selectedTab = 0;
// //
// //   void _onTabSelected(int index) {
// //     // Keep selected tab stored so bottomNav can reflect initialIndex if needed
// //     setState(() => _selectedTab = index);
// //
// //     // Navigate to placeholder pages for non-home tabs
// //     switch (index) {
// //       case 0:
// //       // Home — already here, do nothing
// //         break;
// //       case 1:
// //         Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
// //         break;
// //       case 2:
// //         Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
// //         break;
// //       case 3:
// //         Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()));
// //         break;
// //       case 4:
// //         Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPage()));
// //         break;
// //       case 5:
// //         Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartReadPage()));
// //         break;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey.shade50,
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               TopHeader(
// //                 avatarAsset: 'images/home_page_images/user_logo.png',
// //                 onAvatarTap: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(builder: (context) => const ProfilePage()),
// //                   );
// //                 },
// //               ),
// //
// //               const SizedBox(height: 18),
// //
// //               // Top categories row
// //               TopCategories(
// //                 onCategoryTap: (id, title) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(content: Text('$title tapped (placeholder)')),
// //                   );
// //                 },
// //               ),
// //
// //               const SizedBox(height: 18),
// //
// //               // Advertisement carousel (placeholder)
// //               SizedBox(
// //                 height: 150,
// //                 child: PageView.builder(
// //                   controller: PageController(viewportFraction: 0.9),
// //                   itemCount: 3,
// //                   itemBuilder: (context, index) {
// //                     return Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
// //                       child: GestureDetector(
// //                         onTap: () {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text('Ad ${index + 1} tapped (placeholder)')),
// //                           );
// //                         },
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             color: index == 0 ? Colors.deepPurple.shade50 : Colors.deepPurple.shade100,
// //                             borderRadius: BorderRadius.circular(18),
// //                             boxShadow: [
// //                               BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
// //                             ],
// //                           ),
// //                           padding: const EdgeInsets.all(16),
// //                           child: Row(
// //                             children: [
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       index == 0 ? 'Say hello to TIA' : (index == 1 ? 'Using Truthin — Rewards' : 'Eat Well. Live Well.'),
// //                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                                     ),
// //                                     const SizedBox(height: 8),
// //                                     const Text(
// //                                       'Tap to learn more (placeholder)',
// //                                       style: TextStyle(fontSize: 13),
// //                                     ),
// //                                     const Spacer(),
// //                                     ElevatedButton(
// //                                       onPressed: () {
// //                                         ScaffoldMessenger.of(context).showSnackBar(
// //                                           SnackBar(content: Text('CTA on ad ${index + 1} tapped (placeholder)')),
// //                                         );
// //                                       },
// //                                       style: ElevatedButton.styleFrom(
// //                                         backgroundColor: Colors.deepPurple,
// //                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
// //                                       ),
// //                                       child: const Text('Explore'),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 8),
// //                               // right-side placeholder box
// //                               Container(
// //                                 width: 72,
// //                                 height: 72,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(12),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 24),
// //
// //               // Weekly Healthy Picks heading
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   children: const [
// //                     Expanded(
// //                       child: Text(
// //                         'Weekly Healthy Picks',
// //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 12),
// //
// //               // Placeholder grid
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: GridView.builder(
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   shrinkWrap: true,
// //                   itemCount: 4,
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 2,
// //                     childAspectRatio: 1.6,
// //                     mainAxisSpacing: 12,
// //                     crossAxisSpacing: 12,
// //                   ),
// //                   itemBuilder: (context, index) {
// //                     return Container(
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Container(width: 48, height: 48, color: Colors.grey.shade200),
// //                           const SizedBox(width: 12),
// //                           const Expanded(child: Text('Healthy Pick', style: TextStyle(fontSize: 14))),
// //                         ],
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 80), // leave space for nav
// //             ],
// //           ),
// //         ),
// //       ),
// //
// //       bottomNavigationBar: BottomNavBar(
// //         initialIndex: _selectedTab,
// //         onTabSelected: _onTabSelected,
// //       ),
// //     );
// //   }
// // }
// //
// // /* ---------------------------------------------------------------------------
// //    Below are simple placeholder pages for Search, Scan, Categories, Upload and SmartRead.
// //    Each is intentionally minimal so you can replace with real implementations later.
// //    --------------------------------------------------------------------------- */
// //
// // class SearchPage extends StatelessWidget {
// //   const SearchPage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Search')),
// //       body: const Center(
// //         child: Text(
// //           'Search page (placeholder)\nImplement search UI later.',
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class ScanPage extends StatelessWidget {
// //   const ScanPage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Scan Product')),
// //       body: const Center(
// //         child: Text(
// //           'Scan Product (placeholder)\nReplace with your mobile scanner page when ready.',
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class CategoriesPage extends StatelessWidget {
// //   const CategoriesPage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('All Categories')),
// //       body: const Center(
// //         child: Text(
// //           'Categories page (placeholder)\nDisplay all categories here later.',
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class UploadPage extends StatelessWidget {
// //   const UploadPage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Upload Product')),
// //       body: const Center(
// //         child: Text(
// //           'Upload page (placeholder)\nImplement product upload / request flow here.',
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class SmartReadPage extends StatelessWidget {
// //   const SmartReadPage({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Smart Read')),
// //       body: const Center(
// //         child: Text(
// //           'Smart Read (OCR) placeholder\nThis will run OCR on images and extract ingredients/nutrition.',
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // lib/pages/home_page.dart
// import 'package:flutter/material.dart';
// import 'package:main_project_files/widgets/top_header.dart';
// import 'package:main_project_files/pages/profile_page.dart';
// import 'package:main_project_files/widgets/top_categories.dart';
// import 'package:main_project_files/widgets/bottom_nav_unused.dart';
// import 'package:main_project_files/pages/drinks_page.dart';
// import 'package:flutter/services.dart';
// import 'package:main_project_files/pages/tutorial_page.dart';
//
//
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   DateTime? _lastPressed;
//
//   Future<bool> _onBackPressed() async {
//     final now = DateTime.now();
//
//     // If user hasn't pressed back in last 2 seconds, show message
//     if (_lastPressed == null ||
//         now.difference(_lastPressed!) > const Duration(seconds: 2)) {
//       _lastPressed = now;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.deepPurple, // purple background
//           behavior: SnackBarBehavior.floating, // floating style (more visible)
//           margin: const EdgeInsets.all(16),   // spacing from edges
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           content: const Text(
//             "Press back again to exit",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           duration: Duration(seconds: 2),
//         ),
//       );
//
//
//       return false; // do NOT exit yet
//     }
//
//     SystemNavigator.pop();
//     return false;
//     // exit the app
//   }
//
//   int _selectedTab = 0;
//
//   // Tutorial target keys (used by tutorial_page.dart)
//   final GlobalKey _homeNavKey = GlobalKey();
//   final GlobalKey _searchNavKey = GlobalKey();
//   final GlobalKey _scanNavKey = GlobalKey();
//   final GlobalKey _categoriesNavKey = GlobalKey();
//   final GlobalKey _uploadNavKey = GlobalKey();
//   final GlobalKey _smartReadNavKey = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Run tutorial after first frame. Change forceShow to true while testing.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       TutorialCoach.showBottomNavTutorial(
//         context,
//         homeKey: _homeNavKey,
//         searchKey: _searchNavKey,
//         scanKey: _scanNavKey,
//         categoriesKey: _categoriesNavKey,
//         uploadKey: _uploadNavKey,
//         smartReadKey: _smartReadNavKey,
//         // forceShow: true, // uncomment during development to ignore saved prefs
//       );
//     });
//   }
//
//
//   void _onTabSelected(int index) {
//     // Keep selected tab stored so bottomNav can reflect initialIndex if needed
//     setState(() => _selectedTab = index);
//
//     // Navigate to placeholder pages for non-home tabs (these pages exist in your repo)
//     switch (index) {
//       case 0:
//       // Home — already here, do nothing
//         break;
//       case 1:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
//         break;
//       case 2:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
//         break;
//       case 3:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()));
//         break;
//       case 4:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPage()));
//         break;
//       case 5:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartReadPage()));
//         break;
//     }
//   }
//
//   // Helper: navigate to DrinksPage, optionally with an initialCategory
//   void _openDrinks({String? initialCategory}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => DrinksPage(initialCategory: initialCategory)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.deepPurple, // match your header color
//         statusBarIconBrightness: Brightness.dark,    // icons (time/battery) remain readable
//       ),
//     );
//
//     return WillPopScope(
//       onWillPop: _onBackPressed,   // <-- added this line
//       child: Scaffold(
//         backgroundColor: Colors.deepPurple.shade100,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TopHeader(
//                   avatarAsset: 'images/home_page_images/user_logo.png',
//                   onAvatarTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ProfilePage()),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Top categories row — when tapped, open DrinksPage and pass the title
//                 TopCategories(
//                   onCategoryTap: (id, title) {
//                     _openDrinks(initialCategory: title);
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Advertisement carousel — tap navigates to Drinks (example)
//                 SizedBox(
//                   height: 200,
//                   child: PageView.builder(
//                     controller: PageController(viewportFraction: 0.9),
//                     itemCount: 3,
//                     itemBuilder: (context, index) {
//                       final headline = index == 0
//                           ? 'Say hello to Awareness'
//                           : (index == 1 ? 'Using ScanToKnow — Rewards' : 'Eat Well. Live Well.');
//                       final sub = 'Tap to learn more (placeholder)';
//
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             _openDrinks();
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.deepPurple.shade50,
//                               borderRadius: BorderRadius.circular(18),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
//                               ],
//                             ),
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         headline,
//                                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         sub,
//                                         style: const TextStyle(fontSize: 13),
//                                       ),
//                                       const Spacer(),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _openDrinks();
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.deepPurple,
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                                         ),
//                                         child: const Text(
//                                           'Explore',
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//
//                                 Container(
//                                   width: 72,
//                                   height: 72,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Weekly Healthy Picks heading
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                         child: Text(
//                           'Weekly Healthy Picks',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Placeholder grid
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.6,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                     ),
//                     itemBuilder: (context, index) {
//                       return Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(width: 48, height: 48, color: Colors.grey.shade200),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text('Healthy Pick', style: TextStyle(fontSize: 14)),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//
//         bottomNavigationBar: BottomNavBar(
//           initialIndex: _selectedTab,
//           onTabSelected: _onTabSelected,
//           homeKey: _homeNavKey,
//           searchKey: _searchNavKey,
//           scanKey: _scanNavKey,
//           categoriesKey: _categoriesNavKey,
//           uploadKey: _uploadNavKey,
//           smartReadKey: _smartReadNavKey,
//         ),
//       ),
//     );
//
//   }
// }
//
// /* ---------------------------------------------------------------------------
//    Placeholder pages referenced from bottom nav. You already have these files in
//    your project; the placeholders exist so the home page compiles and runs.
//    --------------------------------------------------------------------------- */
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search')),
//       body: const Center(
//         child: Text(
//           'Search page (placeholder)\nImplement search UI later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class ScanPage extends StatelessWidget {
//   const ScanPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan Product')),
//       body: const Center(
//         child: Text(
//           'Scan Product (placeholder)\nReplace with your mobile scanner page when ready.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Categories')),
//       body: const Center(
//         child: Text(
//           'Categories page (placeholder)\nDisplay all categories here later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class UploadPage extends StatelessWidget {
//   const UploadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Product')),
//       body: const Center(
//         child: Text(
//           'Upload page (placeholder)\nImplement product upload / request flow here.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class SmartReadPage extends StatelessWidget {
//   const SmartReadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Smart Read')),
//       body: const Center(
//         child: Text(
//           'Smart Read (OCR) placeholder\nThis will run OCR on images and extract ingredients/nutrition.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:main_project_files/widgets/top_header.dart';
// import 'package:main_project_files/pages/profile_page.dart';
// import 'package:main_project_files/widgets/top_categories.dart';
// import 'package:main_project_files/widgets/bottom_nav_unused.dart';
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
//   void _onTabSelected(int index) {
//     // Keep selected tab stored so bottomNav can reflect initialIndex if needed
//     setState(() => _selectedTab = index);
//
//     // Navigate to placeholder pages for non-home tabs
//     switch (index) {
//       case 0:
//       // Home — already here, do nothing
//         break;
//       case 1:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
//         break;
//       case 2:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
//         break;
//       case 3:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesPage()));
//         break;
//       case 4:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPage()));
//         break;
//       case 5:
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartReadPage()));
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TopHeader(
//                 avatarAsset: 'images/home_page_images/user_logo.png',
//                 onAvatarTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const ProfilePage()),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 18),
//
//               // Top categories row
//               TopCategories(
//                 onCategoryTap: (id, title) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('$title tapped (placeholder)')),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 18),
//
//               // Advertisement carousel (placeholder)
//               SizedBox(
//                 height: 150,
//                 child: PageView.builder(
//                   controller: PageController(viewportFraction: 0.9),
//                   itemCount: 3,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Ad ${index + 1} tapped (placeholder)')),
//                           );
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: index == 0 ? Colors.deepPurple.shade50 : Colors.deepPurple.shade100,
//                             borderRadius: BorderRadius.circular(18),
//                             boxShadow: [
//                               BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       index == 0 ? 'Say hello to TIA' : (index == 1 ? 'Using Truthin — Rewards' : 'Eat Well. Live Well.'),
//                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     const Text(
//                                       'Tap to learn more (placeholder)',
//                                       style: TextStyle(fontSize: 13),
//                                     ),
//                                     const Spacer(),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         ScaffoldMessenger.of(context).showSnackBar(
//                                           SnackBar(content: Text('CTA on ad ${index + 1} tapped (placeholder)')),
//                                         );
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.deepPurple,
//                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                                       ),
//                                       child: const Text('Explore'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // right-side placeholder box
//                               Container(
//                                 width: 72,
//                                 height: 72,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Weekly Healthy Picks heading
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: const [
//                     Expanded(
//                       child: Text(
//                         'Weekly Healthy Picks',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Placeholder grid
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: 4,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 1.6,
//                     mainAxisSpacing: 12,
//                     crossAxisSpacing: 12,
//                   ),
//                   itemBuilder: (context, index) {
//                     return Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(width: 48, height: 48, color: Colors.grey.shade200),
//                           const SizedBox(width: 12),
//                           const Expanded(child: Text('Healthy Pick', style: TextStyle(fontSize: 14))),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 80), // leave space for nav
//             ],
//           ),
//         ),
//       ),
//
//       bottomNavigationBar: BottomNavBar(
//         initialIndex: _selectedTab,
//         onTabSelected: _onTabSelected,
//       ),
//     );
//   }
// }
//
// /* ---------------------------------------------------------------------------
//    Below are simple placeholder pages for Search, Scan, Categories, Upload and SmartRead.
//    Each is intentionally minimal so you can replace with real implementations later.
//    --------------------------------------------------------------------------- */
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search')),
//       body: const Center(
//         child: Text(
//           'Search page (placeholder)\nImplement search UI later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class ScanPage extends StatelessWidget {
//   const ScanPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan Product')),
//       body: const Center(
//         child: Text(
//           'Scan Product (placeholder)\nReplace with your mobile scanner page when ready.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Categories')),
//       body: const Center(
//         child: Text(
//           'Categories page (placeholder)\nDisplay all categories here later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class UploadPage extends StatelessWidget {
//   const UploadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Product')),
//       body: const Center(
//         child: Text(
//           'Upload page (placeholder)\nImplement product upload / request flow here.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class SmartReadPage extends StatelessWidget {
//   const SmartReadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Smart Read')),
//       body: const Center(
//         child: Text(
//           'Smart Read (OCR) placeholder\nThis will run OCR on images and extract ingredients/nutrition.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

// lib/pages/home_page.dart
// import 'package:main_project_files/scan/barcode/BarcodeScannerPage.dart';
// import 'package:main_project_files/scan/ocr/OCRScanPage.dart';
// import 'package:flutter/material.dart';
// import 'package:main_project_files/widgets/top_header.dart';
// import 'package:main_project_files/pages/profile_page.dart';
// import 'package:main_project_files/widgets/top_categories.dart';
// import 'package:main_project_files/widgets/bottom_nav.dart';
// import 'package:main_project_files/pages/drinks_page.dart';
// import 'package:flutter/services.dart';
// import 'package:main_project_files/pages/tutorial_page.dart';
//
//
//
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   DateTime? _lastPressed;
//
//   Future<bool> _onBackPressed() async {
//     final now = DateTime.now();
//
//     // If user hasn't pressed back in last 2 seconds, show message
//     if (_lastPressed == null ||
//         now.difference(_lastPressed!) > const Duration(seconds: 2)) {
//       _lastPressed = now;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.deepPurple, // purple background
//           behavior: SnackBarBehavior.floating, // floating style (more visible)
//           margin: const EdgeInsets.all(16),   // spacing from edges
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           content: const Text(
//             "Press back again to exit",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           duration: Duration(seconds: 2),
//         ),
//       );
//
//
//       return false; // do NOT exit yet
//     }
//
//     SystemNavigator.pop();
//     return false;
//     // exit the app
//   }
//
//   int _selectedTab = 0;
//
//   // Tutorial target keys (used by tutorial_page.dart)
//   final GlobalKey _homeNavKey = GlobalKey();
//   final GlobalKey _searchNavKey = GlobalKey();
//   final GlobalKey _scanNavKey = GlobalKey();
//   final GlobalKey _categoriesNavKey = GlobalKey();
//   final GlobalKey _uploadNavKey = GlobalKey();
//   final GlobalKey _smartReadNavKey = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Run tutorial after first frame. Change forceShow to true while testing.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       TutorialCoach.showBottomNavTutorial(
//         context,
//         homeKey: _homeNavKey,
//         searchKey: _searchNavKey,
//         scanKey: _scanNavKey,
//         categoriesKey: _categoriesNavKey,
//         uploadKey: _uploadNavKey,
//         smartReadKey: _smartReadNavKey,
//         // forceShow: true, // uncomment during development to ignore saved prefs
//       );
//     });
//   }
//
//
//   void _onTabSelected(int index) {
//     setState(() => _selectedTab = index);
//
//     switch (index) {
//       case 0:
//         break;
//
//       case 1:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const SearchPage()));
//         break;
//
//       case 2: // 🔥 SCAN → BARCODE
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const BarcodeScannerPage()));
//         break;
//
//       case 3:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const CategoriesPage()));
//         break;
//
//       case 4:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const UploadPage()));
//         break;
//
//       case 5: // 🔥 SMART READ → OCR
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const OCRScanPage()));
//         break;
//     }
//   }
//
//
//   // Helper: navigate to DrinksPage, optionally with an initialCategory
//   void _openDrinks({String? initialCategory}) {
//     print("➡️ NAVIGATE → DrinksPage | category: $initialCategory");
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => DrinksPage(initialCategory: initialCategory)),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.deepPurple, // match your header color
//         statusBarIconBrightness: Brightness.dark,    // icons (time/battery) remain readable
//       ),
//     );
//
//     return WillPopScope(
//       onWillPop: _onBackPressed,   // <-- added this line
//       child: Scaffold(
//         backgroundColor: Colors.deepPurple.shade100,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TopHeader(
//                   avatarAsset: 'images/home_page_images/user_logo.png',
//                   onAvatarTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ProfilePage()),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Top categories row — when tapped, open DrinksPage and pass the title
//                 TopCategories(
//                   onCategoryTap: (id, title) {
//                     _openDrinks(initialCategory: title);
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Advertisement carousel — tap navigates to Drinks (example)
//                 SizedBox(
//                   height: 200,
//                   child: PageView.builder(
//                     controller: PageController(viewportFraction: 0.9),
//                     itemCount: 3,
//                     itemBuilder: (context, index) {
//                       final headline = index == 0
//                           ? 'Say hello to Awareness'
//                           : (index == 1 ? 'Using ScanToKnow — Rewards' : 'Eat Well. Live Well.');
//                       final sub = 'Tap to learn more (placeholder)';
//
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             _openDrinks();
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.deepPurple.shade50,
//                               borderRadius: BorderRadius.circular(18),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
//                               ],
//                             ),
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         headline,
//                                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         sub,
//                                         style: const TextStyle(fontSize: 13),
//                                       ),
//                                       const Spacer(),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _openDrinks();
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.deepPurple,
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                                         ),
//                                         child: const Text(
//                                           'Explore',
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//
//                                 Container(
//                                   width: 72,
//                                   height: 72,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Weekly Healthy Picks heading
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                         child: Text(
//                           'Weekly Healthy Picks',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Placeholder grid
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.6,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                     ),
//                     itemBuilder: (context, index) {
//                       return Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(width: 48, height: 48, color: Colors.grey.shade200),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text('Healthy Pick', style: TextStyle(fontSize: 14)),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//
//         bottomNavigationBar: BottomNavBar(
//           initialIndex: _selectedTab,
//           onTabSelected: _onTabSelected,
//           homeKey: _homeNavKey,
//           searchKey: _searchNavKey,
//           scanKey: _scanNavKey,
//           categoriesKey: _categoriesNavKey,
//           uploadKey: _uploadNavKey,
//           smartReadKey: _smartReadNavKey,
//         ),
//       ),
//     );
//
//   }
// }
//
// /* ---------------------------------------------------------------------------
//    Placeholder pages referenced from bottom nav. You already have these files in
//    your project; the placeholders exist so the home page compiles and runs.
//    --------------------------------------------------------------------------- */
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search')),
//       body: const Center(
//         child: Text(
//           'Search page (placeholder)\nImplement search UI later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class ScanPage extends StatelessWidget {
//   const ScanPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan Product')),
//       body: const Center(
//         child: Text(
//           'Scan Product (placeholder)\nReplace with your mobile scanner page when ready.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Categories')),
//       body: const Center(
//         child: Text(
//           'Categories page (placeholder)\nDisplay all categories here later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class UploadPage extends StatelessWidget {
//   const UploadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Product')),
//       body: const Center(
//         child: Text(
//           'Upload page (placeholder)\nImplement product upload / request flow here.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class SmartReadPage extends StatelessWidget {
//   const SmartReadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Smart Read')),
//       body: const Center(
//         child: Text(
//           'Smart Read (OCR) placeholder\nThis will run OCR on images and extract ingredients/nutrition.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }



// import 'package:main_project_files/scan/barcode/BarcodeScannerPage.dart';
// import 'package:main_project_files/scan/ocr/OCRScanPage.dart';
// import 'package:flutter/material.dart';
// import 'package:main_project_files/widgets/top_header.dart';
// import 'package:main_project_files/pages/profile_page.dart';
// import 'package:main_project_files/widgets/top_categories.dart';
// import 'package:main_project_files/widgets/bottom_nav.dart';
// import 'package:main_project_files/pages/drinks_page.dart';
// import 'package:flutter/services.dart';
// import 'package:main_project_files/pages/tutorial_page.dart';
//
//
//
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   DateTime? _lastPressed;
//
//   Future<bool> _onBackPressed() async {
//     final now = DateTime.now();
//
//     // If user hasn't pressed back in last 2 seconds, show message
//     if (_lastPressed == null ||
//         now.difference(_lastPressed!) > const Duration(seconds: 2)) {
//       _lastPressed = now;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.deepPurple, // purple background
//           behavior: SnackBarBehavior.floating, // floating style (more visible)
//           margin: const EdgeInsets.all(16),   // spacing from edges
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           content: const Text(
//             "Press back again to exit",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           duration: Duration(seconds: 2),
//         ),
//       );
//
//
//       return false; // do NOT exit yet
//     }
//
//     SystemNavigator.pop();
//     return false;
//     // exit the app
//   }
//
//   int _selectedTab = 0;
//
//   // Tutorial target keys (used by tutorial_page.dart)
//   final GlobalKey _homeNavKey = GlobalKey();
//   final GlobalKey _searchNavKey = GlobalKey();
//   final GlobalKey _scanNavKey = GlobalKey();
//   final GlobalKey _categoriesNavKey = GlobalKey();
//   final GlobalKey _uploadNavKey = GlobalKey();
//   final GlobalKey _smartReadNavKey = GlobalKey();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Run tutorial after first frame. Change forceShow to true while testing.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       TutorialCoach.showBottomNavTutorial(
//         context,
//         homeKey: _homeNavKey,
//         searchKey: _searchNavKey,
//         scanKey: _scanNavKey,
//         categoriesKey: _categoriesNavKey,
//         uploadKey: _uploadNavKey,
//         smartReadKey: _smartReadNavKey,
//         // forceShow: true, // uncomment during development to ignore saved prefs
//       );
//     });
//   }
//
//
//   void _onTabSelected(int index) {
//     setState(() => _selectedTab = index);
//
//     switch (index) {
//       case 0:
//         break;
//
//       case 1:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const SearchPage()));
//         break;
//
//       case 2: // 🔥 SCAN → BARCODE
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const BarcodeScannerPage()));
//         break;
//
//       case 3:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const CategoriesPage()));
//         break;
//
//       case 4:
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const UploadPage()));
//         break;
//
//       case 5: // 🔥 SMART READ → OCR
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const OCRScanPage()));
//         break;
//     }
//   }
//
//
//   // Helper: navigate to DrinksPage, optionally with an initialCategory
//   void _openDrinks({String? initialCategory}) {
//     print("➡️ NAVIGATE → DrinksPage | category: $initialCategory");
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => DrinksPage(initialCategory: initialCategory)),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.deepPurple, // match your header color
//         statusBarIconBrightness: Brightness.dark,    // icons (time/battery) remain readable
//       ),
//     );
//
//     return WillPopScope(
//       onWillPop: _onBackPressed,   // <-- added this line
//       child: Scaffold(
//         backgroundColor: Colors.deepPurple.shade100,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TopHeader(
//                   avatarAsset: 'images/home_page_images/user_logo.png',
//                   onAvatarTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ProfilePage()),
//                     );
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Top categories row — when tapped, open DrinksPage and pass the title
//                 TopCategories(
//                   onCategoryTap: (id, title) {
//                     _openDrinks(initialCategory: title);
//                   },
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // Advertisement carousel — tap navigates to Drinks (example)
//                 SizedBox(
//                   height: 200,
//                   child: PageView.builder(
//                     controller: PageController(viewportFraction: 0.9),
//                     itemCount: 3,
//                     itemBuilder: (context, index) {
//                       final headline = index == 0
//                           ? 'Say hello to Awareness'
//                           : (index == 1 ? 'Using ScanToKnow — Rewards' : 'Eat Well. Live Well.');
//                       final sub = 'Tap to learn more (placeholder)';
//
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             _openDrinks();
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.deepPurple.shade50,
//                               borderRadius: BorderRadius.circular(18),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
//                               ],
//                             ),
//                             padding: const EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         headline,
//                                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         sub,
//                                         style: const TextStyle(fontSize: 13),
//                                       ),
//                                       const Spacer(),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _openDrinks();
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.deepPurple,
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                                         ),
//                                         child: const Text(
//                                           'Explore',
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//
//                                 Container(
//                                   width: 72,
//                                   height: 72,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Weekly Healthy Picks heading
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: const [
//                       Expanded(
//                         child: Text(
//                           'Weekly Healthy Picks',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Placeholder grid
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.6,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                     ),
//                     itemBuilder: (context, index) {
//                       return Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(width: 48, height: 48, color: Colors.grey.shade200),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text('Healthy Pick', style: TextStyle(fontSize: 14)),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//
//         bottomNavigationBar: BottomNavBar(
//           initialIndex: _selectedTab,
//           onTabSelected: _onTabSelected,
//           homeKey: _homeNavKey,
//           searchKey: _searchNavKey,
//           scanKey: _scanNavKey,
//           categoriesKey: _categoriesNavKey,
//           uploadKey: _uploadNavKey,
//           smartReadKey: _smartReadNavKey,
//         ),
//       ),
//     );
//
//   }
// }
//
// /* ---------------------------------------------------------------------------
//    Placeholder pages referenced from bottom nav. You already have these files in
//    your project; the placeholders exist so the home page compiles and runs.
//    --------------------------------------------------------------------------- */
//
// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Search')),
//       body: const Center(
//         child: Text(
//           'Search page (placeholder)\nImplement search UI later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class CategoriesPage extends StatelessWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Categories')),
//       body: const Center(
//         child: Text(
//           'Categories page (placeholder)\nDisplay all categories here later.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class UploadPage extends StatelessWidget {
//   const UploadPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Product')),
//       body: const Center(
//         child: Text(
//           'Upload page (placeholder)\nImplement product upload / request flow here.',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:main_project_files/scan/barcode/BarcodeScannerPage.dart';
import 'package:main_project_files/scan/ocr/OCRScanPage.dart';

import 'package:main_project_files/widgets/top_header.dart';
import 'package:main_project_files/widgets/top_categories.dart';
import 'package:main_project_files/widgets/bottom_nav.dart';

import 'package:main_project_files/pages/profile_page.dart';
import 'package:main_project_files/pages/drinks_page.dart';
import 'package:main_project_files/pages/tutorial_page.dart';

// 👇 IMPORTANT: alias added here
import 'package:main_project_files/pages/product_detail_page.dart'
as details;

import 'package:main_project_files/services/fetch_product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  DateTime? _lastPressed;

  final GlobalKey _homeNavKey = GlobalKey();
  final GlobalKey _searchNavKey = GlobalKey();
  final GlobalKey _scanNavKey = GlobalKey();
  final GlobalKey _categoriesNavKey = GlobalKey();
  final GlobalKey _uploadNavKey = GlobalKey();
  final GlobalKey _smartReadNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialCoach.showBottomNavTutorial(
        context,
        homeKey: _homeNavKey,
        searchKey: _searchNavKey,
        scanKey: _scanNavKey,
        categoriesKey: _categoriesNavKey,
        uploadKey: _uploadNavKey,
        smartReadKey: _smartReadNavKey,
      );
    });
  }

  Future<bool> _onBackPressed() async {
    final now = DateTime.now();
    if (_lastPressed == null ||
        now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Press back again to exit")),
      );
      return false;
    }
    SystemNavigator.pop();
    return false;
  }

  // ✅ BARCODE → FETCH → REAL PRODUCT DETAIL PAGE
  Future<void> _handleBarcode(String barcode) async {
    try {
      final product = await fetchProduct(barcode);

      if (!mounted) return;

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product not found")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              details.ProductDetailPage(productData: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching product: $e")),
      );
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BarcodeScannerPage(
              onDetect: _handleBarcode,
            ),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesPage()),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadPage()),
        );
        break;

      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OCRScanPage()),
        );
        break;
    }
  }

  void _openDrinks({String? initialCategory}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrinksPage(initialCategory: initialCategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.teal,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          backgroundColor: Colors.teal.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TopHeader(
                  avatarAsset: 'images/home_page_images/user_logo.png',
                  onAvatarTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                const SizedBox(height: 18),
                TopCategories(
                  onCategoryTap: (id, title) {
                    _openDrinks(initialCategory: title);
                  },
                ),
                const SizedBox(height: 20),
                // ------------------ Advertisement Carousel ------------------
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final headline = index == 0
                          ? 'Say hello to Awareness'
                          : (index == 1
                          ? 'Using ScanToKnow — Rewards'
                          : 'Eat Well. Live Well.');

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            _openDrinks();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        headline,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Tap to learn more',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: _openDrinks,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade600,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'Explore',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

// ------------------ Weekly Healthy Picks ------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Weekly Healthy Picks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Healthy Pick',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 80),

              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          initialIndex: _selectedTab,
          onTabSelected: _onTabSelected,
          homeKey: _homeNavKey,
          searchKey: _searchNavKey,
          scanKey: _scanNavKey,
          categoriesKey: _categoriesNavKey,
          uploadKey: _uploadNavKey,
          smartReadKey: _smartReadNavKey,
        ),
      ),
    );
  }
}

/* -------- PLACEHOLDERS -------- */

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Search placeholder")));
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Categories placeholder")));
}

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Upload placeholder")));
}
