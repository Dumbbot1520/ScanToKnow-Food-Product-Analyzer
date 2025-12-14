// lib/utils/ingredient_box_painter.dart
import 'package:flutter/material.dart';

class IngredientBoxPainter extends CustomPainter {
  final double leftPct;
  final double topPct;
  final double widthPct;
  final double heightPct;

  IngredientBoxPainter({
    required this.leftPct,
    required this.topPct,
    required this.widthPct,
    required this.heightPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * leftPct,
      size.height * topPct,
      size.width * widthPct,
      size.height * heightPct,
    );

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
