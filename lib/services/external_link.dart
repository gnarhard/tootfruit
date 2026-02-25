import 'external_link_stub.dart'
    if (dart.library.html) 'external_link_web.dart'
    as external_link;

typedef ExternalLinkOpener = Future<void> Function(Uri uri);

Future<void> openExternalLink(Uri uri) => external_link.openExternalLink(uri);
