import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tootfruit/interfaces/i_audio_player.dart';
import 'package:tootfruit/interfaces/i_storage_repository.dart';
import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/interfaces/i_user_repository.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/models/user.dart';
import 'package:tootfruit/services/navigation_service.dart';

@GenerateMocks([
  IAudioPlayer,
  IStorageRepository,
  ITootRepository,
  IUserRepository,
  NavigationService,
])
void main() {}

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
    String currentFruit = 'peach',
  }) {
    return User(
      currentFruit: currentFruit,
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

const testDuration = Duration(seconds: 3);
