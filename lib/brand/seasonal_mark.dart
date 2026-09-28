import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Seasonal mark: a paintbrush drawing a stroke.
///
/// Drawn as a vector so it stays crisp at any size and needs no asset bundle.
/// Kept in sync with `brand/logo/mark.svg`.
class SeasonalMark extends StatelessWidget {
  const SeasonalMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 256.0;
    canvas.save();
    canvas.scale(s);

    // The painted swash.
    final paint = Path()
      ..moveTo(22, 216)
      ..cubicTo(40, 200, 62, 192, 86, 184)
      ..cubicTo(112, 175, 132, 164, 146, 148)
      ..cubicTo(150, 144, 153, 141, 156, 139)
      ..cubicTo(153, 156, 145, 174, 128, 190)
      ..cubicTo(106, 212, 72, 226, 42, 228)
      ..cubicTo(32, 229, 24, 224, 22, 216)
      ..close();
    canvas.drawPath(
      paint,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFA9532F), Color(0xFFC97B44), Color(0xFFE0A659)],
        ).createShader(const Rect.fromLTWH(22, 139, 134, 90)),
    );

    // The brush: handle, ferrule, bristles, tilted 38 degrees.
    canvas.save();
    canvas.translate(128, 128);
    canvas.rotate(38 * math.pi / 180);
    canvas.translate(-128, -128);

    canvas.drawPath(
      Path()
        ..moveTo(116, 14)
        ..cubicTo(116, 8, 121, 4, 128, 4)
        ..cubicTo(135, 4, 140, 8, 140, 14)
        ..lineTo(137, 92)
        ..lineTo(119, 92)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF8A6E5A), Color(0xFF5B4A3E)],
        ).createShader(const Rect.fromLTWH(116, 4, 24, 88)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(112, 90, 32, 28),
        const Radius.circular(4),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFC9BEB2), Color(0xFF9A8B7C), Color(0xFF6F6155)],
        ).createShader(const Rect.fromLTWH(112, 90, 32, 28)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(112, 116)
        ..lineTo(144, 116)
        ..lineTo(138, 158)
        ..cubicTo(136, 176, 132, 190, 128, 202)
        ..cubicTo(124, 190, 120, 176, 118, 158)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFD18A4E), Color(0xFFB4633A)],
        ).createShader(const Rect.fromLTWH(112, 116, 32, 86)),
    );

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}
