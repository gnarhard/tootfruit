import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/screens/launch_screen.dart';

void main() {
  group('resolveLaunchBackgroundColor', () {
    test('defaults to peach when query parameter is absent', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/#/toot'),
      );

      expect(color, equals(toots.first.color));
    });

    test('uses fruit color when fruit path parameter is valid', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/banana'),
      );

      expect(color, equals(const Color(0xfffff263)));
    });

    test('uses fruit color from hash-based path parameter', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/#/kiwi'),
      );

      expect(color, equals(const Color(0xffB9CA50)));
    });

    test('falls back to peach when fruit path parameter is unknown', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/dragonfruit'),
      );

      expect(color, equals(toots.first.color));
    });
  });
}
