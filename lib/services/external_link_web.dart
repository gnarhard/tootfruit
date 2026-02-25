import 'package:web/web.dart' as web;

Future<void> openExternalLink(Uri uri) async {
  final url = uri.toString();
  final openedWindow = web.window.open(url, '_blank');

  // Some browsers block popups even for taps; keep navigation working anyway.
  if (openedWindow == null) {
    web.window.location.href = url;
  }
}
