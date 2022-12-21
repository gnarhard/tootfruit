import 'package:flutter/cupertino.dart';
import 'package:toot_fruit/services/storage_service.dart';
import 'package:toot_fruit/services/theme_service.dart';
import 'package:toot_fruit/services/toot_service.dart';
import 'package:toot_fruit/services/user_service.dart';

import '../locator.dart';
import '../screens/toot_fairy_screen.dart';
import '../screens/toot_screen.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _themeService = Locator.get<ThemeService>();
  late final _tootService = Locator.get<TootService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();

  bool isSmallScreen = false;

  double get headingFontSize => isSmallScreen ? 16 : 26;

  Future<void> init(context) async {
    // await _storageService.deleteStorageFile();
    await TootFairyScreen.precacheImages(context);
    await _userService.init();

    await Future.wait([
      _themeService.init(), // Discover the stored theme.
      _tootService.init()
    ]);

    if (MediaQuery.of(context).size.width < 400) {
      isSmallScreen = true;
    }

    _navService.current.pushNamed(TootScreen.route);
    // _navService.current.pushNamed(TootFairyScreen.route);
  }
}
