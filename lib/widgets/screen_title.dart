import 'package:flutter/material.dart';

class AppScreenTitle extends StatelessWidget {
  final Color color;
  final List<Shadow>? shadows;
  final String title;
  const AppScreenTitle({super.key, required this.color, this.shadows, required this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Text(
          title.toUpperCase(),
          style: TextStyle(color: color, fontSize: 48, shadows: shadows ?? []),
        );
      }
      if (constraints.maxWidth > 300) {
        return Text(
          title.toUpperCase(),
          style: TextStyle(color: color, fontSize: 26, shadows: shadows ?? []),
        );
      }

      return Text(
        title.toUpperCase(),
        style: TextStyle(color: color, fontSize: 18, shadows: shadows ?? []),
      );
    });
  }
}
