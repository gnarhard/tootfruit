import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FruitAsset extends StatelessWidget {
  final String fruit;
  final Key? svgKey;

  const FruitAsset({super.key, required this.fruit, this.svgKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SvgPicture.asset(
        'assets/images/fruit/$fruit.svg',
        key: svgKey,
        fit: BoxFit.contain,
      ),
    );
  }
}
