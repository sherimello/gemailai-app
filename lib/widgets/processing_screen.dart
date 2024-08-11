import 'package:flutter/material.dart';
import 'package:gemailai/widgets/sparkling_dot.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with TickerProviderStateMixin{

  late AnimationController _controller;

  initProcessingAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initProcessingAnimation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "adding magic",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "SF-Pro",
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * .055),
              ),
              SizedBox(
                height: size.width * .05,
              ),
              SizedBox(
                  width: size.width * .05,
                  height: size.width * .05,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ))
            ],
          )),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.height,
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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: size.width,
                height: size.height,
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
          Opacity(
            opacity: .15,
            child: HalftoneBackground(
              dotColor: const Color(0xffffffff),
              dotSize: 2,
              spacing: 7,
              animationDuration: const Duration(milliseconds: 500),
            ),
          ),
          Positioned(
            left: -size.width * .35,
            top: size.height * .75,
            child: Opacity(
              opacity: .5,
              child: SizedBox(
                width: size.width * .95,
                height: size.width * .95,
                child: HalftoneBackground(
                  dotColor: const Color(0xffffffff),
                  dotSize: 2,
                  spacing: 7,
                  animationDuration: const Duration(milliseconds: 500),
                ),
              ),
            ),
          ),
          Positioned(
            right: -size.width * .35,
            bottom: size.height * .75,
            child: Opacity(
              opacity: .5,
              child: SizedBox(
                width: size.width * .95,
                height: size.width * .95,
                child: HalftoneBackground(
                  dotColor: const Color(0xffffffff),
                  dotSize: 2,
                  spacing: 7,
                  animationDuration: const Duration(milliseconds: 500),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: .5,
            child: SizedBox(
              width: size.width * .75,
              height: size.width * .75,
              child: HalftoneBackground(
                dotColor: const Color(0xffffffff),
                dotSize: 2,
                spacing: 7,
                animationDuration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
