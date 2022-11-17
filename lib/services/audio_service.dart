import 'package:just_audio/just_audio.dart';
import 'package:tooty_fruity/locator.dart';
import 'package:tooty_fruity/services/toot_service.dart';

class AudioService {
  final _tootService = Locator.get<TootService>();

  bool hasPlayed = false;
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    _tootService.current$.distinct().listen((toot) async {
      toot.duration = await _player.setAudioSource(AudioSource.uri(Uri.parse(toot.audioPath)));
      _player.stop();
    });

    _player.playerStateStream.listen((state) {
      if (_tootService.current$.value.duration == null) {
        return;
      }

      if (state.processingState == ProcessingState.completed) {
        // _tootService.shuffle();
        _tootService.increment();
      }
    });
  }

  Future<void> play() async {
    if (_player.playing) {
      await _player.seek(const Duration(seconds: 0));
    }
    await _player.play();
    hasPlayed = true;
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
