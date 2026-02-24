import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

void main() {
  group('normalizeRouteName', () {
    test('normalizes query route names to toot route', () {
      expect(
        normalizeRouteName('/toot?fruit=banana'),
        equals(TootScreen.route),
      );
    });

    test('normalizes fragment route names to toot route', () {
      expect(
        normalizeRouteName('/#/toot?fruit=banana'),
        equals(TootScreen.route),
      );
    });

    test('normalizes fruit path routes to toot route', () {
      expect(normalizeRouteName('/strawberry'), equals(TootScreen.route));
      expect(normalizeRouteName('/#/strawberry'), equals(TootScreen.route));
      expect(normalizeRouteName('/toot/strawberry'), equals(TootScreen.route));
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

    test('routes fruit path deep links through launch bootstrap', () {
      final route = onGenerateAppRoute(
        const RouteSettings(name: '/strawberry'),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, equals('/strawberry'));
    });

    test('routes canonical toot fruit deep links through launch bootstrap', () {
      final route = onGenerateAppRoute(
        const RouteSettings(name: '/toot/strawberry'),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, equals('/toot/strawberry'));
    });

    test('routes hash fruit deep links through launch bootstrap', () {
      final route = onGenerateAppRoute(
        const RouteSettings(name: '/#/strawberry'),
      );

      expect(route, isNotNull);
      expect(route!.settings.name, equals('/#/strawberry'));
    });

    test(
      'routes hash canonical toot fruit deep links through launch bootstrap',
      () {
        final route = onGenerateAppRoute(
          const RouteSettings(name: '/#/toot/strawberry'),
        );

        expect(route, isNotNull);
        expect(route!.settings.name, equals('/#/toot/strawberry'));
      },
    );

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
