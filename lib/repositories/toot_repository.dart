import 'package:tootfruit/interfaces/i_toot_repository.dart';
import 'package:tootfruit/models/toot.dart';

/// Concrete implementation of toot repository
/// Single responsibility: Toot data access
class TootRepository implements ITootRepository {
  @override
  List<Toot> getAllToots() => toots;

  @override
  Toot getTootByFruit(String fruit) {
    return toots.firstWhere(
      (toot) => toot.fruit == fruit,
      orElse: () => toots.first,
    );
  }
}
