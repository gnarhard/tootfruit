import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('desktop web arrows navigate between fruits', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    final di = await initializeIntegrationTestState(tester);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
        home: const TootScreen(),
        onGenerateRoute: onGenerateAppRoute,
        onUnknownRoute: onUnknownAppRoute,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    expect(find.byKey(const Key('desktopNextFruitButton')), findsOneWidget);
    expect(find.byKey(const Key('desktopPrevFruitButton')), findsOneWidget);

    final nextButton = find.descendant(
      of: find.byKey(const Key('desktopNextFruitButton')),
      matching: find.byType(IconButton),
    );
    final prevButton = find.descendant(
      of: find.byKey(const Key('desktopPrevFruitButton')),
      matching: find.byType(IconButton),
    );

    final initialFruit = di.tootService.current.fruit;

    await tester.tap(nextButton);
    await _waitForLiveApp();
    expect(di.tootService.current.fruit, isNot(equals(initialFruit)));

    await tester.tap(prevButton);
    await _waitForLiveApp();
    expect(di.tootService.current.fruit, equals(initialFruit));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard left/right arrows navigate between fruits on web', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    final di = await initializeIntegrationTestState(tester);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
        home: const TootScreen(),
        onGenerateRoute: onGenerateAppRoute,
        onUnknownRoute: onUnknownAppRoute,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    final initialFruit = di.tootService.current.fruit;

    await _sendKeyPress(tester, LogicalKeyboardKey.arrowRight);
    await _waitForLiveApp();
    final nextFruit = di.tootService.current.fruit;
    expect(nextFruit, isNot(equals(initialFruit)));

    await _sendKeyPress(tester, LogicalKeyboardKey.arrowLeft);
    await _waitForLiveApp();
    expect(di.tootService.current.fruit, equals(initialFruit));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _sendKeyPress(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}
