import 'package:flutter/foundation.dart';
import 'package:tootfruit/services/connectivity_service.dart';
import 'package:tootfruit/services/google_ad_service.dart';
import 'package:tootfruit/services/in_app_purchase_service.dart';
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
  late final _googleAdService = Locator.get<GoogleAdService>();
  late final _connectivityService = Locator.get<ConnectivityService>();
  late final _inAppPurchaseService = Locator.get<InAppPurchaseService>();

  bool isSmallScreen = false;

  Future<void> init() async {
    if (kDebugMode) {
      await _storageService.deleteStorageFile();
    }
    await _connectivityService.init();
    await _userService.init();
    await _tootService.init();
    await _googleAdService.createRewardedAd();
    _inAppPurchaseService.init();

    _navService.current.pushNamed(TootScreen.route);
    // _navService.current.pushNamed(TootFairyScreen.route);
  }
}
