import 'package:flutter/foundation.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/models/toot.dart';

/// Refactored TootService following SOLID principles
/// Single Responsibility: Manage toot selection and state
/// Dependency Inversion: Depends on abstractions (interfaces)
class TootService {
  final ITootRepository _tootRepository;
  final IUserRepository _userRepository;
  final IAudioPlayer _audioPlayer;

  // State
  final loading = ValueNotifier<bool>(false);
  Toot? _currentToot;
  Toot? newLoot;
  List<Toot> _ownedToots = [];
  bool isRewarded = false;

  /// Constructor with dependency injection
  TootService({
    required ITootRepository tootRepository,
    required IUserRepository userRepository,
    required IAudioPlayer audioPlayer,
  }) : _tootRepository = tootRepository,
       _userRepository = userRepository,
       _audioPlayer = audioPlayer;

  // Getters
  Toot get current => _currentToot ?? _tootRepository.getAllToots().first;
  List<Toot> get owned => _ownedToots;
  List<Toot> get all => _tootRepository.getAllToots();
  bool get ownsEveryToot => all.length == owned.length;

  /// Initialize the service with user data
  Future<void> init() async {
    final user = _userRepository.currentUser;
    if (user == null) {
      throw StateError('User must be loaded before initializing TootService');
    }

    _ownedToots = _tootRepository.getOwnedToots(user.ownedFruit);
    final currentToot = _tootRepository.getTootByFruit(user.currentFruit);
    await setCurrentToot(currentToot);
  }

  /// Set the current toot and update audio
  Future<void> setCurrentToot(Toot toot) async {
    _currentToot = toot;

    try {
      final duration = await _audioPlayer.setAudio(
        'asset:///assets/audio/${toot.fruit}.${toot.fileExtension}',
      );
      toot.duration = duration;
    } catch (error, stackTrace) {
      debugPrint(
        'TootService(refactored).setCurrentToot: '
        'Failed to set audio for ${toot.fruit}: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      toot.duration = Duration.zero;
    }

    await _userRepository.updateCurrentFruit(toot.fruit);
  }

  /// Navigate to next toot in owned list
  Future<void> increment() => _navigateToot(1);

  /// Navigate to previous toot in owned list
  Future<void> decrement() => _navigateToot(-1);

  /// Internal navigation method (DRY principle)
  Future<void> _navigateToot(int direction) async {
    final currentIndex = owned.indexWhere((t) => t.fruit == current.fruit);
    final nextIndex = (currentIndex + direction) % owned.length;
    await setCurrentToot(owned[nextIndex]);
  }

  /// Reward user with a random unclaimed toot
  Future<void> reward() async {
    final user = _userRepository.currentUser!;
    newLoot = _tootRepository.getRandomUnclaimedToot(user.ownedFruit);

    await _userRepository.addOwnedFruit(newLoot!.fruit);
    _ownedToots = _tootRepository.getOwnedToots(user.ownedFruit);

    await setCurrentToot(newLoot!);
    isRewarded = true;
  }

  /// Reward all toots (purchase flow)
  Future<void> rewardAll() async {
    final allFruits = all.map((toot) => toot.fruit).toList();
    await _userRepository.setAllFruitsOwned(allFruits);

    final user = _userRepository.currentUser!;
    _ownedToots = _tootRepository.getOwnedToots(user.ownedFruit);

    await setCurrentToot(all.last);
  }

  /// Initiate purchase of all fruits
  Future<void> purchaseAll() async {
    if (loading.value) return;

    loading.value = true;
    try {
      await rewardAll();
    } finally {
      loading.value = false;
    }
  }

  /// Shuffle to random toot
  void shuffle() {
    _currentToot = all[DateTime.now().millisecondsSinceEpoch % all.length];
  }
}
