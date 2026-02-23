import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/models/toot.dart';

/// Concrete implementation of audio player using flutter_soloud
/// Provides audio pooling for all toot sounds for instant playback
class AudioService implements IAudioPlayer {
  bool hasPlayed = false;
  late final SoLoud _soloud;

  // Audio sources cached by normalized asset path (without asset:/// prefix)
  final Map<String, AudioSource> _audioSources = {};
  final Map<String, Future<AudioSource?>> _loadingSources = {};

  // Currently active sound handle
  SoundHandle? _currentHandle;

  // Current normalized audio path being played
  String? _currentAssetPath;

  bool _isInitialized = false;
  bool _isDisposed = false;
  Future<void>? _warmupFuture;

  /// Initialize SoLoud and start background warm-up of all audio files.
  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    _soloud = SoLoud.instance;

    try {
      await _soloud.init();
      _soloud.setGlobalVolume(1.0);
      _isInitialized = true;

      // Warm up sources in the background so app launch is not blocked.
      _warmupFuture ??= _preloadAllAudio();
    } catch (e, stackTrace) {
      debugPrint('AudioService: Failed to initialize SoLoud: $e');
      _log('AudioService: Stack trace: $stackTrace');
      // Keep app startup resilient when audio backend is unavailable (e.g. web).
      _isInitialized = false;
    }
  }

  /// Preload all toot audio files into memory for instant playback.
  Future<void> _preloadAllAudio() async {
    final assetPaths = <String>{
      for (final toot in toots)
        'assets/audio/${toot.fruit}.${toot.fileExtension}',
      'assets/audio/toot_fairy_intro.mp3',
    };

    await Future.wait(assetPaths.map(_ensureAudioSourceLoaded));
    _log('AudioService: Warm-up complete (${_audioSources.length} sources)');
  }

  /// Load a single audio source and cache it.
  Future<AudioSource?> _ensureAudioSourceLoaded(String assetPath) async {
    final normalizedPath = _normalizeAssetPath(assetPath);
    final existing = _audioSources[normalizedPath];
    if (existing != null) {
      return existing;
    }

    final inFlightLoad = _loadingSources[normalizedPath];
    if (inFlightLoad != null) {
      return inFlightLoad;
    }

    final loadFuture = _loadAndCacheAudioSource(normalizedPath);
    _loadingSources[normalizedPath] = loadFuture;
    return loadFuture;
  }

  Future<AudioSource?> _loadAndCacheAudioSource(String normalizedPath) async {
    try {
      if (!_isInitialized || _isDisposed) {
        return null;
      }

      final source = await _soloud.loadAsset(normalizedPath);
      if (_isDisposed) {
        _soloud.disposeSource(source);
        return null;
      }

      _audioSources[normalizedPath] = source;
      return source;
    } catch (e, stackTrace) {
      debugPrint('AudioService: Failed to load $normalizedPath: $e');
      _log('AudioService: Stack trace: $stackTrace');
      return null;
    } finally {
      _loadingSources.remove(normalizedPath);
    }
  }

  @override
  Future<Duration> setAudio(String assetPath) async {
    if (!_isInitialized) {
      return Duration.zero;
    }

    if (_currentHandle != null) {
      await stop();
    }

    final normalizedPath = _normalizeAssetPath(assetPath);
    var source = _audioSources[normalizedPath];
    source ??= await _ensureAudioSourceLoaded(normalizedPath);

    if (source == null) {
      debugPrint('AudioService: Failed to prepare $normalizedPath');
      return Duration.zero;
    }

    _currentAssetPath = normalizedPath;
    return _soloud.getLength(source);
  }

  @override
  void play() {
    if (!_isInitialized) {
      return;
    }

    if (_currentAssetPath == null) {
      return;
    }

    final source = _audioSources[_currentAssetPath!];

    if (source == null) {
      debugPrint('AudioService: Audio source not found for $_currentAssetPath');
      return;
    }

    _playAsync(source);
  }

  /// Internal async play method.
  Future<void> _playAsync(AudioSource source) async {
    try {
      if (!_isInitialized || _isDisposed) {
        return;
      }

      if (_currentHandle != null) {
        _soloud.stop(_currentHandle!);
        _currentHandle = null;
      }

      _currentHandle = await _soloud.play(source, volume: 1.0);
      hasPlayed = true;
    } catch (e, stackTrace) {
      debugPrint('AudioService: Error playing audio: $e');
      _log('AudioService: Stack trace: $stackTrace');
    }
  }

  @override
  Future<void> stop() async {
    if (_currentHandle != null) {
      try {
        _soloud.stop(_currentHandle!);
        _currentHandle = null;
      } catch (e) {
        debugPrint('AudioService: Error stopping audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    if (_currentHandle != null) {
      _soloud.stop(_currentHandle!);
      _currentHandle = null;
    }

    final uniqueSources = _audioSources.values.toSet();
    for (final source in uniqueSources) {
      _soloud.disposeSource(source);
    }
    _audioSources.clear();
    _loadingSources.clear();
    _warmupFuture = null;

    if (_isInitialized) {
      _soloud.deinit();
      _isInitialized = false;
    }
  }

  String _normalizeAssetPath(String assetPath) {
    if (assetPath.startsWith('asset:///')) {
      return assetPath.substring('asset:///'.length);
    }
    if (assetPath.startsWith('asset://')) {
      return assetPath.substring('asset://'.length);
    }
    return assetPath;
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
