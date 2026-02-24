import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/models/settings.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';

void main() {
  group('TootScreen first fruit audio', () {
    tearDown(() async {
      await GetIt.I.reset();
    });

    testWidgets(
      'prepares and plays on first interaction when initial audio load returned zero',
      (WidgetTester tester) async {
        final audioService = _FakeAudioService(
          setAudioResults: <Duration>[
            Duration.zero,
            const Duration(milliseconds: 250),
          ],
        );
        final userService = _FakeUserService(
          User(
            settings: Settings(),
            currentFruit: 'peach',
            ownedFruit: const ['peach', 'banana', 'strawberry'],
          ),
        );
        final storageService = _FakeStorageService();
        final navigationService = NavigationService();

        GetIt.I.registerSingleton<AudioService>(audioService);
        GetIt.I.registerSingleton<UserService>(userService);
        GetIt.I.registerSingleton<StorageService>(storageService);
        GetIt.I.registerSingleton<NavigationService>(navigationService);

        final tootService = TootService(
          readFruitQueryParam: () => null,
          writeFruitQueryParam: (_) {},
        );
        GetIt.I.registerSingleton<TootService>(tootService);

        await tootService.init();
        expect(tootService.current.duration, equals(Duration.zero));
        expect(audioService.setAudioCalls, equals(1));
        expect(audioService.playCalls, equals(0));

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

        expect(audioService.setAudioCalls, equals(2));
        expect(audioService.playCalls, equals(1));
        expect(
          tootService.current.duration,
          equals(const Duration(milliseconds: 250)),
        );
      },
    );
  });
}

class _FakeAudioService extends AudioService {
  final List<Duration> _setAudioResults;
  int setAudioCalls = 0;
  int playCalls = 0;
  bool _isPrepared = false;

  _FakeAudioService({required List<Duration> setAudioResults})
    : _setAudioResults = List<Duration>.from(setAudioResults);

  @override
  Future<Duration> setAudio(String assetPath) async {
    setAudioCalls++;
    final result = _setAudioResults.isNotEmpty
        ? _setAudioResults.removeAt(0)
        : const Duration(milliseconds: 250);
    _isPrepared = result > Duration.zero;
    return result;
  }

  @override
  void play() {
    if (_isPrepared) {
      playCalls++;
    }
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
  Future<dynamic> get(String key) async {
    return writes[key];
  }

  @override
  Future<void> set(String key, dynamic value) async {
    writes[key] = value;
    if (key == StorageKeys.user && value is User) {
      final expirationKey = StorageKeys.expirationKey(key);
      writes[expirationKey] = DateTime.now().toIso8601String();
    }
  }
}
