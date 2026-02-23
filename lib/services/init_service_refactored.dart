import 'package:flutter/foundation.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/screens/toot_screen.dart';

/// Refactored InitService following Single Responsibility Principle
/// Responsibility: Initialize app services in correct order
class InitService {
  final DependencyInjection _di = DependencyInjection();

  /// Initialize all app services
  Future<void> init() async {
    // Initialize DI container
    _di.initialize();

    // Debug: Clear storage in debug mode
    if (kDebugMode) {
      final storage = _di.storageRepository as FileStorageRepository;
      await storage.deleteStorageFile();
    }

    // Initialize connectivity monitoring
    _di.connectivityService.init();

    // Initialize audio service and preload all audio pools
    await _di.audioPlayer.init();

    // Load user data
    await _di.userRepository.loadUser();

    // Initialize toot service
    await _di.tootService.init();

    // Navigate to main screen
    await _navigateToTootScreen();
  }

  Future<void> _navigateToTootScreen() async {
    while (_di.navigationService.navigatorKey.currentState == null) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    _di.navigationService.current.pushNamed(TootScreen.route);
  }
}
