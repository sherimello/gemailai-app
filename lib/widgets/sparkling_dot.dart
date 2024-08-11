import 'package:flutter/material.dart';
import 'dart:math';

class HalftoneBackground extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;

  HalftoneBackground({
    this.dotColor = Colors.grey,
    this.dotSize = 10,
    this.spacing = 20,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  _HalftoneBackgroundState createState() => _HalftoneBackgroundState();
}

class _HalftoneBackgroundState extends State<HalftoneBackground> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HalftonePainter(
        _animationController,
        dotColor: widget.dotColor,
        dotSize: widget.dotSize,
        spacing: widget.spacing,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class HalftonePainter extends CustomPainter {
  final AnimationController _animationController;
  final Color dotColor;
  final double dotSize;
  final double spacing;

  HalftonePainter(
      this._animationController, {
        required this.dotColor,
        required this.dotSize,
        required this.spacing,
      }) : super(repaint: _animationController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rows = size.height ~/ spacing;
    final cols = size.width ~/ spacing;
    final offset = _animationController.value * spacing;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        final x = j * spacing + offset;
        final y = i * spacing + offset;
        final distanceFromCenter = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
        final opacity = 1 - (distanceFromCenter / (size.width / 2));
        paint.color = dotColor.withOpacity(opacity.clamp(0, 1));
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}