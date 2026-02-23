import 'package:flutter/foundation.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/interfaces/i_toast_service.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/repositories/toot_repository.dart';
import 'package:tootfruit/repositories/user_repository.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/connectivity_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/services/toot_service_refactored.dart';

/// Dependency Injection Container following SOLID principles
/// Single Responsibility: Wire up dependencies
/// Dependency Inversion: Register interfaces, not implementations
class DependencyInjection {
  // Singletons
  late final IToastService toastService;
  late final IStorageRepository storageRepository;
  late final IUserRepository userRepository;
  late final ITootRepository tootRepository;
  late final IAudioPlayer audioPlayer;
  late final NavigationService navigationService;
  late final ConnectivityService connectivityService;
  late final TootService tootService;

  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  bool _initialized = false;

  /// Initialize all dependencies with proper injection
  void initialize() {
    if (_initialized) {
      debugPrint('Dependencies already initialized.');
      return;
    }

    // Layer 1: Core services with no dependencies
    toastService = ToastService();
    tootRepository = TootRepository();
    audioPlayer = AudioService();
    navigationService = NavigationService();
    connectivityService = ConnectivityService();

    // Layer 2: Repositories that depend on core services
    storageRepository = FileStorageRepository(toastService);
    userRepository = UserRepository(storageRepository);

    // Layer 3: Services with dependencies
    tootService = TootService(
      tootRepository: tootRepository,
      userRepository: userRepository,
      audioPlayer: audioPlayer,
    );

    _initialized = true;
    debugPrint('Dependencies initialized successfully');
  }

  /// Reset for testing
  @visibleForTesting
  void reset() {
    _initialized = false;
  }
}
