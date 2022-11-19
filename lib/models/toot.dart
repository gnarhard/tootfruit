import 'dart:ui';

import 'package:flutter/material.dart';

class Toot {
  final String fruit;
  final String title;
  final String emoji;
  final String fileExtension;
  final Color color;
  final bool darkText;
  Duration? duration;

  Toot({
    required this.fruit,
    required this.title,
    required this.emoji,
    required this.color,
    this.duration,
    this.darkText = false,
    this.fileExtension = 'm4a',
  });
}

List<Toot> toots = [
  Toot(
    fruit: 'peach',
    title: 'Poopy Peach',
    emoji: '🍑',
    color: const Color(0xffFE9E57),
  ),
  Toot(
    fruit: 'strawberry',
    title: 'Stinky Strawberry',
    emoji: '🍓',
    color: const Color(0xffe34b50),
  ),
  Toot(
    fruit: 'blueberry',
    title: 'Pooberry',
    fileExtension: 'mp3',
    emoji: '🫐',
    color: const Color(0xff4f86f7),
  ),
  Toot(
    fruit: 'banana',
    title: 'Brown Banana',
    emoji: '🍌',
    darkText: true,
    color: const Color(0xfffff263),
  ),
  Toot(
    fruit: 'cherry',
    title: 'Airy Cherry',
    emoji: '🍒',
    color: const Color(0xffD2042D),
  ),
  Toot(
    fruit: 'pineapple',
    title: 'Ploppin\' Pineapple',
    emoji: '🍍',
    darkText: true,
    color: const Color(0xffFEEA63),
  ),
  Toot(
    fruit: 'kiwi',
    title: 'Krappy Kiwi',
    fileExtension: 'mp3',
    emoji: '🥝',
    color: const Color(0xffB9CA50),
  ),
  Toot(
    fruit: 'mango',
    title: 'Manure Mango',
    fileExtension: 'mp3',
    emoji: '🥭',
    color: const Color(0xffF4BB44),
  ),
  Toot(
    fruit: 'tomato',
    title: 'Tooty Tomato',
    emoji: '🍅',
    color: const Color(0xffff6347),
  ),
  Toot(
    fruit: 'pear',
    title: 'Putrid Pear',
    emoji: '🍐',
    darkText: true,
    color: const Color(0xffd1e231),
  ),
  Toot(
    fruit: 'grape',
    title: 'Gassy Grape',
    emoji: '🍇',
    color: const Color(0xff6f2da8),
  ),
  Toot(
    fruit: 'lemon',
    title: 'Lewd Lemon',
    emoji: '🍋',
    darkText: true,
    color: const Color(0xfffff44f),
  ),
  Toot(
    fruit: 'coconut',
    title: 'Cocobutt',
    emoji: '🥥',
    color: const Color(0xff965A3E),
  ),
  Toot(
    fruit: 'avocado',
    title: 'Acrid Avocado',
    emoji: '🥑',
    color: const Color(0xff648000),
  ),
  Toot(
    fruit: 'orange',
    title: 'Oderous Orange',
    fileExtension: 'mp3',
    emoji: '🍊',
    color: const Color(0xffffa836),
  ),
  Toot(
    fruit: 'watermelon',
    title: 'Watersmellon',
    emoji: '🍉',
    color: const Color(0xffE37383),
  ),
  Toot(
    fruit: 'apple',
    title: 'Sour Apple',
    fileExtension: 'mp3',
    emoji: '🍏',
    color: const Color(0xff78a24c),
  ),
];
