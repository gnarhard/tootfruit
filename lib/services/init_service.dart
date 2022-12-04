import 'package:tooty_fruity/services/theme_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import '../locator.dart';
import '../models/toot.dart';
import '../screens/toot_loot_screen.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _themeService = Locator.get<ThemeService>();
  late final _tootService = Locator.get<TootService>();

  Future<void> init() async {
    // Initialize pre-login listeners.
    await Future.wait([
      _themeService.init(), // Discover the stored theme.
      _tootService.set(toots.first)
    ]);

    _navService.current.pushNamed(TootLootScreen.route);
  }

  Future<void> postLoginInit() async {}
}
