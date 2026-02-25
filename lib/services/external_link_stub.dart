import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalLink(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
