import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop/web space bar triggers toot audio and animation', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    final di = await _initializeUnlockedState(tester);
    final audioService = di.audioPlayer as AudioService;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
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
