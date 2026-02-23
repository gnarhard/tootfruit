import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/toot_service_refactored.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('TootService', () {
    late TootService service;
    late MockITootRepository mockTootRepo;
    late MockIUserRepository mockUserRepo;
    late MockIAudioPlayer mockAudioPlayer;

    late List<Toot> testToots;
    late User testUser;

    setUp(() {
      mockTootRepo = MockITootRepository();
      mockUserRepo = MockIUserRepository();
      mockAudioPlayer = MockIAudioPlayer();

      // Stub the audio player init method
      when(mockAudioPlayer.init()).thenAnswer((_) async => {});

      testToots = TestData.createTootList();
      testUser = TestData.createUser(
        ownedFruit: ['peach', 'apple'],
        currentFruit: 'peach',
      );

      service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
      );
    });

    group('initialization', () {
      test('starts with default values', () {
        expect(service.loading.value, isFalse);
        expect(service.isRewarded, isFalse);
        expect(service.newLoot, isNull);
      });

      test('current getter returns first toot when not initialized', () {
        when(mockTootRepo.getAllToots()).thenReturn(testToots);

        final current = service.current;

        expect(current.fruit, equals('peach'));
      });
    });

    group('init', () {
      test('loads owned toots for user', () async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(
          mockTootRepo.getOwnedToots(['peach', 'apple']),
        ).thenReturn([testToots[0], testToots[1]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();

        expect(service.owned.length, equals(2));
        verify(mockTootRepo.getOwnedToots(['peach', 'apple'])).called(1);
      });

      test('sets current toot from user', () async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getOwnedToots(any)).thenReturn([testToots[0]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();

        expect(service.current.fruit, equals('peach'));
      });

      test('throws StateError when user is null', () async {
        when(mockUserRepo.currentUser).thenReturn(null);

        expect(
          () => service.init(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('User must be loaded before initializing TootService'),
            ),
          ),
        );
      });
    });

    group('setCurrentToot', () {
      test('loads audio for toot', () async {
        final toot = testToots[0];
        when(
          mockAudioPlayer.setAudio('asset:///assets/audio/peach.mp3'),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.setCurrentToot(toot);

        verify(
          mockAudioPlayer.setAudio('asset:///assets/audio/peach.mp3'),
        ).called(1);
      });

      test('sets toot duration from audio', () async {
        final toot = testToots[0];
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.setCurrentToot(toot);

        expect(toot.duration, equals(testDuration));
      });

      test('updates current fruit in user repository', () async {
        final toot = testToots[1]; // apple
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.setCurrentToot(toot);

        verify(mockUserRepo.updateCurrentFruit('apple')).called(1);
      });
    });

    group('increment', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(
          mockTootRepo.getOwnedToots(any),
        ).thenReturn([testToots[0], testToots[1]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('moves to next toot', () async {
        await service.increment();

        expect(service.current.fruit, equals('apple'));
      });

      test('wraps around to first toot', () async {
        await service.increment(); // to apple
        await service.increment(); // wraps to peach

        expect(service.current.fruit, equals('peach'));
      });

      test('updates user repository', () async {
        await service.increment();

        verify(mockUserRepo.updateCurrentFruit('apple')).called(1);
      });
    });

    group('decrement', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(
          mockTootRepo.getOwnedToots(any),
        ).thenReturn([testToots[0], testToots[1]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('moves to previous toot', () async {
        await service.decrement();

        expect(service.current.fruit, equals('apple'));
      });

      test('wraps around to last toot', () async {
        await service.increment(); // to apple
        await service.decrement(); // back to peach

        expect(service.current.fruit, equals('peach'));
      });
    });

    group('reward', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
        when(
          mockTootRepo.getOwnedToots(['peach', 'apple']),
        ).thenReturn([testToots[0], testToots[1]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});
        when(mockUserRepo.addOwnedFruit(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('gets random unclaimed toot', () async {
        when(
          mockTootRepo.getRandomUnclaimedToot(['peach', 'apple']),
        ).thenReturn(testToots[2]); // banana

        await service.reward();

        expect(service.newLoot!.fruit, equals('banana'));
      });

      test('adds fruit to user repository', () async {
        when(mockTootRepo.getRandomUnclaimedToot(any)).thenReturn(testToots[2]);
        when(
          mockTootRepo.getOwnedToots(any),
        ).thenReturn([testToots[0], testToots[1], testToots[2]]);

        await service.reward();

        verify(mockUserRepo.addOwnedFruit('banana')).called(1);
      });

      test('sets isRewarded flag', () async {
        when(mockTootRepo.getRandomUnclaimedToot(any)).thenReturn(testToots[2]);
        when(mockTootRepo.getOwnedToots(any)).thenReturn(testToots);

        await service.reward();

        expect(service.isRewarded, isTrue);
      });

      test('updates owned toots list', () async {
        when(mockTootRepo.getRandomUnclaimedToot(any)).thenReturn(testToots[2]);
        // Use any matcher since mock userRepo doesn't modify the actual user object
        when(mockTootRepo.getOwnedToots(any)).thenReturn(testToots);

        await service.reward();

        expect(service.owned.length, equals(3));
      });
    });

    group('rewardAll', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
        when(mockTootRepo.getOwnedToots(any)).thenReturn([testToots[0]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});
        when(mockUserRepo.setAllFruitsOwned(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('sets all fruits as owned', () async {
        await service.rewardAll();

        verify(
          mockUserRepo.setAllFruitsOwned(['peach', 'apple', 'banana']),
        ).called(1);
      });

      test('updates owned toots to all toots', () async {
        when(mockTootRepo.getOwnedToots(any)).thenReturn(testToots);

        await service.rewardAll();

        expect(service.owned.length, equals(3));
        expect(service.ownsEveryToot, isTrue);
      });

      test('sets current to last toot', () async {
        await service.rewardAll();

        expect(service.current.fruit, equals('banana'));
      });
    });

    group('purchaseAll', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
        when(mockTootRepo.getOwnedToots(any)).thenReturn([testToots[0]]);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});
        when(mockUserRepo.setAllFruitsOwned(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('unlocks all fruits when not loading', () async {
        await service.purchaseAll();

        verify(
          mockUserRepo.setAllFruitsOwned(['peach', 'apple', 'banana']),
        ).called(1);
      });

      test('resets loading flag after completion', () async {
        await service.purchaseAll();

        expect(service.loading.value, isFalse);
      });

      test('does not start purchase when already loading', () async {
        service.loading.value = true;

        await service.purchaseAll();

        verifyNever(mockUserRepo.setAllFruitsOwned(any));
      });
    });

    group('ownsEveryToot', () {
      test('returns false when not all toots owned', () {
        when(mockTootRepo.getAllToots()).thenReturn(testToots);

        expect(service.ownsEveryToot, isFalse);
      });

      test('returns true when all toots owned', () async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
        when(mockTootRepo.getOwnedToots(any)).thenReturn(testToots);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();

        expect(service.ownsEveryToot, isTrue);
      });
    });
  });
}
