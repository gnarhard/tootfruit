import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/connectivity_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';
import '../locator.dart';
import '../screens/toot_screen.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();
  late final _connectivityService = Locator.get<ConnectivityService>();
  late final _audioService = Locator.get<AudioService>();

  bool isSmallScreen = false;

  Future<void> init() async {
    if (kDebugMode && !kIsWeb) {
      await _storageService.deleteStorageFile();
    }
    _connectivityService.init();

    // Initialize audio service (it warms up sources in the background)
    await _audioService.init();

    await _userService.init();
    await _tootService.init();

    await _navigateToTootScreen();
    // if (kDebugMode) {
    //   _navService.current.pushNamed(TootFairyScreen.route);
    // }
  }

  Future<void> _navigateToTootScreen() async {
    while (_navService.navigatorKey.currentState == null) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    _navService.current.pushNamed(TootScreen.route);
  }
}
