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
  });
}
