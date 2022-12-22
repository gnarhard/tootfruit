import 'package:flutter/material.dart';

class AppScreenTitle extends StatelessWidget {
  final Color color;
  final List<Shadow>? shadows;
  const AppScreenTitle({Key? key, required this.color, this.shadows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return Text(
          'TOOT LOOT',
          style: TextStyle(color: color, fontSize: 48, shadows: shadows ?? []),
        );
      }
      if (constraints.maxWidth > 300) {
        return Text(
          'TOOT LOOT',
          style: TextStyle(color: color, fontSize: 26, shadows: shadows ?? []),
        );
      }

      return Text(
        'TOOT LOOT',
        style: TextStyle(color: color, fontSize: 16, shadows: shadows ?? []),
      );
    });
  }
}
