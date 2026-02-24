import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/toot_service.dart';

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

      when(mockAudioPlayer.init()).thenAnswer((_) async => {});

      testToots = TestData.createTootList();
      testUser = TestData.createUser(currentFruit: 'peach');

      service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (_) {},
      );
    });

    group('initialization', () {
      test('current getter returns first toot when not initialized', () {
        when(mockTootRepo.getAllToots()).thenReturn(testToots);

        final current = service.current;

        expect(current.fruit, equals('peach'));
      });
    });

    group('init', () {
      test('sets current toot from user', () async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
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

    group('set', () {
      test('loads audio for toot', () async {
        final toot = testToots[0];
        when(
          mockAudioPlayer.setAudio('asset:///assets/audio/peach.mp3'),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.set(toot);

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

        await service.set(toot);

        expect(toot.duration, equals(testDuration));
      });

      test('updates current fruit in user repository', () async {
        final toot = testToots[1]; // apple
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.set(toot);

        verify(mockUserRepo.updateCurrentFruit('apple')).called(1);
      });
    });

    group('increment', () {
      setUp(() async {
        when(mockUserRepo.currentUser).thenReturn(testUser);
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
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
        await service.increment(); // to banana
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
        when(mockTootRepo.getAllToots()).thenReturn(testToots);
        when(mockTootRepo.getTootByFruit('peach')).thenReturn(testToots[0]);
        when(
          mockAudioPlayer.setAudio(any),
        ).thenAnswer((_) async => testDuration);
        when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

        await service.init();
      });

      test('moves to previous toot (wraps to last)', () async {
        await service.decrement();

        expect(service.current.fruit, equals('banana'));
      });

      test('wraps around correctly', () async {
        await service.increment(); // to apple
        await service.decrement(); // back to peach

        expect(service.current.fruit, equals('peach'));
      });
    });
  });
}
