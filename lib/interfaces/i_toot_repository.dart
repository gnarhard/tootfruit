import 'package:tootfruit/models/toot.dart';

/// Toot data repository interface
/// Handles all toot-related data operations
abstract class ITootRepository {
  /// Get all available toots
  List<Toot> getAllToots();

  /// Get a toot by fruit name
  Toot getTootByFruit(String fruit);

  /// Get toots owned by user
  List<Toot> getOwnedToots(List<String> ownedFruits);

  /// Get unclaimed toots
  List<Toot> getUnclaimedToots(List<String> ownedFruits);

  /// Get a random unclaimed toot
  Toot getRandomUnclaimedToot(List<String> ownedFruits);
}
