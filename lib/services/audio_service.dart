import 'package:just_audio/just_audio.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import '../models/toot.dart';

class AudioService {
  final _tootService = Locator.get<TootService>();

  bool hasPlayed = false;
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    _tootService.current$.listen((toot) async {
      await setAudio(
          'asset:///assets/audio/${_tootService.current$.value.fruit}.${_tootService.current$.value.fileExtension}');
    });
    _tootService.current$.add(toots.first);
  }

  Future<void> setAudio(String path) async {
    if (_player.playing) {
      await _player.stop();
    }
    await _player.setAudioSource(AudioSource.uri(Uri.parse(path)));
  }

  Future<void> play() async {
    if (_player.playing) {
      await _player.seek(const Duration(seconds: 0));
    } else {
      await _player.play();
    }
    hasPlayed = true;
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
