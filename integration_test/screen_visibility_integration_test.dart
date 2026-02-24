import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Unlocked Toot Flow', () {
    testWidgets(
      'all fruits are unlocked, restore loads last fruit, and gestures/taps work',
      (WidgetTester tester) async {
        await _initializeUnlockedState(tester);
        final tootService = Locator.get<TootService>();
        final routeSpy = _RouteSpy();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: Locator.get<NavigationService>().navigatorKey,
            initialRoute: TootScreen.route,
            routes: routes,
            navigatorObservers: [routeSpy],
          ),
        );

        expect(find.byKey(const Key('tootScreen')), findsOneWidget);
        expect(tootService.owned.length, equals(tootService.all.length));
        expect(tootService.ownsEveryToot, isTrue);
        expect(find.text('visit the toot fairy'), findsOneWidget);
        expect(tootService.current.fruit, equals(tootService.all[4].fruit));

        await _waitForLiveApp(duration: const Duration(seconds: 1));
        expect(tootService.current.fruit, equals(tootService.all[4].fruit));

        if (kIsWeb) {
          expect(
            find.byKey(const Key('desktopPrevFruitButton')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('desktopNextFruitButton')),
            findsOneWidget,
          );

          final nextButton = find.descendant(
            of: find.byKey(const Key('desktopNextFruitButton')),
            matching: find.byType(IconButton),
          );
          final prevButton = find.descendant(
            of: find.byKey(const Key('desktopPrevFruitButton')),
            matching: find.byType(IconButton),
          );

          final currentFruit = tootService.current.fruit;
          await tester.tap(nextButton);
          await _waitForLiveApp();
          expect(tootService.current.fruit, isNot(equals(currentFruit)));

          await tester.tap(prevButton);
          await _waitForLiveApp();
        } else {
          expect(find.byKey(const Key('desktopPrevFruitButton')), findsNothing);
          expect(find.byKey(const Key('desktopNextFruitButton')), findsNothing);
        }

        await _swipeTootScreen(tester, const Offset(-500, 0));
        await _waitForLiveApp();

        await _swipeTootScreen(tester, const Offset(500, 0));
        await _waitForLiveApp();

        final visitFairyButton = find.byKey(const Key('visitTootFairyButton'));
        await tester.tap(visitFairyButton);
        await _waitForLiveApp(duration: const Duration(seconds: 2));

        expect(routeSpy.pushedRoutes.contains(TootFairyScreen.route), isTrue);
      },
    );

    testWidgets(
      'toot fairy has back button, no monetization controls, and back returns to toot',
      (WidgetTester tester) async {
        await _initializeUnlockedState(tester);
        final routeSpy = _RouteSpy();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: Locator.get<NavigationService>().navigatorKey,
            initialRoute: TootFairyScreen.route,
            routes: routes,
            navigatorObservers: [routeSpy],
          ),
        );

        expect(find.byKey(const Key('tootFairyScreen')), findsOneWidget);
        expect(find.byKey(const Key('tootFairyBackButton')), findsOneWidget);

        expect(find.text('FRUITS'), findsNothing);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.text('COLLECT MORE'), findsNothing);
        expect(find.text('BUY ALL'), findsNothing);
        expect(find.textContaining('watch ad'), findsNothing);

        await tester.tap(find.byKey(const Key('tootFairyBackButton')));
        await _waitForLiveApp(duration: const Duration(seconds: 1));

        expect(routeSpy.replacedRoutes.contains(TootScreen.route), isTrue);
      },
    );
  });
}

class _RouteSpy extends NavigatorObserver {
  final pushedRoutes = <String?>[];
  final replacedRoutes = <String?>[];

  @override
  void didPush(Route route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedRoutes.add(newRoute?.settings.name);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
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
    await tootService.set(tootService.all[4]);
    await userService.init();
    await tootService.init();
  });
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}

Future<void> _swipeTootScreen(WidgetTester tester, Offset delta) async {
  final center = tester.getCenter(find.byKey(const Key('tootGestureSurface')));
  final gesture = await tester.startGesture(center);
  await gesture.moveBy(delta, timeStamp: const Duration(milliseconds: 10));
  await gesture.up(timeStamp: const Duration(milliseconds: 20));
}
