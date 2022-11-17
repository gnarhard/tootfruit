import 'package:just_audio/just_audio.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/services/toot_service.dart';

class AudioService {
  final _tootService = Locator.get<TootService>();

  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    _tootService.current$.distinct().listen((toot) async {
      toot.duration = await _player.setAudioSource(AudioSource.uri(Uri.parse(toot.audioPath)));
    });
  }

  Future<void> play() async {
    // print(_tootService.switched$.value);
    // if (_tootService.switched$.value) {
    //   return;
    // }

    if (_player.playing) {
      await _player.seek(const Duration(seconds: 0));
    }
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
