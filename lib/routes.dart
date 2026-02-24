import 'package:flutter/material.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/screens/toot_fairy_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';

final routes = <String, Widget Function(BuildContext)>{
  '/': (context) => const LaunchScreen(),
  LaunchScreen.route: (context) => const LaunchScreen(), // /launch
  TootScreen.route: (context) => const TootScreen(), // /toot
  TootFairyScreen.route: (context) => const TootFairyScreen(), // /toot_fairy
};

Route<dynamic>? onGenerateAppRoute(RouteSettings settings) {
  final normalizedRouteName = normalizeRouteName(settings.name);
  final builder = routes[normalizedRouteName];
  if (builder == null) {
    return null;
  }

  return MaterialPageRoute<dynamic>(
    settings: RouteSettings(name: normalizedRouteName),
    builder: builder,
  );
}

Route<dynamic> onUnknownAppRoute(RouteSettings settings) {
  return MaterialPageRoute<dynamic>(
    settings: const RouteSettings(name: LaunchScreen.route),
    builder: (context) => const LaunchScreen(),
  );
}

String normalizeRouteName(String? routeName) {
  final trimmed = routeName?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return LaunchScreen.route;
  }

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null) {
    final fragmentPath = _routePathFromFragment(parsed.fragment);
    if (fragmentPath != null) {
      return fragmentPath;
    }

    if (parsed.path.isNotEmpty) {
      return parsed.path;
    }
  }

  return trimmed.split('?').first;
}

String? _routePathFromFragment(String fragment) {
  if (fragment.isEmpty) {
    return null;
  }

  final fragmentWithoutQuery = fragment.split('?').first;
  if (fragmentWithoutQuery.startsWith('/')) {
    return fragmentWithoutQuery;
  }

  if (fragmentWithoutQuery.startsWith('#/')) {
    return fragmentWithoutQuery.substring(1);
  }

  return null;
}
