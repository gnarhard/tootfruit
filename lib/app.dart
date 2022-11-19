import 'package:flutter/material.dart';
import 'package:tooty_fruity/routes.dart';
import 'package:tooty_fruity/screens/launch_screen.dart';
import 'package:tooty_fruity/screens/toot_screen.dart';
import 'package:tooty_fruity/services/navigation_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';

import 'env.dart';
import 'locator.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navService = Locator.get<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Env.title,
      themeMode: ThemeMode.dark,
      navigatorKey: _navService.navigatorKey,
      initialRoute: LaunchScreen.route,
      routes: routes,
      navigatorObservers: [SwitchAudioObserver()],
    );
  }
}

class SwitchAudioObserver extends NavigatorObserver {
  late final _tootService = Locator.get<TootService>();

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute?.settings.name == TootScreen.route) {
      _tootService.set(_tootService.current$.value);
    }
    super.didPop(route, previousRoute);
  }
}
