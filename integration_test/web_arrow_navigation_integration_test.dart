import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop web arrows navigate between fruits without exceptions', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    await _initializeUnlockedState(tester);
    final tootService = Locator.get<TootService>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: Locator.get<NavigationService>().navigatorKey,
        initialRoute: TootScreen.route,
        routes: routes,
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

    final initialFruit = tootService.current.fruit;

    await tester.tap(nextButton);
    await _waitForLiveApp();
    expect(tester.takeException(), isNull);
    expect(tootService.current.fruit, isNot(equals(initialFruit)));

    await tester.tap(prevButton);
    await _waitForLiveApp();
    expect(tester.takeException(), isNull);
    expect(tootService.current.fruit, equals(initialFruit));

    for (var i = 0; i < 8; i++) {
      await tester.tap(nextButton);
      await _waitForLiveApp();
      expect(tester.takeException(), isNull);
    }

    for (var i = 0; i < 8; i++) {
      await tester.tap(prevButton);
      await _waitForLiveApp();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('keyboard left/right arrows navigate between fruits on web', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    await _initializeUnlockedState(tester);
    final tootService = Locator.get<TootService>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: Locator.get<NavigationService>().navigatorKey,
        initialRoute: TootScreen.route,
        routes: routes,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    final initialFruit = tootService.current.fruit;

    final rightHandled = await tester.sendKeyEvent(
      LogicalKeyboardKey.arrowRight,
    );
    await _waitForLiveApp();
    expect(rightHandled, isTrue);
    expect(tester.takeException(), isNull);

    final nextFruit = tootService.current.fruit;
    expect(nextFruit, isNot(equals(initialFruit)));

    final leftHandled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _waitForLiveApp();
    expect(leftHandled, isTrue);
    expect(tester.takeException(), isNull);
    expect(tootService.current.fruit, equals(initialFruit));

    for (var i = 0; i < 8; i++) {
      final handled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await _waitForLiveApp();
      expect(handled, isTrue);
      expect(tester.takeException(), isNull);
    }

    for (var i = 0; i < 8; i++) {
      final handled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await _waitForLiveApp();
      expect(handled, isTrue);
      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _initializeUnlockedState(WidgetTester tester) async {
  Locator.registerAll();

  final storageService = Locator.get<StorageService>();
  final audioService = Locator.get<AudioService>();
  final userService = Locator.get<UserService>();
  final tootService = Locator.get<TootService>();

  await tester.runAsync(() async {
    await storageService.deleteStorageFile();
    await audioService.init();
    await userService.init();
    await tootService.init();
    await tootService.set(tootService.all[0]);
    await userService.init();
    await tootService.init();
  });
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}
