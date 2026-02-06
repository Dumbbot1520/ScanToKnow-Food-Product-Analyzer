// lib/features/onboarding/presentation/intro_page2.dart

import 'package:flutter/material.dart';
import 'intro_page3.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                SizedBox(
                  height: 250,
                  child: Center(
                    child: Image.asset(
                      'images/intro_page_images/intro_page2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  "Know What You Eat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Scan ingredients or barcodes to discover how healthy your food really is.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),

                const SizedBox(height: 50),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, animation, __) => const IntroPage3(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _inactiveDot(),
                    const SizedBox(width: 8),
                    _activeDot(Colors.teal.shade600),
                    const SizedBox(width: 8),
                    _inactiveDot(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeDot(Color color) =>
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _inactiveDot() =>
      Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle));
}
