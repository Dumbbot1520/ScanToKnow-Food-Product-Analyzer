import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialCoach {
  // We define the controller here so the helper methods can access it
  static TutorialCoachMark? _controller;

  static Future<void> showBottomNavTutorial(
      BuildContext context, {
        required GlobalKey homeKey,
        required GlobalKey searchKey,
        required GlobalKey scanKey,
        required GlobalKey categoriesKey,
        required GlobalKey uploadKey,
        required GlobalKey smartReadKey,
        bool forceShow = true,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('bottomNavTutorialSeen') ?? false;
    if (seen && !forceShow) return;

    final List<TargetFocus> targets = [
      _buildTarget("Home", homeKey, Icons.home_rounded, "Home", "Return to your dashboard.", ContentAlign.bottom),
      _buildTarget("Search", searchKey, Icons.search_rounded, "Search", "Find products or ingredients.", ContentAlign.top),
      _buildTarget("Scan", scanKey, Icons.qr_code_scanner_rounded, "Scan", "Scan a barcode for instant info.", ContentAlign.top),
      _buildTarget("Categories", categoriesKey, Icons.grid_view_rounded, "Categories", "Browse food collections.", ContentAlign.top),
      _buildTarget("Upload", uploadKey, Icons.cloud_upload_rounded, "Upload", "Request a product detail.", ContentAlign.top),
      _buildTarget("SmartRead", smartReadKey, Icons.document_scanner_rounded, "Smart Read", "Extract info using OCR.", ContentAlign.top),
    ];

    await Future.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;

    _controller = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      paddingFocus: 8,
      textSkip: "SKIP",
      opacityShadow: 0.8,

      // THE "NO ZOOM" SECRET:
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: Duration.zero, // Prevents the 'shrink' before moving
      pulseEnable: false,

      onFinish: () => prefs.setBool('bottomNavTutorialSeen', true),
      onSkip: () {
        prefs.setBool('bottomNavTutorialSeen', true);
        return true;
      },
    );

    _controller!.show(context: context);
  }

  static TargetFocus _buildTarget(String id, GlobalKey key, IconData icon, String title, String msg, ContentAlign align) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      contents: [
        TargetContent(
          align: align,
          child: _tutorialCard(icon: icon, title: title, message: msg),
        ),
      ],
    );
  }

  static Widget _tutorialCard({required IconData icon, required String title, required String message}) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 1),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          // --- THE NEXT BUTTON ---
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _controller?.next(),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text("Next >", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}