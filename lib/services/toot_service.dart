import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/user_service.dart';

class TootService {
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
    final toot = toots.firstWhere(
      (element) => element.fruit == user.currentFruit,
    );
    owned = user.ownedFruit
        .map((fruit) => toots.firstWhere((element) => element.fruit == fruit))
        .toList();

    await set(toot);
  }

  void shuffle() {
    current = toots[_random.nextInt(toots.length)];
  }

  Future<void> set(Toot toot) async {
    // Set current fruit immediately so app reopen does not visually jump fruits.
    current = toot;
    try {
      toot.duration = await _audioService.setAudio(
        'asset:///assets/audio/${toot.fruit}.${toot.fileExtension}',
      );
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
  }

  /// Navigate to the next or previous toot in the owned list
  Future<void> _navigateToot(int direction) async {
    final currentIndex = owned.indexWhere(
      (toot) => toot.fruit == current.fruit,
    );
    final nextIndex = (currentIndex + direction) % owned.length;
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
}
