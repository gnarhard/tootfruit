import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tootfruit/widgets/toot_fairy.dart';

class RotatingFruits extends StatefulWidget {
  const RotatingFruits({super.key});

  @override
  State<RotatingFruits> createState() => _RotatingFruitsState();
}

class _RotatingFruitsState extends State<RotatingFruits>
    with TickerProviderStateMixin {
  static const _fruitRotationSpeed = Duration(seconds: 10);

  late final AnimationController _fruitRotationController = AnimationController(
    duration: _fruitRotationSpeed,
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _fruitRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return AnimatedBuilder(
          animation: _fruitRotationController,
          child: Image.asset('assets/images/all_fruits.png', width: width),
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle:
                  _fruitRotationController.value *
                  TootFairy.fairyRotationSecondsSpeed *
                  math.pi,
              child: child,
            );
          },
        );
      },
    );
  }
}
