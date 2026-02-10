// lib/main.dart

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Onboarding
// import 'features/onboarding/presentation/intro_page1.dart';
//
// // Home
// import 'features/home/presentation/home_page.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const Scan2KnowApp());
// }
//
// class Scan2KnowApp extends StatelessWidget {
//   const Scan2KnowApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Scan2Know',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         useMaterial3: true,
//       ),
//       home: const _AppEntry(),
//     );
//   }
// }
//
// class _AppEntry extends StatelessWidget {
//   const _AppEntry();
//
//   Future<bool> _hasSeenIntro() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('intro_seen') ?? false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _hasSeenIntro(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         final seenIntro = snapshot.data!;
//
//         return seenIntro ? const HomePage() : const IntroPage1();
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding
import 'features/onboarding/presentation/intro_page1.dart';

// Home
import 'features/home/presentation/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 TEMPORARY FIX: reset intro flag for testing
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('intro_seen');

  runApp(const Scan2KnowApp());
}

class Scan2KnowApp extends StatelessWidget {
  const Scan2KnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan2Know',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  Future<bool> _hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('intro_seen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenIntro(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final seenIntro = snapshot.data!;

        return seenIntro ? const HomePage() : const IntroPage1();
      },
    );
  }
}
