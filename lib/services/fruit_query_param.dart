import 'package:flutter/foundation.dart';

import 'fruit_query_param_update_stub.dart'
    if (dart.library.js_interop) 'fruit_query_param_update_web.dart'
    as fruit_query_updater;

String? readFruitQueryParam() => readFruitQueryParamFromUri(Uri.base);

String? readFruitQueryParamFromUri(Uri uri) {
  final fromFragment = _readFruitFromFragment(uri.fragment);
  if (fromFragment != null) {
    return fromFragment;
  }

  return _normalizedFruit(uri.queryParameters['fruit']);
}

Uri? buildFruitQueryUri(Uri currentUri, String fruit) {
  final normalizedFruit = _normalizedFruit(fruit);
  if (normalizedFruit == null) {
    return null;
  }

  if (currentUri.fragment.isNotEmpty) {
    final fragmentParts = currentUri.fragment.split('?');
    final fragmentPath = fragmentParts.first;
    final existingFragmentQuery = fragmentParts.length > 1
        ? fragmentParts.sublist(1).join('?')
        : '';
    final fragmentQueryParameters = Map<String, String>.from(
      Uri(query: existingFragmentQuery).queryParameters,
    );
    fragmentQueryParameters['fruit'] = normalizedFruit;
    final nextFragmentQuery = Uri(
      queryParameters: fragmentQueryParameters,
    ).query;
    final nextFragment = nextFragmentQuery.isEmpty
        ? fragmentPath
        : '$fragmentPath?$nextFragmentQuery';

    final nextQuery = Map<String, String>.from(currentUri.queryParameters)
      ..remove('fruit');

    return Uri(
      scheme: currentUri.scheme,
      userInfo: currentUri.userInfo,
      host: currentUri.host,
      port: currentUri.hasPort ? currentUri.port : null,
      path: currentUri.path,
      queryParameters: nextQuery.isEmpty ? null : nextQuery,
      fragment: nextFragment,
    );
  }

  final nextQuery = Map<String, String>.from(currentUri.queryParameters);
  nextQuery['fruit'] = normalizedFruit;
  return currentUri.replace(queryParameters: nextQuery);
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

String? _readFruitFromFragment(String fragment) {
  if (fragment.isEmpty || !fragment.contains('?')) {
    return null;
  }

  final query = fragment.split('?').skip(1).join('?');
  final fromFragment = Uri(query: query).queryParameters['fruit'];
  return _normalizedFruit(fromFragment);
}

String? _normalizedFruit(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
