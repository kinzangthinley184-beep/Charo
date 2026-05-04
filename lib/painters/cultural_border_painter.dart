import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Paints a subtle Bhutanese-inspired endless-knot corner and border pattern.
class CulturalBorderPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const CulturalBorderPainter({
    this.color = AppColors.gold,
    this.opacity = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawCornerKnot(canvas, paint, size, Corner.topLeft);
    _drawCornerKnot(canvas, paint, size, Corner.topRight);
    _drawCornerKnot(canvas, paint, size, Corner.bottomLeft);
    _drawCornerKnot(canvas, paint, size, Corner.bottomRight);
    _drawBorderDots(canvas, paint, size);
  }

  void _drawCornerKnot(Canvas canvas, Paint p, Size size, Corner c) {
    const knotSize = 60.0;
    double ox, oy;
    double rotAngle;

    switch (c) {
      case Corner.topLeft:
        ox = 0; oy = 0; rotAngle = 0;
      case Corner.topRight:
        ox = size.width; oy = 0; rotAngle = math.pi / 2;
      case Corner.bottomLeft:
        ox = 0; oy = size.height; rotAngle = -math.pi / 2;
      case Corner.bottomRight:
        ox = size.width; oy = size.height; rotAngle = math.pi;
    }

    canvas.save();
    canvas.translate(ox, oy);
    canvas.rotate(rotAngle);

    // Outer L-frame
    final frame = Path()
      ..moveTo(0, knotSize)
      ..lineTo(0, 8)
      ..cubicTo(0, 2, 2, 0, 8, 0)
      ..lineTo(knotSize, 0);
    canvas.drawPath(frame, p);

    // Inner square spiral — endless knot (Bhutanese auspicious symbol)
    final knot = Path()
      ..moveTo(12, 12)
      ..lineTo(12, 36)
      ..lineTo(36, 36)
      ..lineTo(36, 12)
      ..lineTo(20, 12)
      ..lineTo(20, 28)
      ..lineTo(28, 28)
      ..lineTo(28, 20)
      ..lineTo(22, 20)
      ..lineTo(22, 26)
      ..lineTo(26, 26)
      ..lineTo(26, 22);
    canvas.drawPath(knot, p);

    // Corner flower petals
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final cx2 = 10 + 6 * math.cos(a);
      final cy2 = 10 + 6 * math.sin(a);
      canvas.drawCircle(Offset(cx2, cy2), 3, p..style = PaintingStyle.fill);
    }
    p.style = PaintingStyle.stroke;

    canvas.restore();
  }

  void _drawBorderDots(Canvas canvas, Paint p, Size size) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const dotR = 1.5;

    for (double x = 80; x < size.width - 70; x += spacing) {
      canvas.drawCircle(Offset(x, 16), dotR, dotPaint);
    }
    for (double x = 80; x < size.width - 70; x += spacing) {
      canvas.drawCircle(Offset(x, size.height - 16), dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CulturalBorderPainter old) =>
      old.color != color || old.opacity != opacity;
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }
