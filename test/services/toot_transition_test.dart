import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/services/toot_transition.dart';

void main() {
  group('linearFruitTransitionProgress', () {
    test('returns full progress when fruit does not change', () {
      final progress = linearFruitTransitionProgress(
        fromFruit: 'peach',
        toFruit: 'peach',
        animationValue: 0.2,
      );

      expect(progress, equals(1.0));
    });

    test('keeps animation progress linear when fruit changes', () {
      final progress = linearFruitTransitionProgress(
        fromFruit: 'peach',
        toFruit: 'banana',
        animationValue: 0.35,
      );

      expect(progress, equals(0.35));
    });
  });

  group('lerpFruitPageColor', () {
    test('linearly interpolates color channels at midpoint', () {
      const fromColor = Color(0xFF000000);
      const toColor = Color(0xFFFFFFFF);
      final color = lerpFruitPageColor(
        fromColor: const Color(0xFF000000),
        toColor: const Color(0xFFFFFFFF),
        progress: 0.5,
      );

      expect(color, equals(Color.lerp(fromColor, toColor, 0.5)));
    });

    test('clamps progress values outside of [0, 1]', () {
      final low = lerpFruitPageColor(
        fromColor: const Color(0xFF112233),
        toColor: const Color(0xFF445566),
        progress: -4.0,
      );
      final high = lerpFruitPageColor(
        fromColor: const Color(0xFF112233),
        toColor: const Color(0xFF445566),
        progress: 5.0,
      );

      expect(low, equals(const Color(0xFF112233)));
      expect(high, equals(const Color(0xFF445566)));
    });
  });

  group('fadeInFruitScale', () {
    test('starts smaller and scales to full size linearly', () {
      final atStart = fadeInFruitScale(progress: 0.0);
      final atMid = fadeInFruitScale(progress: 0.5);
      final atEnd = fadeInFruitScale(progress: 1.0);

      expect(atStart, equals(0.82));
      expect(atMid, closeTo(0.91, 0.000001));
      expect(atEnd, equals(1.0));
    });

    test('clamps scale progress outside [0, 1]', () {
      final below = fadeInFruitScale(progress: -2.0);
      final above = fadeInFruitScale(progress: 3.0);

      expect(below, equals(0.82));
      expect(above, equals(1.0));
    });
  });

  group('fadeInFruitRotationRadians', () {
    test('starts rotated and linearly settles at zero', () {
      final atStart = fadeInFruitRotationRadians(progress: 0.0);
      final atMid = fadeInFruitRotationRadians(progress: 0.5);
      final atEnd = fadeInFruitRotationRadians(progress: 1.0);

      expect(atStart, closeTo(2.1991, 0.0001));
      expect(atMid, closeTo(1.0995, 0.0001));
      expect(atEnd, equals(0.0));
    });

    test('clamps rotation progress outside [0, 1]', () {
      final below = fadeInFruitRotationRadians(progress: -1.0);
      final above = fadeInFruitRotationRadians(progress: 2.0);

      expect(below, closeTo(2.1991, 0.0001));
      expect(above, equals(0.0));
    });
  });
}
