import 'dart:math';

import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/models/toot.dart';

/// Concrete implementation of toot repository
/// Single responsibility: Toot data access
class TootRepository implements ITootRepository {
  final Random _random = Random();

  @override
  List<Toot> getAllToots() => toots;

  @override
  Toot getTootByFruit(String fruit) {
    return toots.firstWhere(
      (toot) => toot.fruit == fruit,
      orElse: () => toots.first,
    );
  }

  @override
  List<Toot> getOwnedToots(List<String> ownedFruits) {
    return ownedFruits
        .map((fruit) => getTootByFruit(fruit))
        .toList();
  }

  @override
  List<Toot> getUnclaimedToots(List<String> ownedFruits) {
    final allSet = toots.toSet();
    final ownedSet = getOwnedToots(ownedFruits).toSet();
    return allSet.difference(ownedSet).toList();
  }

  @override
  Toot getRandomUnclaimedToot(List<String> ownedFruits) {
    final unclaimed = getUnclaimedToots(ownedFruits);
    if (unclaimed.isEmpty) {
      throw StateError('No unclaimed toots available');
    }
    return unclaimed[_random.nextInt(unclaimed.length)];
  }
}
