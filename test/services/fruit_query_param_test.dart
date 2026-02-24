import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/services/fruit_query_param.dart';

void main() {
  group('fruit query params', () {
    test('reads fruit from standard query parameter', () {
      final uri = Uri.parse('https://tootfruit.test/?fruit=banana');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('banana'));
    });

    test('reads fruit from fragment query parameter', () {
      final uri = Uri.parse('https://tootfruit.test/#/toot?fruit=kiwi');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('kiwi'));
    });

    test('builds uri with fruit while preserving fragment and path', () {
      final current = Uri.parse('https://tootfruit.test/#/toot');

      final next = buildFruitQueryUri(current, 'mango');

      expect(next, isNotNull);
      expect(
        next!.toString(),
        equals('https://tootfruit.test/?fruit=mango#/toot'),
      );
    });

    test('returns null when attempting to build uri for empty fruit', () {
      final current = Uri.parse('https://tootfruit.test/#/toot');

      final next = buildFruitQueryUri(current, '   ');

      expect(next, isNull);
    });
  });
}
