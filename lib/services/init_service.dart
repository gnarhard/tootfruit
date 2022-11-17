import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/theme_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import '../locator.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _themeService = Locator.get<ThemeService>();
  late final _audioService = Locator.get<AudioService>();
  late final _tootService = Locator.get<TootService>();

  Future<void> init() async {
    // Initialize pre-login listeners.
    await Future.wait([
      _themeService.init(), // Discover the stored theme.
      _audioService.init(), // Setup audio listeners.
    ]);

    _navService.current.pushNamed(TootScreen.route);
  }

  Future<void> postLoginInit() async {}
}
