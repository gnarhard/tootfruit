import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/interfaces/i_toast_service.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/models/settings.dart';
import 'package:tootfruit/services/navigation_service.dart';

/// Test helpers and common utilities for testing

// Generate mocks for all interfaces
@GenerateMocks([
  IAudioPlayer,
  IStorageRepository,
  IToastService,
  ITootRepository,
  IUserRepository,
  NavigationService,
])
void main() {}

/// Test data builders
class TestData {
  static Toot createToot({
    String fruit = 'apple',
    String title = 'Test Apple',
    String emoji = '🍎',
    String fileExtension = 'mp3',
  }) {
    return Toot(
      fruit: fruit,
      title: title,
      emoji: emoji,
      color: const Color(0xFFFF0000),
      fileExtension: fileExtension,
    );
  }

  static User createUser({
    List<String>? ownedFruit,
    String currentFruit = 'peach',
  }) {
    return User(
      ownedFruit: ownedFruit ?? ['peach'],
      currentFruit: currentFruit,
      settings: Settings(),
    );
  }

  static List<Toot> createTootList() {
    return [
      createToot(fruit: 'peach', title: 'Poopy Peach', emoji: '🍑'),
      createToot(fruit: 'apple', title: 'Airy Apple', emoji: '🍎'),
      createToot(fruit: 'banana', title: 'Brown Banana', emoji: '🍌'),
    ];
  }
}

/// Custom matchers
class IsToot extends Matcher {
  final String fruit;

  IsToot(this.fruit);

  @override
  bool matches(dynamic item, Map matchState) {
    return item is Toot && item.fruit == fruit;
  }

  @override
  Description describe(Description description) {
    return description.add('is Toot with fruit: $fruit');
  }
}

/// Verify helpers - Re-export from mockito for convenience
// Note: verifyNever and verifyInOrder are already exported by mockito/mockito.dart
// so we don't need custom wrappers

/// Useful constants
const testDuration = Duration(seconds: 3);
