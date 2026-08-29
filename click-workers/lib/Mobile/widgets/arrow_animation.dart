import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ArrowCircleAnimation extends StatefulWidget {
  final double minWidth;
  final double maxWidth;
  final double height;
  final double iconSize;
  final Color borderColor;
  final double borderWidth;

  const ArrowCircleAnimation({
    super.key,
    this.minWidth = 30,
    this.maxWidth = 40,
    this.height = 30,
    this.iconSize = 22,
    this.borderColor = Colors.grey,
    this.borderWidth = 2.0,
  });

  @override
  State<ArrowCircleAnimation> createState() => _ArrowCircleAnimationState();
}

class _ArrowCircleAnimationState extends State<ArrowCircleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value; // 0..1..0 because repeat(reverse: true)

        // container width follows the animation value (expands then shrinks)
        final width = ui.lerpDouble(widget.minWidth, widget.maxWidth, t)!;

        // --- NEW: symmetric padding inside container ---
        const double padding = 2.0; // applies to left + right
        final available =
            width - (padding * 2) - widget.iconSize; // leave space both sides
        final double clamped = available > 0 ? available : 0;

        // arrow horizontal position (respect both paddings)
        final arrowLeft = padding + t * clamped;

        // IMPORTANT: we reserve the full maxWidth here and anchor the animated
        // inner container to the left. That causes the inner box to grow only
        // to the right (left edge fixed).
        return SizedBox(
          height: widget.height,
          width: widget
              .maxWidth, // reserve full space so expansion goes right only
          child: Align(
            alignment: Alignment.centerLeft, // left-anchored
            child: Container(
              width: width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                border: Border.all(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
                color: Colors.transparent,
              ),
              child: Center(
                child: Stack(
                  children: [
                    Positioned(
                      left: arrowLeft,
                      top: (widget.height - widget.iconSize) / 2,
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: widget.borderColor,
                          size: widget.iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
