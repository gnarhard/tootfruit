import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';

import 'test_di_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    resetIntegrationTestDI();
  });

  testWidgets('desktop/web space bar triggers toot audio and animation', (
    WidgetTester tester,
  ) async {
    if (!kIsWeb) {
      return;
    }

    final di = await initializeIntegrationTestState(tester);
    final audioService = di.audioPlayer as AudioService;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: di.navigationService.navigatorKey,
        home: const TootScreen(),
        onGenerateRoute: onGenerateAppRoute,
        onUnknownRoute: onUnknownAppRoute,
      ),
    );

    await _waitForLiveApp(duration: const Duration(seconds: 1));
    expect(find.byKey(const Key('tootScreen')), findsOneWidget);
    expect(find.byKey(const Key('fruitScaleTransform')), findsOneWidget);
    expect(audioService.hasPlayed, isFalse);

    await _sendSpacePress(tester);
    await _waitForLiveApp(duration: const Duration(milliseconds: 300));

    expect(audioService.hasPlayed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _sendSpacePress(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
}

Future<void> _waitForLiveApp({
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await Future<void>.delayed(duration);
}
