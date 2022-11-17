import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/models/toot.dart';

class TootService {
  final _random = Random();
  final current$ = BehaviorSubject<Toot>.seeded(toots.first);
  final previous$ = BehaviorSubject<Toot>.seeded(toots.first);
  final switched$ = BehaviorSubject<bool>.seeded(false);

  void shuffle() {
    switched$.add(true);
    previous$.add(current$.value);
    current$.add(toots[_random.nextInt(toots.length)]);
  }
}
