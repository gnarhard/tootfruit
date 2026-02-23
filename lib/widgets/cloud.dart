import 'package:flutter/material.dart';

class Cloud extends StatelessWidget {
  const Cloud({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Image.asset(
          'assets/images/cloud_simple.png',
          width: constraints.maxWidth * .8,
        );
      }

      if (constraints.maxWidth > 400) {
        return Image.asset(
          'assets/images/cloud_simple.png',
          width: constraints.maxWidth,
        );
      }

      // Smallest screen size.
      return Image.asset(
        'assets/images/cloud_simple.png',
        width: constraints.maxWidth * .8,
      );
    });
  }
}
