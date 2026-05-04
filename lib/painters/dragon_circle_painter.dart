import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Animates a Bhutanese Thunder Dragon orbiting a central Dharma chakra jewel.
/// [progress] drives every phase: body draw-on (0→1), then head/claws/jewel appear.
class DragonCirclePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  DragonCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final orbitR = size.width * 0.38;

    _drawOuterGlow(canvas, cx, cy, orbitR);
    _drawDecorativeRings(canvas, cx, cy, orbitR);
    _drawDragonBody(canvas, cx, cy, orbitR);
    _drawDragonHead(canvas, cx, cy, orbitR);
    _drawClaws(canvas, cx, cy, orbitR);
    _drawCenterJewel(canvas, cx, cy, orbitR);
  }

  // ── Glow backdrop ─────────────────────────────────────────────────────────

  void _drawOuterGlow(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.25 * progress),
          AppColors.gold.withValues(alpha: 0.08 * progress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.6));
    canvas.drawCircle(Offset(cx, cy), r * 1.6, paint);
  }

  // ── Decorative rings with diamond accents ─────────────────────────────────

  void _drawDecorativeRings(Canvas canvas, double cx, double cy, double r) {
    // Fade rings in during the first half of the animation
    final opacity = (progress * 2).clamp(0.0, 1.0);

    final outerRing = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.5 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), r + 10, outerRing);

    final innerRing = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.25 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cy), r - 18, innerRing);

    // 8 diamond gems on outer ring
    final gemPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.85 * opacity)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final gx = cx + (r + 10) * math.cos(a);
      final gy = cy + (r + 10) * math.sin(a);
      _drawDiamond(canvas, gx, gy, 5, gemPaint);
    }

    // 16 small dots on the inner ring
    final dotPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.4 * opacity);
    for (int i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final dx = cx + (r - 18) * math.cos(a);
      final dy = cy + (r - 18) * math.sin(a);
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }
  }

  void _drawDiamond(Canvas canvas, double x, double y, double s, Paint p) {
    final path = Path()
      ..moveTo(x, y - s)
      ..lineTo(x + s * 0.55, y)
      ..lineTo(x, y + s)
      ..lineTo(x - s * 0.55, y)
      ..close();
    canvas.drawPath(path, p);
  }

  // ── Serpentine dragon body ─────────────────────────────────────────────────

  List<Offset> _buildBodyPoints(double cx, double cy, double r) {
    final pts = <Offset>[];
    // Sweep from -65° (head position) clockwise 345° leaving a gap for the head
    const startDeg = -65.0;
    const sweepDeg = 345.0;
    const segments = 240;

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final angleDeg = startDeg + t * sweepDeg;
      final angle = angleDeg * math.pi / 180;

      // Sinusoidal oscillation creates the serpentine weave — 4.5 cycles
      final oscillation = math.sin(t * math.pi * 4.5) * r * 0.10;
      final pr = r + oscillation;

      pts.add(Offset(cx + pr * math.cos(angle), cy + pr * math.sin(angle)));
    }
    return pts;
  }

  /// Converts point list to a smooth quadratic bezier path.
  Path _pointsToSmoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length - 2; i++) {
      final xMid = (pts[i].dx + pts[i + 1].dx) / 2;
      final yMid = (pts[i].dy + pts[i + 1].dy) / 2;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, xMid, yMid);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  void _drawDragonBody(Canvas canvas, double cx, double cy, double r) {
    final pts = _buildBodyPoints(cx, cy, r);
    final fullPath = _pointsToSmoothPath(pts);

    // _extractPartialPath drives the draw-on animation effect
    final animPath = _extractPartialPath(fullPath, progress);

    // Soft saffron glow beneath the body
    canvas.drawPath(
      animPath,
      Paint()
        ..color = AppColors.saffronDark.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Main gold body
    canvas.drawPath(
      animPath,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );

    // Inner pale highlight
    canvas.drawPath(
      animPath,
      Paint()
        // Pale gold highlight — intentionally not in AppColors (art-only detail)
        ..color = const Color(0xFFF8E070).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Scale arcs appear once body is 25% drawn
    if (progress > 0.25) {
      final scaleT = ((progress - 0.25) / 0.75).clamp(0.0, 1.0);
      _drawScales(canvas, pts, scaleT);
    }

    _drawTailTip(canvas, pts);
  }

  void _drawScales(Canvas canvas, List<Offset> pts, double t) {
    final paint = Paint()
      ..color = AppColors.goldDark.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final limit = (pts.length * t * 0.90).toInt();
    for (int i = 5; i < limit; i += 7) {
      final p = pts[i];
      final prev = pts[(i - 3).clamp(0, pts.length - 1)];
      final next = pts[(i + 3).clamp(0, pts.length - 1)];
      final dx = next.dx - prev.dx;
      final dy = next.dy - prev.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      if (len == 0) continue;

      // Orient arc as a scale bump perpendicular to body direction
      final scaleRect = Rect.fromCenter(center: p, width: 11, height: 7);
      final tangentAngle = math.atan2(dy, dx);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(tangentAngle);
      canvas.translate(-p.dx, -p.dy);
      canvas.drawArc(scaleRect, math.pi, math.pi, false, paint);
      canvas.restore();
    }
  }

  void _drawTailTip(Canvas canvas, List<Offset> pts) {
    if (progress < 0.05) return;
    final tail = pts.last;
    final preTail = pts[pts.length - 8];
    final dx = tail.dx - preTail.dx;
    final dy = tail.dy - preTail.dy;
    final angle = math.atan2(dy, dx);

    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(tail.dx, tail.dy);
    canvas.rotate(angle);
    // Three pointed flame tips fanning out from tail end
    for (int i = -1; i <= 1; i++) {
      final flamePath = Path()
        ..moveTo(0, i * 6.0)
        ..cubicTo(6, i * 5.0, 12, i * 3.0, 16, i * 0.0)
        ..cubicTo(12, i * -1.5, 6, i * -4.0, 0, i * -6.0 + 12 * i);
      canvas.drawPath(flamePath, paint);
    }
    canvas.restore();
  }

  // ── Dragon head ───────────────────────────────────────────────────────────

  void _drawDragonHead(Canvas canvas, double cx, double cy, double r) {
    // Head appears after body is 55% drawn
    final headProgress = ((progress - 0.55) / 0.45).clamp(0.0, 1.0);
    if (headProgress <= 0) return;

    // Fixed at -65° — same start angle as the body path
    const headAngleDeg = -65.0;
    final headAngle = headAngleDeg * math.pi / 180;
    final hx = cx + r * math.cos(headAngle);
    final hy = cy + r * math.sin(headAngle);

    final faceAngle = headAngle - math.pi * 0.18;

    canvas.save();
    canvas.translate(hx, hy);
    canvas.rotate(faceAngle);
    canvas.scale(headProgress);

    final fillPaint = Paint()..color = AppColors.gold..style = PaintingStyle.fill;
    final darkPaint = Paint()..color = AppColors.goldDark..style = PaintingStyle.fill;

    // Upper skull
    final skull = Path()
      ..moveTo(0, 0)
      ..cubicTo(4, -14, 22, -18, 32, -12)
      ..cubicTo(38, -8, 40, -2, 36, 2)
      ..cubicTo(30, 6, 12, 5, 0, 0);
    canvas.drawPath(skull, fillPaint);

    // Snout / upper jaw
    final upper = Path()
      ..moveTo(28, -4)
      ..cubicTo(38, -6, 50, -4, 54, 0)
      ..cubicTo(56, 4, 50, 8, 42, 7)
      ..cubicTo(36, 6, 28, 4, 28, -4);
    canvas.drawPath(upper, fillPaint);

    // Lower jaw (darker to show depth)
    final lower = Path()
      ..moveTo(28, 2)
      ..cubicTo(36, 8, 46, 10, 50, 7)
      ..cubicTo(54, 5, 54, 1, 50, 0)
      ..cubicTo(46, -1, 36, 0, 28, 2);
    canvas.drawPath(lower, darkPaint);

    // Teeth (3 small triangles on upper jaw)
    final toothPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final tx = 32.0 + i * 6;
      final tooth = Path()
        ..moveTo(tx, 3)
        ..lineTo(tx + 2, 8)
        ..lineTo(tx + 4, 3)
        ..close();
      canvas.drawPath(tooth, toothPaint);
    }

    // Eye: dark outer, fire-orange pupil, white glint
    // Art-specific colors kept inline for the iris and pupil details
    canvas.drawCircle(const Offset(18, -10), 4.5,
        Paint()..color = const Color(0xFF1A0000));
    canvas.drawCircle(const Offset(18, -10), 2.5,
        Paint()..color = AppColors.orangeRed);
    canvas.drawCircle(const Offset(18, -10), 1.0,
        Paint()..color = Colors.white.withValues(alpha: 0.8));

    // Flaming brow ridge
    final browPaint = Paint()
      ..color = AppColors.saffronDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final brow = Path()
      ..moveTo(12, -16)
      ..cubicTo(16, -20, 22, -19, 26, -15);
    canvas.drawPath(brow, browPaint);

    // Horn
    final hornPaint = Paint()..color = AppColors.gold..style = PaintingStyle.fill;
    final horn = Path()
      ..moveTo(10, -12)
      ..lineTo(7, -26)
      ..lineTo(13, -22)
      ..lineTo(14, -12);
    canvas.drawPath(horn, hornPaint);

    // Second smaller horn
    final horn2 = Path()
      ..moveTo(18, -14)
      ..lineTo(16, -24)
      ..lineTo(20, -21)
      ..lineTo(21, -14);
    canvas.drawPath(horn2, darkPaint);

    // Whiskers (3 curved lines radiating from snout)
    final whiskerPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final w1 = Path()..moveTo(36, -8)..cubicTo(42, -16, 50, -18, 56, -12);
    final w2 = Path()..moveTo(36, -6)..cubicTo(44, -6, 52, -6, 60, -2);
    final w3 = Path()..moveTo(36, -4)..cubicTo(44, 2, 52, 6, 58, 8);
    canvas.drawPath(w1, whiskerPaint);
    canvas.drawPath(w2, whiskerPaint);
    canvas.drawPath(w3, whiskerPaint);

    // Neck frills
    final frillPaint = Paint()
      ..color = AppColors.saffronDark.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final fx = -4.0 + i * -5;
      final frillPath = Path()
        ..moveTo(fx, -8.0 + i * 2)
        ..cubicTo(fx - 8, -14, fx - 12, -20, fx - 8, -24)
        ..cubicTo(fx - 4, -20, fx - 2, -12, fx, -8 + i * 2);
      canvas.drawPath(frillPath, frillPaint);
    }

    canvas.restore();
  }

  // ── Claws ─────────────────────────────────────────────────────────────────

  void _drawClaws(Canvas canvas, double cx, double cy, double r) {
    // Claws appear after body is 65% drawn
    final clawProgress = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);
    if (clawProgress <= 0) return;

    // Three claw groups at 0° (right), 100° (bottom), 200° (left)
    final positions = [
      (0.0, true),
      (100.0, false),
      (200.0, true),
    ];

    for (final (angleDeg, flipY) in positions) {
      final a = angleDeg * math.pi / 180;
      final clawX = cx + (r + 2) * math.cos(a);
      final clawY = cy + (r + 2) * math.sin(a);
      _drawClawGroup(canvas, clawX, clawY, a + math.pi / 2, flipY, clawProgress);
    }
  }

  void _drawClawGroup(Canvas canvas, double x, double y, double angle,
      bool flipY, double t) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    if (flipY) canvas.scale(1, -1);
    canvas.scale(t);

    final paint = Paint()..color = AppColors.gold..style = PaintingStyle.fill;
    final darkPaint = Paint()..color = AppColors.goldDark..style = PaintingStyle.fill;

    // Palm base
    final palm = Path()
      ..moveTo(-10, 0)
      ..cubicTo(-12, -6, -4, -10, 0, -8)
      ..cubicTo(4, -10, 12, -6, 10, 0)
      ..cubicTo(6, 4, -6, 4, -10, 0);
    canvas.drawPath(palm, paint);

    // Three curved claws
    final offsets = [-7.0, 0.0, 7.0];
    for (int i = 0; i < 3; i++) {
      final ox = offsets[i];
      final claw = Path()
        ..moveTo(ox, -8)
        ..cubicTo(ox - 2, -14, ox - 4, -20, ox, -24)
        ..cubicTo(ox + 3, -20, ox + 3, -14, ox, -8);
      canvas.drawPath(claw, i == 1 ? darkPaint : paint);
    }

    // Thunderbolt jewel in palm — pale gold art detail
    canvas.drawCircle(Offset.zero, 3.5,
        Paint()..color = const Color(0xFFFFF0A0)..style = PaintingStyle.fill);

    canvas.restore();
  }

  // ── Central jewel / Dharma chakra ─────────────────────────────────────────

  void _drawCenterJewel(Canvas canvas, double cx, double cy, double r) {
    // Jewel materialises in the final 30% of animation
    final jewelProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
    if (jewelProgress <= 0) return;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.goldBright.withValues(alpha: 0.85 * jewelProgress),
          AppColors.saffronDark.withValues(alpha: 0.4 * jewelProgress),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.32 * jewelProgress));
    canvas.drawCircle(Offset(cx, cy), r * 0.32 * jewelProgress, glow);

    // 8-spoke Dharma chakra wheel
    final spokePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: jewelProgress * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final innerR = r * 0.15 * jewelProgress;
    final outerR = r * 0.27 * jewelProgress;

    canvas.drawCircle(
        Offset(cx, cy),
        innerR,
        Paint()
          ..color = AppColors.gold.withValues(alpha: jewelProgress * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    canvas.drawCircle(Offset(cx, cy), outerR, spokePaint);

    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(a), cy + innerR * math.sin(a)),
        Offset(cx + outerR * math.cos(a), cy + outerR * math.sin(a)),
        spokePaint,
      );
    }
  }

  // ── Animation helper ──────────────────────────────────────────────────────

  /// Extracts a partial path of length [t * totalLength] for draw-on animation.
  Path _extractPartialPath(Path full, double t) {
    if (t >= 1.0) return full;
    final metrics = full.computeMetrics();
    final result = Path();
    for (final m in metrics) {
      result.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return result;
  }

  @override
  bool shouldRepaint(DragonCirclePainter old) => old.progress != progress;
}
