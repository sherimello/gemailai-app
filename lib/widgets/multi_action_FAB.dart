import 'dart:math';

import 'package:flutter/material.dart';

class MultiActionFAB extends StatefulWidget {
  final List<ActionButton> actions;

  MultiActionFAB({required this.actions});

  @override
  _MultiActionFABState createState() => _MultiActionFABState();
}

class _MultiActionFABState extends State<MultiActionFAB> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.actions.map((action) => _buildActionButton(action)),
        FloatingActionButton(
          onPressed: () {
            if (_controller.isCompleted) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 0.5 * pi,
                child: child,
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ActionButton action) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -50 * _animation.value,
          ),
          child: child,
        );
      },
      child: action,
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}