import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/models/settings.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

void main() {
  group('TootService query param behavior', () {
    late _FakeAudioService audioService;
    late _FakeUserService userService;
    late _FakeStorageService storageService;

    setUp(() async {
      await GetIt.I.reset();
      audioService = _FakeAudioService();
      userService = _FakeUserService(
        User(
          settings: Settings(),
          currentFruit: 'peach',
          ownedFruit: ['peach', 'banana', 'strawberry'],
        ),
      );
      storageService = _FakeStorageService();

      GetIt.I.registerSingleton<AudioService>(audioService);
      GetIt.I.registerSingleton<UserService>(userService);
      GetIt.I.registerSingleton<StorageService>(storageService);
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    test('init picks fruit from query parameter when owned', () async {
      final service = TootService(
        readFruitQueryParam: () => 'banana',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('banana'));
    });

    test('init picks fruit from query parameter even when not owned', () async {
      final service = TootService(
        readFruitQueryParam: () => 'blueberry',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('blueberry'));
    });

    test('init ignores unknown query parameter fruit', () async {
      final service = TootService(
        readFruitQueryParam: () => 'dragonfruit',
        writeFruitQueryParam: (_) {},
      );

      await service.init();

      expect(service.current.fruit, equals('peach'));
    });

    test(
      'increment from deep-linked unowned fruit stays deterministic',
      () async {
        final service = TootService(
          readFruitQueryParam: () => 'blueberry',
          writeFruitQueryParam: (_) {},
        );

        await service.init();
        expect(service.current.fruit, equals('blueberry'));

        await service.increment();

        expect(service.current.fruit, equals('banana'));
      },
    );

    test('set writes the selected fruit to query parameter writer', () async {
      String? writtenFruit;
      final service = TootService(
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (fruit) => writtenFruit = fruit,
      );

      await service.init();
      await service.increment();

      expect(service.current.fruit, equals('banana'));
      expect(writtenFruit, equals('banana'));
      expect(
        storageService.writes[StorageKeys.user],
        equals(userService.current),
      );
    });

    test('set does not throw when query parameter writer fails', () async {
      final service = TootService(
        readFruitQueryParam: () => null,
        writeFruitQueryParam: (_) => throw StateError('browser update failed'),
      );

      await service.init();

      expect(() async => service.increment(), returnsNormally);
      expect(service.current.fruit, equals('banana'));
      expect(
        storageService.writes[StorageKeys.user],
        equals(userService.current),
      );
    });

    test(
      'ensureCurrentAudioPrepared recovers first fruit audio when initial load fails',
      () async {
        audioService.enqueueSetAudioResults([
          Duration.zero,
          const Duration(milliseconds: 250),
        ]);

        final service = TootService(
          readFruitQueryParam: () => null,
          writeFruitQueryParam: (_) {},
        );

        await service.init();
        expect(service.current.duration, equals(Duration.zero));
        expect(audioService.setAudioCalls, equals(1));

        await service.ensureCurrentAudioPrepared();

        expect(
          service.current.duration,
          equals(const Duration(milliseconds: 250)),
        );
        expect(audioService.setAudioCalls, equals(2));
      },
    );
  });
}

class _FakeAudioService extends AudioService {
  final List<Duration> _queuedResults = [];
  int setAudioCalls = 0;

  void enqueueSetAudioResults(List<Duration> durations) {
    _queuedResults
      ..clear()
      ..addAll(durations);
  }

  @override
  Future<Duration> setAudio(String assetPath) async {
    setAudioCalls++;
    if (_queuedResults.isEmpty) {
      return const Duration(milliseconds: 250);
    }
    return _queuedResults.removeAt(0);
  }
}

class _FakeUserService extends UserService {
  _FakeUserService(User user) {
    current = user;
  }
}

class _FakeStorageService extends StorageService {
  final writes = <String, dynamic>{};

  @override
  Future<void> set(String key, dynamic value) async {
    writes[key] = value;
  }
}
