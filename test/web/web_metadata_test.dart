import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Web metadata', () {
    test('index.html uses required sharing description and icon tags', () {
      final html = File('web/index.html').readAsStringSync();
      const description =
          'This fruity little fart app allows you to swipe between different fruit images and revel in a carefully curated collection of scatalogical delights.';
      const iconPath = 'assets/images/app_icon_512x512.png';

      expect(
        html,
        contains('<meta name="description" content="$description">'),
      );
      expect(
        html,
        contains('<meta property="og:description" content="$description">'),
      );
      expect(
        html,
        contains('<meta name="twitter:description" content="$description">'),
      );
      expect(html, contains('<meta property="og:image" content="$iconPath">'));
      expect(html, contains('<meta name="twitter:image" content="$iconPath">'));
    });

    test('index.html configures iOS web audio session for playback mode', () {
      final html = File('web/index.html').readAsStringSync();

      expect(html, contains("const isIos ="));
      expect(html, contains("const audioSession = navigator.audioSession;"));
      expect(html, contains("audioSession.type = 'playback';"));
      expect(html, contains("function legacyUnlockWebAudio()"));
      expect(
        html,
        contains(
          "'data:audio/wav;base64,UklGRisAAABXQVZFZm10IBAAAAABAAEAESsAAESsAAABAAgAZGF0YQcAAACAgICAgICAAAA='",
        ),
      );
      expect(
        html,
        contains(
          "const activationEvents = ['touchend', 'pointerup', 'click', 'keydown'];",
        ),
      );
    });

    test('index.html and manifest use Icon-512.png for web icons', () {
      final html = File('web/index.html').readAsStringSync();
      final manifestJson =
          jsonDecode(File('web/manifest.json').readAsStringSync())
              as Map<String, dynamic>;
      final icons = (manifestJson['icons'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(
        html,
        contains('<link rel="apple-touch-icon" href="icons/Icon-512.png">'),
      );
      expect(
        html,
        contains(
          '<link rel="icon" type="image/png" href="icons/Icon-512.png"/>',
        ),
      );

      for (final icon in icons) {
        expect(icon['src'], equals('icons/Icon-512.png'));
      }
    });

    test('all web icon files match Icon-512.png bytes', () {
      final icon512Bytes = File('web/icons/Icon-512.png').readAsBytesSync();
      final filesThatMustMatch = <String>[
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
      ];

      for (final path in filesThatMustMatch) {
        expect(
          File(path).readAsBytesSync(),
          orderedEquals(icon512Bytes),
          reason: '$path should match web/icons/Icon-512.png',
        );
      }
    });
  });
}
