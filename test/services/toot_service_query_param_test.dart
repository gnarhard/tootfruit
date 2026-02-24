import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/services/toot_service.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('TootService query param behavior', () {
    late MockITootRepository mockTootRepo;
    late MockIUserRepository mockUserRepo;
    late MockIAudioPlayer mockAudioPlayer;

    setUp(() {
      mockTootRepo = MockITootRepository();
      mockUserRepo = MockIUserRepository();
      mockAudioPlayer = MockIAudioPlayer();

      when(mockAudioPlayer.init()).thenAnswer((_) async => {});
      when(
        mockAudioPlayer.setAudio(any),
      ).thenAnswer((_) async => const Duration(milliseconds: 250));
      when(mockUserRepo.updateCurrentFruit(any)).thenAnswer((_) async => {});

      final testUser = TestData.createUser(currentFruit: 'peach');
      when(mockUserRepo.currentUser).thenReturn(testUser);
      when(mockTootRepo.getAllToots()).thenReturn(toots);
      when(mockTootRepo.getTootByFruit('peach')).thenReturn(toots.first);
    });

    test('init picks fruit from query parameter', () async {
      final service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => 'banana',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('banana'));
    });

    test('init picks fruit from query parameter for any fruit', () async {
      final service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => 'blueberry',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('blueberry'));
    });

    test('init ignores unknown query parameter fruit', () async {
      final service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => 'dragonfruit',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('peach'));
    });

    test(
      'increment from deep-linked fruit navigates through all fruits',
      () async {
        final service = TootService(
          tootRepository: mockTootRepo,
          userRepository: mockUserRepo,
          audioPlayer: mockAudioPlayer,
          readFruitQueryParam: () => 'blueberry',
          writeFruitQueryParam: (_) {},
        );

        await service.init();
        expect(service.current.fruit, equals('blueberry'));

        await service.increment();

        // blueberry is index 15 in the toots list, next is coconut (index 16)
        final allToots = toots;
        final blueberryIndex = allToots.indexWhere((t) => t.fruit == 'blueberry');
        final expectedNext = allToots[(blueberryIndex + 1) % allToots.length];
        expect(service.current.fruit, equals(expectedNext.fruit));
      },
    );

    test('set writes the selected fruit to query parameter writer', () async {
      String? writtenFruit;
      final service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (fruit) => writtenFruit = fruit,
      );

      await service.init();
      await service.increment();

      final allToots = toots;
      final peachIndex = allToots.indexWhere((t) => t.fruit == 'peach');
      final expectedNext = allToots[(peachIndex + 1) % allToots.length];
      expect(service.current.fruit, equals(expectedNext.fruit));
      expect(writtenFruit, equals(expectedNext.fruit));
      verify(mockUserRepo.updateCurrentFruit(expectedNext.fruit)).called(1);
    });

    test('set does not throw when query parameter writer fails', () async {
      final service = TootService(
        tootRepository: mockTootRepo,
        userRepository: mockUserRepo,
        audioPlayer: mockAudioPlayer,
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (_) => throw StateError('browser update failed'),
      );

      await service.init();

      expect(() async => service.increment(), returnsNormally);
    });

    test(
      'ensureCurrentAudioPrepared recovers first fruit audio when initial load fails',
      () async {
        var setAudioCalls = 0;
        final results = [Duration.zero, const Duration(milliseconds: 250)];

        when(mockAudioPlayer.setAudio(any)).thenAnswer((_) async {
          setAudioCalls++;
          if (results.isNotEmpty) {
            return results.removeAt(0);
          }
          return const Duration(milliseconds: 250);
        });

        final service = TootService(
          tootRepository: mockTootRepo,
          userRepository: mockUserRepo,
          audioPlayer: mockAudioPlayer,
          readFruitQueryParam: () => null,
          writeFruitQueryParam: (_) {},
        );

        await service.init();
        expect(service.current.duration, equals(Duration.zero));
        expect(setAudioCalls, equals(1));

        await service.ensureCurrentAudioPrepared();

        expect(
          service.current.duration,
          equals(const Duration(milliseconds: 250)),
        );
        expect(setAudioCalls, equals(2));
      },
    );
  });
}
