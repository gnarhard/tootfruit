/// Audio player interface for playing toot sounds
/// Allows different audio implementations or mocking for tests
abstract class IAudioPlayer {
  /// Initialize the audio player and preload all audio pools
  /// Must be called before any other methods
  Future<void> init();

  /// Set the audio file to play
  /// Returns the duration of the audio
  Future<Duration> setAudio(String assetPath);

  /// Play the current audio
  void play();

  /// Stop the current audio
  Future<void> stop();

  /// Dispose of audio resources
  void dispose();
}
