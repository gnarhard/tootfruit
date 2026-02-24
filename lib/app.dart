import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tootfruit/core/dependency_injection.dart';
import 'package:tootfruit/routes.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

import 'env.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _di = DI();

  List<Route<dynamic>> _onGenerateInitialRoutes(String initialRouteName) {
    debugPrint('Initial route name: $initialRouteName');
    final trimmed = initialRouteName.trim();
    final routeName = trimmed.isEmpty ? LaunchScreen.route : trimmed;

    return <Route<dynamic>>[
      MaterialPageRoute<dynamic>(
        settings: RouteSettings(name: routeName),
        builder: (context) => const LaunchScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Env.title,
      themeMode: ThemeMode.dark,
      navigatorKey: _di.navigationService.navigatorKey,
      onGenerateInitialRoutes: _onGenerateInitialRoutes,
      routes: routes,
      onGenerateRoute: onGenerateAppRoute,
      onUnknownRoute: onUnknownAppRoute,
      navigatorObservers: [SwitchAudioObserver()],
    );
  }
}

class SwitchAudioObserver extends NavigatorObserver {
  final _tootService = DI().tootService;

  @override
  void didPop(Route route, Route? previousRoute) {
    if (normalizeRouteName(previousRoute?.settings.name) == TootScreen.route) {
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
