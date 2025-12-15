import 'package:flutter/material.dart';
import 'intro_page2.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

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

                // 🔥 MATCH IMAGE HEIGHT OF OTHER PAGES
                SizedBox(
                  height: 250,
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 100,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  "Welcome to Scan to Know!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Scan any food product's barcode or ingredients and instantly know its health rating.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration:
                        const Duration(milliseconds: 400),
                        pageBuilder:
                            (_, animation, __) => const IntroPage2(),
                        transitionsBuilder:
                            (_, animation, __, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return FadeTransition(
                            opacity: curved,
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
                    _activeDot(Colors.teal.shade600),
                    const SizedBox(width: 8),
                    _inactiveDot(),
                    const SizedBox(width: 8),
                    _inactiveDot(),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeDot(Color color) => Container(
    width: 12,
    height: 12,
    decoration:
    BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _inactiveDot() => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: Colors.grey[400],
      shape: BoxShape.circle,
    ),
  );
}
