import 'package:flutter/foundation.dart';

import 'fruit_query_param_update_stub.dart'
    if (dart.library.html) 'fruit_query_param_update_web.dart'
    as fruit_query_updater;
import 'fruit_query_param_initial_url_stub.dart'
    if (dart.library.html) 'fruit_query_param_initial_url_web.dart'
    as fruit_query_initial_url;

final Uri _startupUri = _resolveStartupUri();

const Set<String> _reservedRouteSegments = <String>{
  'launch',
  'toot',
  'toot_fairy',
};
const String _tootRouteSegment = 'toot';

String? readFruitQueryParam() {
  final currentUri = Uri.base;
  if (kIsWeb) {
    debugPrint(
      'Fruit URL read: current=$currentUri startup=$_startupUri initial=${fruit_query_initial_url.readInitialBrowserUrl()}',
    );
  }
  final fruitFromCurrentUri = readFruitQueryParamFromUri(currentUri);
  if (fruitFromCurrentUri != null) {
    return fruitFromCurrentUri;
  }

  final startupUri = _startupUri;
  if (startupUri.toString() == currentUri.toString()) {
    return null;
  }

  return readFruitQueryParamFromUri(startupUri);
}

String? readFruitQueryParamFromUri(Uri uri) {
  final fromPath = _readFruitFromRoutePath(uri.path);
  if (fromPath != null) {
    return fromPath;
  }

  final fromFragmentPath = _readFruitFromFragmentPath(uri.fragment);
  if (fromFragmentPath != null) {
    return fromFragmentPath;
  }

  final fromFragmentQuery = _readFruitFromFragmentQuery(uri.fragment);
  if (fromFragmentQuery != null) {
    return fromFragmentQuery;
  }

  return _normalizedFruit(uri.queryParameters['fruit']);
}

Uri? buildFruitQueryUri(Uri currentUri, String fruit) {
  final normalizedFruit = _normalizedFruit(fruit);
  if (normalizedFruit == null) {
    return null;
  }

  final canonicalTootPath = '/$_tootRouteSegment/$normalizedFruit';

  final nextQuery = Map<String, String>.from(currentUri.queryParameters)
    ..remove('fruit');

  return Uri(
    scheme: currentUri.scheme,
    userInfo: currentUri.userInfo,
    host: currentUri.host,
    port: currentUri.hasPort ? currentUri.port : null,
    path: canonicalTootPath,
    queryParameters: nextQuery.isEmpty ? null : nextQuery,
  );
}

void writeFruitQueryParam(String fruit) {
  if (!kIsWeb) {
    return;
  }

  final currentUri = Uri.base;
  final nextUri = buildFruitQueryUri(currentUri, fruit);
  if (nextUri == null || nextUri.toString() == currentUri.toString()) {
    return;
  }

  try {
    fruit_query_updater.replaceBrowserUrl(nextUri);
  } catch (_) {
    // URL sync is best-effort; navigation should continue even if browser URL update fails.
  }
}

Uri _resolveStartupUri() {
  final initialBrowserUrl = fruit_query_initial_url.readInitialBrowserUrl();
  if (initialBrowserUrl == null) {
    return Uri.base;
  }

  final parsedInitialBrowserUrl = Uri.tryParse(initialBrowserUrl);
  return parsedInitialBrowserUrl ?? Uri.base;
}

String? _readFruitFromFragmentPath(String fragment) {
  if (fragment.isEmpty) {
    return null;
  }

  return _readFruitFromRoutePath(_routePathFromFragment(fragment));
}

String? _readFruitFromFragmentQuery(String fragment) {
  if (fragment.isEmpty || !fragment.contains('?')) {
    return null;
  }

  final query = fragment.split('?').skip(1).join('?');
  final fromFragment = Uri(query: query).queryParameters['fruit'];
  return _normalizedFruit(fromFragment);
}

String? _readFruitFromRoutePath(String routePath) {
  final pathWithoutQuery = routePath.split('?').first.trim();
  if (pathWithoutQuery.isEmpty) {
    return null;
  }

  final segments = pathWithoutQuery
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (segments.isEmpty) {
    return null;
  }

  if (segments.length == 1) {
    return _normalizedFruitFromSegment(segments.first);
  }

  final firstSegment = segments.first.toLowerCase();
  if (firstSegment == 'toot' && segments.length > 1) {
    return _normalizedFruitFromSegment(segments[1]);
  }

  return null;
}

String _routePathFromFragment(String fragment) {
  final pathWithoutQuery = fragment.split('?').first.trim();
  if (pathWithoutQuery.isEmpty) {
    return '';
  }

  if (pathWithoutQuery.startsWith('#/')) {
    return pathWithoutQuery.substring(1);
  }

  if (pathWithoutQuery.startsWith('/')) {
    return pathWithoutQuery;
  }

  return '/$pathWithoutQuery';
}

String? _normalizedFruitFromSegment(String segment) {
  final normalizedSegment = segment.trim().toLowerCase();
  if (_reservedRouteSegments.contains(normalizedSegment)) {
    return null;
  }

  return _normalizedFruit(segment);
}

String? _normalizedFruit(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
