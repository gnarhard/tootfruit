import 'package:flutter/material.dart';

double linearFruitTransitionProgress({
  required String fromFruit,
  required String toFruit,
  required double animationValue,
}) {
  if (fromFruit == toFruit) {
    return 1.0;
  }
  return animationValue.clamp(0.0, 1.0);
}

Color lerpFruitPageColor({
  required Color fromColor,
  required Color toColor,
  required double progress,
}) {
  final clampedProgress = progress.clamp(0.0, 1.0);
  return Color.lerp(fromColor, toColor, clampedProgress) ?? toColor;
}

double fadeInFruitScale({required double progress, double minScale = 0.82}) {
  final clampedProgress = progress.clamp(0.0, 1.0);
  return minScale + (1.0 - minScale) * clampedProgress;
}

double fadeInFruitRotationRadians({
  required double progress,
  double turns = 0.35,
}) {
  final clampedProgress = progress.clamp(0.0, 1.0);
  return (1.0 - clampedProgress) * turns * 2 * 3.1415926535897932;
}
