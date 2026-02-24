import 'dart:io';

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
  });
}
