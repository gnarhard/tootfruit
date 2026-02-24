import 'package:flutter/foundation.dart';

import 'fruit_query_param_update_stub.dart'
    if (dart.library.js_interop) 'fruit_query_param_update_web.dart'
    as fruit_query_updater;

String? readFruitQueryParam() => readFruitQueryParamFromUri(Uri.base);

String? readFruitQueryParamFromUri(Uri uri) {
  final fromQuery = _normalizedFruit(uri.queryParameters['fruit']);
  if (fromQuery != null) {
    return fromQuery;
  }

  final fragment = uri.fragment;
  if (fragment.isEmpty || !fragment.contains('?')) {
    return null;
  }

  final query = fragment.split('?').skip(1).join('?');
  final fromFragment = Uri(query: query).queryParameters['fruit'];
  return _normalizedFruit(fromFragment);
}

Uri? buildFruitQueryUri(Uri currentUri, String fruit) {
  final normalizedFruit = _normalizedFruit(fruit);
  if (normalizedFruit == null) {
    return null;
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

String? _normalizedFruit(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
