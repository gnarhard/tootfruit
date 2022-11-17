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
      color: const Color(0xffff8f8f),
      audioPath: 'asset:///assets/audio/fart1.mp3'),
  Toot(
      fruit: 'blueberry',
      title: 'Pooberry',
      emoji: '🫐',
      color: const Color(0xff375D98),
      audioPath: 'asset:///assets/audio/fart2.mp3'),
  Toot(
      fruit: 'strawberry',
      title: 'Stinky Strawberry',
      emoji: '🍓',
      color: const Color(0xffB1001A),
      audioPath: 'asset:///assets/audio/fart3.mp3'),
  Toot(
      fruit: 'banana',
      title: 'Brown Banana',
      emoji: '🍌',
      color: const Color(0xff964B00),
      audioPath: 'asset:///assets/audio/fart4.mp3'),
];
