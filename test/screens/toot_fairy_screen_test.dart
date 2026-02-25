import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('TootFairyScreen game over actions', () {
    late MockIAudioPlayer mockAudioPlayer;
    late DI di;

    setUp(() {
      mockAudioPlayer = MockIAudioPlayer();
      di = DI();
      di.reset();

      when(mockAudioPlayer.setAudio(any)).thenAnswer((_) async => testDuration);
      when(mockAudioPlayer.play()).thenAnswer((_) {});
      when(mockAudioPlayer.stop()).thenAnswer((_) async {});

      di.audioPlayer = mockAudioPlayer;
    });

    testWidgets('shows play again action without a share action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TootFairyScreen()));
      await tester.pump();

      await tester.tap(find.text('PLAY'));
      await tester.pump();

      for (
        var secondsElapsed = 0;
        secondsElapsed < 20 && find.text('GAME OVER').evaluate().isEmpty;
        secondsElapsed++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text('GAME OVER'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('PLAY AGAIN'), findsOneWidget);
      expect(find.text('SHARE'), findsNothing);
    });
  });
}
