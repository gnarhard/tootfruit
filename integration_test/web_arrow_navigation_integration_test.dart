import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop web arrows navigate between fruits without exceptions', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    final di = await _initializeUnlockedState(tester);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
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

    final initialFruit = di.tootService.current.fruit;

    await tester.tap(nextButton);
    await _waitForLiveApp();
    expect(tester.takeException(), isNull);
    expect(di.tootService.current.fruit, isNot(equals(initialFruit)));

    await tester.tap(prevButton);
    await _waitForLiveApp();
    expect(tester.takeException(), isNull);
    expect(di.tootService.current.fruit, equals(initialFruit));

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

    final di = await _initializeUnlockedState(tester);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
        initialRoute: TootScreen.route,
        routes: routes,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    final initialFruit = di.tootService.current.fruit;

    final rightHandled = await tester.sendKeyEvent(
      LogicalKeyboardKey.arrowRight,
    );
    await _waitForLiveApp();
    expect(rightHandled, isTrue);
    expect(tester.takeException(), isNull);

    final nextFruit = di.tootService.current.fruit;
    expect(nextFruit, isNot(equals(initialFruit)));

    final leftHandled = await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _waitForLiveApp();
    expect(leftHandled, isTrue);
    expect(tester.takeException(), isNull);
    expect(di.tootService.current.fruit, equals(initialFruit));

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

Future<DI> _initializeUnlockedState(WidgetTester tester) async {
  final di = DI();
  di.initialize();

  await tester.runAsync(() async {
    final storage = di.storageRepository as FileStorageRepository;
    await storage.deleteStorageFile();
    await di.audioPlayer.init();
    await di.userRepository.loadUser();
    await di.tootService.init();
    await di.tootService.set(di.tootService.all[0]);
    await di.userRepository.loadUser();
    await di.tootService.init();
  });

  return di;
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}
