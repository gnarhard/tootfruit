import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/theme_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';
import 'package:tooty_fruity/services/user_service.dart';

import '../locator.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _themeService = Locator.get<ThemeService>();
  late final _tootService = Locator.get<TootService>();
  late final _userService = Locator.get<UserService>();

  Future<void> init() async {
    await _userService.init();

    await Future.wait([
      _themeService.init(), // Discover the stored theme.
      _tootService.init()
    ]);

    _navService.current.pushNamed(TootScreen.route);
  }

  Future<void> postLoginInit() async {}
}
