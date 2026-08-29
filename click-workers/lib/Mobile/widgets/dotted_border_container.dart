import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  const DottedBorderContainer({
    super.key,
    required this.child,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: Colors.white,
        child: CustomPaint(
          painter: _DottedBorderPainter(
            strokeWidth: strokeWidth,
            gap: gap,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  _DottedBorderPainter({
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey // ✅ Grey border
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rRect);

    final pathMetrics = path.computeMetrics();

    const dashWidth = 5.0;
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
