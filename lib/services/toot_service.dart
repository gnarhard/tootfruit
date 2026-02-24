import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/fruit_query_param.dart' as fruit_query_param;
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/user_service.dart';

class TootService {
  final String? Function() _readFruitQueryParam;
  final void Function(String fruit) _writeFruitQueryParam;

  TootService({
    String? Function()? readFruitQueryParam,
    void Function(String fruit)? writeFruitQueryParam,
  }) : _readFruitQueryParam =
           readFruitQueryParam ?? fruit_query_param.readFruitQueryParam,
       _writeFruitQueryParam =
           writeFruitQueryParam ?? fruit_query_param.writeFruitQueryParam;

  late final _audioService = Locator.get<AudioService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();

  final loading = ValueNotifier<bool>(false);

  final _random = Random();
  Toot current = toots.first;
  Toot? newLoot;
  List<Toot> all = toots;
  List<Toot> owned = [];
  bool isRewarded = false;

  bool get ownsEveryToot => all.length == owned.length;

  /// Safe accessor for current user with null check
  User get _currentUser {
    final user = _userService.current;
    if (user == null) {
      throw StateError('User must be initialized before accessing TootService');
    }
    return user;
  }

  Future<void> init() async {
    final user = _currentUser;
    var toot = toots.firstWhere(
      (element) => element.fruit == user.currentFruit,
    );
    owned = user.ownedFruit
        .map((fruit) => toots.firstWhere((element) => element.fruit == fruit))
        .toList();

    final requestedFruit = _normalizedFruit(_readFruitQueryParam());
    if (requestedFruit != null) {
      toot = _findTootByFruit(requestedFruit) ?? toot;
    }

    await set(toot);
  }

  void shuffle() {
    current = toots[_random.nextInt(toots.length)];
  }

  Future<void> set(Toot toot) async {
    // Set current fruit immediately so app reopen does not visually jump fruits.
    current = toot;
    try {
      toot.duration = await _audioService.setAudio(_audioAssetPathFor(toot));
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.set: Failed to set audio for ${toot.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      toot.duration = Duration.zero;
    }

    final user = _currentUser;
    user.currentFruit = toot.fruit;
    await _storageService.set(StorageKeys.user, user);
    try {
      _writeFruitQueryParam(toot.fruit);
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.set: Failed to update fruit query param for ${toot.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> ensureCurrentAudioPrepared() async {
    final duration = current.duration;
    if (duration != null && duration > Duration.zero) {
      return;
    }

    try {
      current.duration = await _audioService.setAudio(
        _audioAssetPathFor(current),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.ensureCurrentAudioPrepared: '
        'Failed to prepare audio for ${current.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      current.duration = Duration.zero;
    }
  }

  /// Navigate to the next or previous toot in the owned list
  Future<void> _navigateToot(int direction) async {
    final currentIndex = owned.indexWhere(
      (toot) => toot.fruit == current.fruit,
    );
    final safeCurrentIndex = currentIndex >= 0 ? currentIndex : 0;
    final nextIndex = (safeCurrentIndex + direction) % owned.length;
    await set(owned[nextIndex]);
  }

  Future<void> increment() => _navigateToot(1);

  Future<void> decrement() => _navigateToot(-1);

  Future<void> reward() async {
    final unclaimedToots = all.toSet().difference(owned.toSet()).toList();
    if (unclaimedToots.isEmpty) {
      return;
    }
    newLoot = unclaimedToots.elementAt(_random.nextInt(unclaimedToots.length));

    final user = _currentUser;
    user.ownedFruit.add(newLoot!.fruit);
    owned = [...owned, newLoot!];

    await set(newLoot!);
    await _storageService.set(StorageKeys.user, user);
    isRewarded = true;
  }

  Future<void> rewardAll() async {
    final newToot = toots.last;
    final user = _currentUser;

    user.ownedFruit = all.map((toot) => toot.fruit).toList();
    owned = all;

    await set(newToot);
    await _storageService.set(StorageKeys.user, user);
  }

  Future<void> purchaseAll() async {
    if (loading.value) {
      return;
    }
    loading.value = true;
    try {
      await rewardAll();
    } finally {
      loading.value = false;
    }
  }

  String? _normalizedFruit(String? fruit) {
    final trimmed = fruit?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  Toot? _findTootByFruit(String fruit) {
    final normalizedFruit = fruit.toLowerCase();
    for (final toot in all) {
      if (toot.fruit.toLowerCase() == normalizedFruit) {
        return toot;
      }
    }
    return null;
  }

  String _audioAssetPathFor(Toot toot) {
    return 'asset:///assets/audio/${toot.fruit}.${toot.fileExtension}';
  }
}
