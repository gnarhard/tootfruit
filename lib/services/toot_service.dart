import 'dart:math';

import 'package:tootfruit/locator.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/services/user_service.dart';

class TootService {
  late final _audioService = Locator.get<AudioService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();

  final _random = Random();
  Toot current = toots.first;
  Toot? newLoot;
  List<Toot> all = toots;
  List<Toot> owned = [];

  bool get ownsEveryToot => all == owned;

  Future<void> init() async {
    User user = _userService.current!;
    final toot = toots.firstWhere((element) => element.fruit == user.currentFruit);
    owned = [];

    for (String fruit in user.ownedFruit) {
      final toot = toots.firstWhere((element) => element.fruit == fruit);
      owned.add(toot);
    }

    await set(toot);
  }

  void shuffle() {
    current = toots[_random.nextInt(toots.length)];
  }

  Future<void> set(Toot toot) async {
    toot.duration =
        await _audioService.setAudio('asset:///assets/audio/${toot.fruit}.${toot.fileExtension}');
    current = toot;

    _userService.current!.currentFruit = toot.fruit;
    await _storageService.set('user', _userService.current!);
  }

  Future<void> increment() async {
    final int currentIndex = owned.indexWhere((toot) => toot.fruit == current.fruit);
    int nextIndex = currentIndex + 1;
    if (nextIndex > owned.length - 1) {
      nextIndex = 0;
    }

    await set(owned[nextIndex]);
  }

  Future<void> decrement() async {
    final int currentIndex = owned.indexWhere((toot) => toot.fruit == current.fruit);
    int nextIndex = currentIndex - 1;
    if (nextIndex < 0) {
      nextIndex = owned.length - 1;
    }

    await set(owned[nextIndex]);
  }

  Future<void> reward() async {
    final unclaimedToots = all.toSet().difference(owned.toSet()).toList();
    newLoot = unclaimedToots.elementAt(_random.nextInt(unclaimedToots.length));

    _userService.current!.ownedFruit.add(newLoot!.fruit);

    owned = [...owned, newLoot!];

    await set(newLoot!);
    await _storageService.set('user', _userService.current!);
  }

  Future<void> rewardAll() async {
    final newToot = toots.last;
    final fruitNames = <String>[];

    for (Toot toot in all) {
      fruitNames.add(toot.fruit);
    }
    _userService.current!.ownedFruit = fruitNames;

    owned = all;

    await set(newToot);
    await _storageService.set('user', _userService.current!);
    ToastService.success(message: "Whoa! You found the secret way to unlock all toots!");
  }
}
