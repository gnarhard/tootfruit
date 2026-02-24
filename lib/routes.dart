import 'package:flutter/material.dart';
import 'package:tootfruit/models/toot.dart';
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
  if (_isFruitRouteName(settings.name)) {
    return MaterialPageRoute<dynamic>(
      settings: RouteSettings(name: settings.name),
      builder: routes[LaunchScreen.route]!,
    );
  }

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
      return _normalizeAppRoutePath(fragmentPath);
    }

    if (parsed.path.isNotEmpty) {
      return _normalizeAppRoutePath(parsed.path);
    }
  }

  return _normalizeAppRoutePath(trimmed.split('?').first);
}

bool _isFruitRouteName(String? routeName) {
  final trimmed = routeName?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return false;
  }

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null) {
    final fragmentPath = _routePathFromFragment(parsed.fragment);
    if (fragmentPath != null && _isFruitRoutePath(fragmentPath)) {
      return true;
    }

    if (parsed.path.isNotEmpty && _isFruitRoutePath(parsed.path)) {
      return true;
    }
  }

  return _isFruitRoutePath(trimmed.split('?').first);
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

String _normalizeAppRoutePath(String routePath) {
  final pathWithoutQuery = routePath.split('?').first;
  if (_isFruitRoutePath(pathWithoutQuery)) {
    return TootScreen.route;
  }

  return pathWithoutQuery;
}

bool _isFruitRoutePath(String routePath) {
  final segments = routePath
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (segments.isEmpty) {
    return false;
  }

  if (segments.length == 1) {
    return _isKnownFruit(segments.first);
  }

  if (segments.length == 2 && segments.first.toLowerCase() == 'toot') {
    return _isKnownFruit(segments[1]);
  }

  return false;
}

bool _isKnownFruit(String routeSegment) {
  final normalizedRouteSegment = routeSegment.toLowerCase();
  for (final toot in toots) {
    if (toot.fruit.toLowerCase() == normalizedRouteSegment) {
      return true;
    }
  }
  return false;
}
