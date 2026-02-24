import 'package:flutter/foundation.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/services/fruit_query_param.dart' as fruit_query_param;

class TootService {
  final ITootRepository _tootRepository;
  final IUserRepository _userRepository;
  final IAudioPlayer _audioPlayer;
  final String? Function() _readFruitQueryParam;
  final void Function(String fruit) _writeFruitQueryParam;

  Toot? _currentToot;

  TootService({
    required ITootRepository tootRepository,
    required IUserRepository userRepository,
    required IAudioPlayer audioPlayer,
    String? Function()? readFruitQueryParam,
    void Function(String fruit)? writeFruitQueryParam,
  }) : _tootRepository = tootRepository,
       _userRepository = userRepository,
       _audioPlayer = audioPlayer,
       _readFruitQueryParam =
           readFruitQueryParam ?? fruit_query_param.readFruitQueryParam,
       _writeFruitQueryParam =
           writeFruitQueryParam ?? fruit_query_param.writeFruitQueryParam;

  Toot get current => _currentToot ?? _tootRepository.getAllToots().first;
  List<Toot> get all => _tootRepository.getAllToots();

  Future<void> init() async {
    final user = _userRepository.currentUser;
    if (user == null) {
      throw StateError('User must be loaded before initializing TootService');
    }

    var currentToot = _tootRepository.getTootByFruit(user.currentFruit);

    final requestedFruit = _normalizedFruit(_readFruitQueryParam());
    if (requestedFruit != null) {
      currentToot = _findTootByFruit(requestedFruit) ?? currentToot;
    }

    await set(currentToot);
  }

  Future<void> set(Toot toot) async {
    _currentToot = toot;

    try {
      final duration = await _audioPlayer.setAudio(
        'asset:///assets/audio/${toot.fruit}.${toot.fileExtension}',
      );
      toot.duration = duration;
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.set: Failed to set audio for ${toot.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      toot.duration = Duration.zero;
    }

    await _userRepository.updateCurrentFruit(toot.fruit);

    try {
      _writeFruitQueryParam(toot.fruit);
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.set: Failed to update fruit query param for ${toot.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> ensureCurrentAudioPrepared() async {
    final duration = current.duration;
    if (duration != null && duration > Duration.zero) {
      return;
    }

    try {
      current.duration = await _audioPlayer.setAudio(
        'asset:///assets/audio/${current.fruit}.${current.fileExtension}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'TootService.ensureCurrentAudioPrepared: '
        'Failed to prepare audio for ${current.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      current.duration = Duration.zero;
    }
  }

  Future<void> increment() => _navigateToot(1);

  Future<void> decrement() => _navigateToot(-1);

  Future<void> _navigateToot(int direction) async {
    final currentIndex = all.indexWhere((t) => t.fruit == current.fruit);
    final safeCurrentIndex = currentIndex >= 0 ? currentIndex : 0;
    final nextIndex = (safeCurrentIndex + direction) % all.length;
    await set(all[nextIndex]);
  }

  void shuffle() {
    _currentToot = all[DateTime.now().millisecondsSinceEpoch % all.length];
  }

  String? _normalizedFruit(String? fruit) {
    final trimmed = fruit?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  Toot? _findTootByFruit(String fruit) {
    final normalizedFruit = fruit.toLowerCase();
    for (final toot in all) {
      if (toot.fruit.toLowerCase() == normalizedFruit) {
        return toot;
      }
    }
    return null;
  }
}
