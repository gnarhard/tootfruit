import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/models/toot.dart';
import 'package:tooty_fruity/services/audio_service.dart';

class TootService {
  late final _audioService = Locator.get<AudioService>();

  final _random = Random();
  final current$ = BehaviorSubject<Toot>.seeded(toots.first);

  void shuffle() {
    current$.add(toots[_random.nextInt(toots.length)]);
  }

  Future<void> set(Toot toot) async {
    toot.duration =
        await _audioService.setAudio('asset:///assets/audio/${toot.fruit}.${toot.fileExtension}');
    current$.add(toot);
  }

  Future<void> increment() async {
    final int currentIndex = toots.indexWhere((toot) => toot.fruit == current$.value!.fruit);
    int nextIndex = currentIndex + 1;
    if (nextIndex > toots.length - 1) {
      nextIndex = 0;
    }

    await set(toots[nextIndex]);
  }

  Future<void> decrement() async {
    final int currentIndex = toots.indexWhere((toot) => toot.fruit == current$.value!.fruit);
    int nextIndex = currentIndex - 1;
    if (nextIndex < 0) {
      nextIndex = toots.length - 1;
    }

    await set(toots[nextIndex]);
  }
}
