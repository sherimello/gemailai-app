import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class GradientEdgeContainer extends StatefulWidget {
  @override
  _GradientEdgeContainerState createState() => _GradientEdgeContainerState();
}

class _GradientEdgeContainerState extends State<GradientEdgeContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: Colors.green,
      end: Colors.yellow,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 555),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(-10, -10),
                  blurRadius: 60,
                  spreadRadius: 3,
                  blurStyle: BlurStyle.inner,
                  color: _colorAnimation1.value!,
                  inset: true,
                ),
                BoxShadow(
                  offset: const Offset(10, 10),
                  blurRadius: 60,
                  blurStyle: BlurStyle.inner,
                  spreadRadius: 3,
                  color: _colorAnimation1.value!,
                  inset: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GradientEdgePainter extends CustomPainter {
  final Color color1;
  final Color color2;

  GradientEdgePainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Top gradient
    paint.shader = LinearGradient(
      colors: [color1, Colors.transparent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.1));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.1), paint);

    // Bottom gradient
    paint.shader = LinearGradient(
      colors: [Colors.transparent, color2],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1), paint);

    // Left gradient
    paint.shader = LinearGradient(
      colors: [color1, Colors.transparent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width * 0.1, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.1, size.height), paint);

    // Right gradient
    paint.shader = LinearGradient(
      colors: [Colors.transparent, color2],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height));
    canvas.drawRect(Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
