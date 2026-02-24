import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_screen.dart';

import 'test_di_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    resetIntegrationTestDI();
  });

  group('Toot Flow', () {
    testWidgets('all fruits are available and core interactions work', (
      WidgetTester tester,
    ) async {
      final di = await initializeIntegrationTestState(
        tester,
        initialTootIndex: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: di.navigationService.navigatorKey,
          home: const TootScreen(),
          onGenerateRoute: onGenerateAppRoute,
          onUnknownRoute: onUnknownAppRoute,
        ),
      );

      expect(find.byKey(const Key('tootScreen')), findsOneWidget);
      expect(find.text('visit the toot fairy'), findsOneWidget);
      expect(di.tootService.all.length, equals(17));

      await _waitForLiveApp(duration: const Duration(seconds: 1));
      final initialFruit = di.tootService.current.fruit;

      if (kIsWeb) {
        expect(find.byKey(const Key('desktopPrevFruitButton')), findsOneWidget);
        expect(find.byKey(const Key('desktopNextFruitButton')), findsOneWidget);

        final nextButton = find.descendant(
          of: find.byKey(const Key('desktopNextFruitButton')),
          matching: find.byType(IconButton),
        );
        final prevButton = find.descendant(
          of: find.byKey(const Key('desktopPrevFruitButton')),
          matching: find.byType(IconButton),
        );

        await tester.tap(nextButton);
        await _waitForLiveApp();
        expect(di.tootService.current.fruit, isNot(equals(initialFruit)));

        await tester.tap(prevButton);
        await _waitForLiveApp();
        expect(di.tootService.current.fruit, equals(initialFruit));
      } else {
        expect(find.byKey(const Key('desktopPrevFruitButton')), findsNothing);
        expect(find.byKey(const Key('desktopNextFruitButton')), findsNothing);
      }

      await _swipeTootScreen(tester, const Offset(-500, 0));
      await _waitForLiveApp();
      expect(di.tootService.current.fruit, isNot(equals(initialFruit)));

      await _swipeTootScreen(tester, const Offset(500, 0));
      await _waitForLiveApp();
      expect(di.tootService.current.fruit, equals(initialFruit));

      await tester.tap(find.byKey(const Key('visitTootFairyButton')));
      await _waitForLiveApp(duration: const Duration(seconds: 1));
      expect(find.byKey(const Key('tootFairyScreen')), findsOneWidget);
      expect(find.byKey(const Key('tootFairyBackButton')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tootFairyBackButton')));
      await _waitForLiveApp(duration: const Duration(seconds: 1));

      expect(find.byKey(const Key('tootScreen')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}

Future<void> _swipeTootScreen(WidgetTester tester, Offset delta) async {
  await tester.fling(find.byKey(const Key('tootGestureSurface')), delta, 2000);
}
