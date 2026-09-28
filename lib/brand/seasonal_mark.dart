import 'package:flutter/material.dart';
import 'package:seasonal/brand/palette.dart';

/// The Seasonal mark: a brush tip that has painted a leaf.
///
/// Drawn as a vector so it stays crisp at any size and needs no asset bundle.
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

    final leaf = Path()
      ..moveTo(128, 28)
      ..cubicTo(178, 54, 202, 112, 184, 162)
      ..cubicTo(174, 192, 150, 208, 128, 212)
      ..cubicTo(106, 208, 82, 192, 72, 162)
      ..cubicTo(54, 112, 78, 54, 128, 28)
      ..close();
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: SeasonalColors.leafGradient,
        ).createShader(const Rect.fromLTWH(72, 28, 112, 184)),
    );

    final vein = Paint()
      ..color = SeasonalColors.paper.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(128, 52)
        ..cubicTo(133, 100, 133, 158, 128, 198),
      vein..strokeWidth = 8,
    );
    canvas.drawPath(
      Path()
        ..moveTo(128, 92)
        ..cubicTo(110, 104, 98, 118, 92, 136),
      vein..strokeWidth = 6,
    );
    canvas.drawPath(
      Path()
        ..moveTo(128, 92)
        ..cubicTo(146, 104, 158, 118, 164, 136),
      vein..strokeWidth = 6,
    );

    // Ferrule band.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(90, 196, 76, 14),
        const Radius.circular(5),
      ),
      Paint()..color = SeasonalColors.bark,
    );
    // Bristles.
    canvas.drawPath(
      Path()
        ..moveTo(96, 210)
        ..lineTo(160, 210)
        ..lineTo(150, 234)
        ..lineTo(106, 234)
        ..close(),
      Paint()..color = SeasonalColors.ember,
    );
    // Tip.
    canvas.drawPath(
      Path()
        ..moveTo(106, 234)
        ..lineTo(150, 234)
        ..lineTo(128, 252)
        ..close(),
      Paint()..color = SeasonalColors.ink,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}
