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

  testWidgets('desktop/web space bar triggers toot audio and animation', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    await _initializeUnlockedState(tester);
    final audioService = Locator.get<AudioService>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: Locator.get<NavigationService>().navigatorKey,
        initialRoute: TootScreen.route,
        routes: routes,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    expect(find.byKey(const Key('tootScreen')), findsOneWidget);
    expect(find.byKey(const Key('fruitScaleTransform')), findsOneWidget);
    expect(audioService.hasPlayed, isFalse);

    final handled = await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await _waitForLiveApp(duration: const Duration(milliseconds: 200));

    expect(handled, isTrue);
    expect(audioService.hasPlayed, isTrue);
    expect(tester.takeException(), isNull);
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
