import 'package:flutter/cupertino.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:gemailai/widgets/sparkling_dot.dart';

class FeatureCardBackground extends StatefulWidget {
  final IconData icon;
  final String tag;
  final bool isActive;

  const FeatureCardBackground(
      {super.key,
      required this.icon,
      required this.tag,
      required this.isActive});

  @override
  State<FeatureCardBackground> createState() => _FeatureCardBackgroundState();
}

class _FeatureCardBackgroundState extends State<FeatureCardBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller, _controllerActive;
  late Animation<Color?> _colorAnimation1;

  initProcessingAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false);

    _controllerActive = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: false);
  }

  initActiveGradientAnimation() {
    _controllerActive = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Colors.white,
      end: Colors.transparent,
    ).animate(_controllerActive);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    _controllerActive.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initActiveGradientAnimation();
    initProcessingAnimation();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(41),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.width * .5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                    colors: [
                      Colors.purple.withOpacity(0.5),
                      Colors.purple.withOpacity(0.0),
                    ],
                    transform: GradientRotation(
                        _controller.value * 2.0 * 3.141592653589793),
                  ),
                ),
              );
            },
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(41),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.width * .5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    end: Alignment.topLeft,
                    begin: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                    colors: [
                      Colors.cyan.withOpacity(0.5),
                      Colors.cyan.withOpacity(0.0),
                    ],
                    transform: GradientRotation(
                        _controller.value * 2.0 * 3.141592653589793),
                  ),
                ),
              );
            },
          ),
        ),
        Opacity(
          opacity: .5,
          child: HalftoneBackground(
            dotSize: 3,
            spacing: 7,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: size.width * .13,
              color: Colors.white,
            ),
            Text(
              widget.tag,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  height: 0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF-Pro",
                  fontSize: size.width * .031),
            )
          ],
        ),
        Opacity(
          opacity: widget.isActive ? 1 : 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 555),
                width: size.width,
                height: size.width * .5,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(41),
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
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Opacity(
            opacity: widget.isActive ? 1 : 0,
            child: Container(
              width: size.width * .05,
              height: size.width * .05,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: CupertinoColors.activeGreen),
            ),
          ),
        )
      ],
    );
  }
}
