import 'package:flutter/foundation.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/repositories/storage_repository.dart';
import 'package:tootfruit/services/toot_screen_route.dart';

class InitService {
  final DI _di = DI();

  Future<void> init() async {
    if (kDebugMode) {
      final storage = _di.storageRepository as FileStorageRepository;
      await storage.deleteStorageFile();
    }

    await _di.audioPlayer.init();
    await _di.userRepository.loadUser();
    await _di.tootService.init();

    await _navigateToTootScreen();
  }

  Future<void> _navigateToTootScreen() async {
    while (_di.navigationService.navigatorKey.currentState == null) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    _di.navigationService.current.pushReplacement(
      buildInitialTootScreenRoute(),
    );
  }
}
