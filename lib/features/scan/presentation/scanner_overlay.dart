// // lib/features/scan/presentation/scanner_overlay.dart
// import 'package:flutter/material.dart';
//
// class ScannerOverlay extends StatelessWidget {
//   const ScannerOverlay({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Dark overlay
//         Positioned.fill(
//           child: Container(color: Colors.black.withOpacity(0.55)),
//         ),
//
//         // Scan window
//         Center(
//           child: Container(
//             width: 260,
//             height: 160,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//           ),
//         ),
//
//         // Hint text
//         Positioned(
//           bottom: 120,
//           left: 0,
//           right: 0,
//           child: Column(
//             children: const [
//               Text(
//                 'Align the barcode inside the frame',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'Scanning automatically',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


// lib/features/scan/presentation/scanner_overlay.dart

import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final Animation<double> laserAnimation;

  const ScannerOverlay({super.key, required this.laserAnimation});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerPainter(laserAnimation),
      child: Container(),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final Animation<double> animation;

  _ScannerPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);

    final cutOutSize = size.width * 0.7;
    final left = (size.width - cutOutSize) / 2;
    final top = (size.height - cutOutSize) / 2;

    final cutOutRect = Rect.fromLTWH(left, top, cutOutSize, cutOutSize);

    // Dark background
    final background = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(
      RRect.fromRectXY(cutOutRect, 16, 16),
    );

    final overlay = Path.combine(PathOperation.difference, background, hole);
    canvas.drawPath(overlay, overlayPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectXY(cutOutRect, 16, 16),
      borderPaint,
    );

    // Laser
    final laserY =
        top + (cutOutSize * animation.value);

    final laserPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(left + 10, laserY),
      Offset(left + cutOutSize - 10, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
