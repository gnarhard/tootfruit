import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/toot_screen_route.dart';

void main() {
  group('buildInitialTootScreenRoute', () {
    testWidgets('builds a fade route to toot screen', (
      WidgetTester tester,
    ) async {
      final route = buildInitialTootScreenRoute() as PageRouteBuilder<void>;

      expect(route.settings.name, equals(TootScreen.route));
      expect(
        route.transitionDuration,
        equals(const Duration(milliseconds: 240)),
      );
      expect(
        route.reverseTransitionDuration,
        equals(const Duration(milliseconds: 240)),
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(SizedBox));

      final transitionWidget = route.transitionsBuilder(
        context,
        const AlwaysStoppedAnimation<double>(0.5),
        const AlwaysStoppedAnimation<double>(0.0),
        const SizedBox(),
      );

      expect(transitionWidget, isA<FadeTransition>());
      expect((transitionWidget as FadeTransition).opacity.value, equals(0.5));
    });

    testWidgets('supports canonical toot deep-link route names', (
      WidgetTester tester,
    ) async {
      final route =
          buildInitialTootScreenRoute(routeName: '/toot/strawberry')
              as PageRouteBuilder<void>;

      expect(route.settings.name, equals('/toot/strawberry'));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(SizedBox));

      final transitionWidget = route.transitionsBuilder(
        context,
        const AlwaysStoppedAnimation<double>(0.5),
        const AlwaysStoppedAnimation<double>(0.0),
        const SizedBox(),
      );

      expect(transitionWidget, isA<FadeTransition>());
    });
  });
}
