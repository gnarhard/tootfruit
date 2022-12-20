import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/models/toot.dart';
import 'package:tooty_fruity/models/user.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/storage_service.dart';
import 'package:tooty_fruity/services/user_service.dart';

class TootService {
  late final _audioService = Locator.get<AudioService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();

  final _random = Random();
  final current$ = BehaviorSubject<Toot>.seeded(toots.first);
  List<Toot> all = toots;
  List<Toot> owned = [toots.first];
  final newLoot$ = BehaviorSubject<Toot?>.seeded(null);

  bool get ownsEveryToot => all == owned;

  Future<void> init() async {
    User user = _userService.current!;
    final toot = toots.firstWhere((element) => element.fruit == user.currentFruit);
    current$.add(toot);
    owned = [toots.first];

    for (String fruit in user.ownedFruit) {
      final toot = toots.firstWhere((element) => element.fruit == fruit);
      owned.add(toot);
    }

    await set(toot);
  }

  void shuffle() {
    current$.add(toots[_random.nextInt(toots.length)]);
  }

  Future<void> set(Toot toot) async {
    toot.duration =
        await _audioService.setAudio('asset:///assets/audio/${toot.fruit}.${toot.fileExtension}');
    current$.add(toot);

    _userService.current!.currentFruit = toot.fruit;
    await _storageService.set('user', _userService.current!.toJson());
  }

  Future<void> increment() async {
    final int currentIndex = owned.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex + 1;
    if (nextIndex > owned.length - 1) {
      nextIndex = 0;
    }

    await set(owned[nextIndex]);
  }

  Future<void> decrement() async {
    final int currentIndex = owned.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex - 1;
    if (nextIndex < 0) {
      nextIndex = owned.length - 1;
    }

    await set(owned[nextIndex]);
  }

  Future<void> reward() async {
    final unclaimedToots = all.toSet().difference(owned.toSet()).toList();
    final newToot = unclaimedToots.elementAt(_random.nextInt(unclaimedToots.length));

    _userService.current!.ownedFruit.add(newToot.fruit);

    newLoot$.add(newToot);
    owned = [...owned, newToot];
    current$.add(newToot);

    await set(newToot);
    await _storageService.set('user', _userService.current!.toJson());
  }

  Future<void> rewardAll() async {
    final newToot = toots.last;
    final fruitNames = <String>[];

    for (Toot toot in all) {
      fruitNames.add(toot.fruit);
    }
    _userService.current!.ownedFruit = fruitNames;

    owned = all;
    current$.add(newToot);

    await set(newToot);
    await _storageService.set('user', _userService.current!.toJson());
  }
}
