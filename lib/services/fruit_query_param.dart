import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String? readFruitQueryParam() {
  final fromQuery = _normalizedFruit(Uri.base.queryParameters['fruit']);
  if (fromQuery != null) {
    return fromQuery;
  }

  final fragment = Uri.base.fragment;
  if (fragment.isEmpty || !fragment.contains('?')) {
    return null;
  }

  final query = fragment.split('?').skip(1).join('?');
  final fromFragment = Uri(query: query).queryParameters['fruit'];
  return _normalizedFruit(fromFragment);
}

void writeFruitQueryParam(String fruit) {
  final normalizedFruit = _normalizedFruit(fruit);
  if (!kIsWeb || normalizedFruit == null) {
    return;
  }

  final currentUri = Uri.base;
  final nextQuery = Map<String, String>.from(currentUri.queryParameters);
  nextQuery['fruit'] = normalizedFruit;
  final nextUri = currentUri.replace(queryParameters: nextQuery);

  if (nextUri.toString() == currentUri.toString()) {
    return;
  }

  unawaited(
    SystemNavigator.routeInformationUpdated(uri: nextUri, replace: true),
  );
}

String? _normalizedFruit(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
