import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Unlocked Toot Flow', () {
    testWidgets(
      'all fruits available, restore loads last fruit, and gestures/taps work',
      (WidgetTester tester) async {
        final di = await _initializeState(tester);
        final routeSpy = _RouteSpy();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: di.navigationService.navigatorKey,
            initialRoute: TootScreen.route,
            routes: routes,
            navigatorObservers: [routeSpy],
          ),
        );

        expect(find.byKey(const Key('tootScreen')), findsOneWidget);
        expect(find.text('visit the toot fairy'), findsOneWidget);
        expect(
          di.tootService.current.fruit,
          equals(di.tootService.all[4].fruit),
        );

        await _waitForLiveApp(duration: const Duration(seconds: 1));
        expect(
          di.tootService.current.fruit,
          equals(di.tootService.all[4].fruit),
        );

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

          final currentFruit = di.tootService.current.fruit;
          await tester.tap(nextButton);
          await _waitForLiveApp();
          expect(di.tootService.current.fruit, isNot(equals(currentFruit)));

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
        final di = await _initializeState(tester);
        final routeSpy = _RouteSpy();

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: di.navigationService.navigatorKey,
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

Future<DI> _initializeState(WidgetTester tester) async {
  final di = DI();
  di.initialize();

  await tester.runAsync(() async {
    final storage = di.storageRepository as FileStorageRepository;
    await storage.deleteStorageFile();
    await di.audioPlayer.init();
    await di.userRepository.loadUser();
    await di.tootService.init();
    await di.tootService.set(di.tootService.all[4]);
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

Future<void> _swipeTootScreen(WidgetTester tester, Offset delta) async {
  final center = tester.getCenter(find.byKey(const Key('tootGestureSurface')));
  final gesture = await tester.startGesture(center);
  await gesture.moveBy(delta, timeStamp: const Duration(milliseconds: 10));
  await gesture.up(timeStamp: const Duration(milliseconds: 20));
}
