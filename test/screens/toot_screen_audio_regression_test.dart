import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('TootScreen first fruit audio', () {
    late MockITootRepository mockTootRepo;
    late MockIUserRepository mockUserRepo;
    late MockIAudioPlayer mockAudioPlayer;
    late DI di;

    setUp(() {
      mockTootRepo = MockITootRepository();
      mockUserRepo = MockIUserRepository();
      mockAudioPlayer = MockIAudioPlayer();
      di = DI();
      di.reset();
    });

    testWidgets(
      'prepares and plays on first interaction when initial audio load returned zero',
      (WidgetTester tester) async {
        final setAudioResults = <Duration>[
          Duration.zero,
          const Duration(milliseconds: 250),
        ];
        var setAudioCalls = 0;
        var playCalls = 0;

        when(mockAudioPlayer.setAudio(any)).thenAnswer((_) async {
          setAudioCalls++;
          if (setAudioResults.isNotEmpty) {
            return setAudioResults.removeAt(0);
          }
          return const Duration(milliseconds: 250);
        });
        when(mockAudioPlayer.play()).thenAnswer((_) {
          playCalls++;
        });
        when(mockAudioPlayer.init()).thenAnswer((_) async {});

        final testUser = TestData.createUser(currentFruit: 'peach');
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async {});
        when(mockTootRepo.getAllToots()).thenReturn(toots);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(toots.first);

        final navigationService = NavigationService();

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

        await di.tootService.init();
        expect(di.tootService.current.duration, equals(Duration.zero));
        expect(setAudioCalls, equals(1));
        expect(playCalls, equals(0));

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigationService.navigatorKey,
            home: const TootScreen(),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(FruitAsset).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 320));

        expect(setAudioCalls, equals(2));
        expect(playCalls, equals(1));
        expect(
          di.tootService.current.duration,
          equals(const Duration(milliseconds: 250)),
        );
      },
    );
  });
}
