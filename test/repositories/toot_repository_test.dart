import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/repositories/toot_repository.dart';

void main() {
  group('TootRepository', () {
    late TootRepository repository;

    setUp(() {
      repository = TootRepository();
    });

    group('getAllToots', () {
      test('returns all available toots', () {
        final result = repository.getAllToots();

        expect(result, isNotEmpty);
        expect(result, hasLength(17));
        expect(result.first.fruit, equals('peach'));
      });

      test('returns the same list on multiple calls', () {
        final result1 = repository.getAllToots();
        final result2 = repository.getAllToots();

        expect(result1, equals(result2));
      });
    });

    group('getTootByFruit', () {
      test('returns correct toot for valid fruit name', () {
        final result = repository.getTootByFruit('banana');

        expect(result.fruit, equals('banana'));
        expect(result.title, equals('Brown Banana'));
        expect(result.emoji, equals('🍌'));
      });

      test('returns first toot when fruit not found', () {
        final result = repository.getTootByFruit('nonexistent');

        expect(result, equals(repository.getAllToots().first));
      });

      test('works for all toots in the list', () {
        final allToots = repository.getAllToots();

        for (final toot in allToots) {
          final result = repository.getTootByFruit(toot.fruit);
          expect(result, equals(toot));
        }
      });
    });

    group('getOwnedToots', () {
      test('returns empty list for empty owned fruits', () {
        final result = repository.getOwnedToots([]);

        expect(result, isEmpty);
      });

      test('returns correct toots for owned fruits', () {
        final ownedFruits = ['peach', 'banana', 'cherry'];
        final result = repository.getOwnedToots(ownedFruits);

        expect(result, hasLength(3));
        expect(result[0].fruit, equals('peach'));
        expect(result[1].fruit, equals('banana'));
        expect(result[2].fruit, equals('cherry'));
      });

      test('maintains order of owned fruits', () {
        final ownedFruits = ['cherry', 'peach', 'banana'];
        final result = repository.getOwnedToots(ownedFruits);

        expect(result[0].fruit, equals('cherry'));
        expect(result[1].fruit, equals('peach'));
        expect(result[2].fruit, equals('banana'));
      });
    });

    group('getUnclaimedToots', () {
      test('returns all toots when none are owned', () {
        final result = repository.getUnclaimedToots([]);

        expect(result, hasLength(17));
      });

      test('returns only unclaimed toots', () {
        final ownedFruits = ['peach', 'banana'];
        final result = repository.getUnclaimedToots(ownedFruits);

        expect(result, hasLength(15));
        expect(result.every((t) => !ownedFruits.contains(t.fruit)), isTrue);
      });

      test('returns empty list when all toots are owned', () {
        final allFruits = repository.getAllToots().map((t) => t.fruit).toList();
        final result = repository.getUnclaimedToots(allFruits);

        expect(result, isEmpty);
      });
    });

    group('getRandomUnclaimedToot', () {
      test('returns a toot that is not owned', () {
        final ownedFruits = ['peach', 'banana'];
        final result = repository.getRandomUnclaimedToot(ownedFruits);

        expect(ownedFruits.contains(result.fruit), isFalse);
      });

      test('returns different toots on multiple calls (probabilistic)', () {
        final ownedFruits = ['peach'];
        final results = <String>{};

        // Call multiple times to get different results
        for (int i = 0; i < 20; i++) {
          final result = repository.getRandomUnclaimedToot(ownedFruits);
          results.add(result.fruit);
        }

        // Should get at least 2 different fruits in 20 tries
        expect(results.length, greaterThan(1));
      });

      test('throws StateError when all toots are owned', () {
        final allFruits = repository.getAllToots().map((t) => t.fruit).toList();

        expect(
          () => repository.getRandomUnclaimedToot(allFruits),
          throwsStateError,
        );
      });

      test('throws StateError with descriptive message', () {
        final allFruits = repository.getAllToots().map((t) => t.fruit).toList();

        expect(
          () => repository.getRandomUnclaimedToot(allFruits),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('No unclaimed toots available'),
            ),
          ),
        );
      });
    });
  });
}
