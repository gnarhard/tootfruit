import 'package:web/web.dart' as web;

const _initialUrlStorageKey = '__tootfruitInitialUrl';

String? readInitialBrowserUrl() {
  String? value;
  try {
    value = web.window.sessionStorage.getItem(_initialUrlStorageKey);
  } catch (_) {
    value = null;
  }

  if (value == null) {
    return null;
  }

  final trimmed = value.toString().trim();
  if (trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
