import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/models/toot.dart';
import 'package:tooty_fruity/models/user.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/user_service.dart';

class TootService {
  late final _audioService = Locator.get<AudioService>();
  late final _userService = Locator.get<UserService>();

  final _random = Random();
  final current$ = BehaviorSubject<Toot>.seeded(toots.first);
  final all$ = BehaviorSubject<List<Toot>>.seeded(toots);
  final owned$ = BehaviorSubject<List<Toot>>.seeded([toots.first]);
  final newLoot$ = BehaviorSubject<Toot?>.seeded(null);

  bool get ownsEveryToot => all$.value == owned$.value;

  Future<void> init() async {
    User user = _userService.current$.value!;
    final toot = toots.firstWhere((element) => element.fruit == user.currentFruit);
    final ownedToots = <Toot>[];
    current$.add(toot);

    for (String fruit in user.ownedFruit) {
      final toot = toots.firstWhere((element) => element.fruit == fruit);
      ownedToots.add(toot);
    }

    owned$.add(ownedToots);

    await set(toot);
  }

  void shuffle() {
    current$.add(toots[_random.nextInt(toots.length)]);
  }

  Future<void> set(Toot toot) async {
    toot.duration =
        await _audioService.setAudio('asset:///assets/audio/${toot.fruit}.${toot.fileExtension}');
    current$.add(toot);

    User user = _userService.current$.value!;
    user.currentFruit = toot.fruit;
    _userService.current$.add(user);
  }

  Future<void> increment() async {
    final int currentIndex = owned$.value.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex + 1;
    if (nextIndex > owned$.value.length - 1) {
      nextIndex = 0;
    }

    await set(owned$.value[nextIndex]);
  }

  Future<void> decrement() async {
    final int currentIndex = owned$.value.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex - 1;
    if (nextIndex < 0) {
      nextIndex = owned$.value.length - 1;
    }

    await set(owned$.value[nextIndex]);
  }

  Future<void> reward() async {
    final unclaimedToots = all$.value.toSet().difference(owned$.value.toSet()).toList();
    final newToot = unclaimedToots.elementAt(_random.nextInt(unclaimedToots.length));

    User user = _userService.current$.value!;
    user.ownedFruit.add(newToot.fruit);

    newLoot$.add(newToot);
    owned$.add([...owned$.value, newToot]);
    _userService.current$.add(user);
    current$.add(newToot);

    await set(newToot);
  }

  Future<void> rewardAll() async {
    final newToot = toots.last;
    User user = _userService.current$.value!;
    final fruitNames = <String>[];

    for (Toot toot in all$.value) {
      fruitNames.add(toot.fruit);
    }
    user.ownedFruit = fruitNames;
    _userService.current$.add(user);

    owned$.add(all$.value);
    current$.add(newToot);

    await set(newToot);
  }
}
