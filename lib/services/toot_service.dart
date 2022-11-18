import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/models/toot.dart';

class TootService {
  final _random = Random();
  final current$ = BehaviorSubject<Toot>.seeded(toots.first);

  void shuffle() {
    current$.add(toots[_random.nextInt(toots.length)]);
  }

  void increment() {
    final int currentIndex = toots.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex + 1;
    if (nextIndex > toots.length - 1) {
      nextIndex = 0;
    }

    current$.add(toots[nextIndex]);
  }

  void decrement() {
    final int currentIndex = toots.indexWhere((toot) => toot.fruit == current$.value.fruit);
    int nextIndex = currentIndex - 1;
    if (nextIndex < 0) {
      nextIndex = toots.length - 1;
    }

    current$.add(toots[nextIndex]);
  }
}
