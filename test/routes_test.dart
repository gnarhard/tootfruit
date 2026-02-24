import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

void main() {
  group('normalizeRouteName', () {
    test('normalizes query route names to their path', () {
      expect(
        normalizeRouteName('/toot?fruit=banana'),
        equals(TootScreen.route),
      );
    });

    test('normalizes fragment route names to their fragment path', () {
      expect(
        normalizeRouteName('/#/toot?fruit=banana'),
        equals(TootScreen.route),
      );
    });

    test('falls back to launch route when route name is empty', () {
      expect(normalizeRouteName(''), equals(LaunchScreen.route));
      expect(normalizeRouteName(null), equals(LaunchScreen.route));
    });
  });

  group('onGenerateAppRoute', () {
    test('returns a route for query route names', () {
      final route = onGenerateAppRoute(
        const RouteSettings(name: '/toot?fruit=banana'),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, equals(TootScreen.route));
    });

    test('returns null for unknown route names', () {
      final route = onGenerateAppRoute(
        const RouteSettings(name: '/missing?fruit=banana'),
      );

      expect(route, isNull);
    });
  });

  test('onUnknownAppRoute falls back to launch route', () {
    final route = onUnknownAppRoute(const RouteSettings(name: '/missing'));
    expect(route.settings.name, equals(LaunchScreen.route));
  });
}
