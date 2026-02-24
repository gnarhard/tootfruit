import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toot_service.dart';

import 'env.dart';
import 'locator.dart';

class App extends StatefulWidget {
  const App({super.key});

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
      onGenerateRoute: onGenerateAppRoute,
      onUnknownRoute: onUnknownAppRoute,
      navigatorObservers: [SwitchAudioObserver()],
    );
  }
}

class SwitchAudioObserver extends NavigatorObserver {
  late final _tootService = Locator.get<TootService>();

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute?.settings.name == TootScreen.route) {
      unawaited(
        _tootService.set(_tootService.current).catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          debugPrint(
            'SwitchAudioObserver.didPop: Failed to restore toot audio: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }),
      );
    }
    super.didPop(route, previousRoute);
  }
}
