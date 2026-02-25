import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toot_service.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('TootScreen footer link', () {
    late MockITootRepository mockTootRepo;
    late MockIUserRepository mockUserRepo;
    late MockIAudioPlayer mockAudioPlayer;
    late NavigationService navigationService;
    late DI di;

    setUp(() {
      mockTootRepo = MockITootRepository();
      mockUserRepo = MockIUserRepository();
      mockAudioPlayer = MockIAudioPlayer();
      navigationService = NavigationService();
      di = DI();
      di.reset();

      when(mockAudioPlayer.init()).thenAnswer((_) async {});
      when(mockAudioPlayer.setAudio(any)).thenAnswer((_) async => testDuration);
      when(mockUserRepo.currentUser).thenReturn(TestData.createUser());
      when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async {});
      when(mockTootRepo.getAllToots()).thenReturn(toots);
      when(mockTootRepo.getTootByFruit('peach')).thenReturn(toots.first);

      di.tootRepository = mockTootRepo;
      di.userRepository = mockUserRepo;
      di.audioPlayer = mockAudioPlayer;
      di.navigationService = navigationService;
      di.tootService = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (_) {},
      );
    });

    testWidgets('opens gnarhard link when tapped', (WidgetTester tester) async {
      final openedUris = <Uri>[];

      await di.tootService.init();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigationService.navigatorKey,
          home: TootScreen(
            externalLinkOpener: (uri) async {
              openedUris.add(uri);
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('gnarhardLink')));
      await tester.pump();

      expect(openedUris, equals([Uri.parse('https://gnarhard.com')]));
      expect(find.text('gnarhard'), findsOneWidget);
    });
  });
}
