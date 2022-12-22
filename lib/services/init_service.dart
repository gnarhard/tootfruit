import 'package:flutter/cupertino.dart';
import 'package:tootfruit/services/google_ad_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

import '../locator.dart';
import '../screens/toot_fairy_screen.dart';
import '../screens/toot_screen.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();
  late final _googleAdService = Locator.get<GoogleAdService>();

  bool isSmallScreen = false;

  double get headingFontSize => isSmallScreen ? 16 : 26;

  Future<void> init(context) async {
    // await _storageService.deleteStorageFile();
    await TootFairyScreen.precacheImages(context);
    await _userService.init();
    await _tootService.init();
    await _googleAdService.createRewardedAd();

    if (MediaQuery.of(context).size.width < 400) {
      isSmallScreen = true;
    }

    _navService.current.pushNamed(TootScreen.route);
    // _navService.current.pushNamed(TootFairyScreen.route);
  }
}
