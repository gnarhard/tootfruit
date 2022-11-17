import 'dart:ui';

class Toot {
  final String fruit;
  final String title;
  final String emoji;
  final Color color;
  final String audioPath;
  Duration? duration;

  Toot(
      {required this.fruit,
      required this.title,
      required this.emoji,
      required this.color,
      required this.audioPath,
      this.duration});
}

List<Toot> toots = [
  Toot(
      fruit: 'peach',
      title: 'Poopy Peach',
      emoji: '🍑',
      color: const Color(0xffFE9E57),
      audioPath: 'asset:///assets/audio/fart4.m4a'),
  Toot(
      fruit: 'strawberry',
      title: 'Stinky Strawberry',
      emoji: '🍓',
      color: const Color(0xffB1001A),
      audioPath: 'asset:///assets/audio/fart3.mp3'),
  Toot(
      fruit: 'blueberry',
      title: 'Pooberry',
      emoji: '🫐',
      color: const Color(0xff375D98),
      audioPath: 'asset:///assets/audio/fart2.mp3'),
  Toot(
      fruit: 'banana',
      title: 'Brown Banana',
      emoji: '🍌',
      color: const Color(0xff964B00),
      audioPath: 'asset:///assets/audio/fart1.m4a'),
  Toot(
      fruit: 'pineapple',
      title: 'Ploppin\' Pineapple',
      emoji: '🍍',
      color: const Color(0xffE09D32),
      audioPath: 'asset:///assets/audio/fart5.mp3'),
  Toot(
      fruit: 'kiwi',
      title: 'Krappy Kiwi',
      emoji: '🥝',
      color: const Color(0xff8B9E57),
      audioPath: 'asset:///assets/audio/fart6.mp3'),
  Toot(
      fruit: 'mango',
      title: 'Manure Mango',
      emoji: '🥭',
      color: const Color(0xffC59B0C),
      audioPath: 'asset:///assets/audio/fart0.mp3'),
];
