import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/services/fruit_query_param.dart';

void main() {
  group('fruit URL routing', () {
    test('reads fruit from regular path segment', () {
      final uri = Uri.parse('https://tootfruit.test/banana');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('banana'));
    });

    test('reads fruit from hash fragment path segment', () {
      final uri = Uri.parse('https://tootfruit.test/#/kiwi');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('kiwi'));
    });

    test(
      'reads fruit from legacy query parameter for backward compatibility',
      () {
        final uri = Uri.parse('https://tootfruit.test/?fruit=banana');

        final fruit = readFruitQueryParamFromUri(uri);

        expect(fruit, equals('banana'));
      },
    );

    test('prefers path segment fruit over legacy query parameter', () {
      final uri = Uri.parse('https://tootfruit.test/?fruit=banana#/kiwi');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('kiwi'));
    });

    test('prefers path segment fruit over hash fragment path fruit', () {
      final uri = Uri.parse('https://tootfruit.test/toot/banana#/toot/kiwi');

      final fruit = readFruitQueryParamFromUri(uri);

      expect(fruit, equals('banana'));
    });

    test('builds path URI from hash-route input', () {
      final current = Uri.parse('https://tootfruit.test/#/toot');

      final next = buildFruitQueryUri(current, 'mango');

      expect(next, isNotNull);
      expect(next!.toString(), equals('https://tootfruit.test/toot/mango'));
    });

    test('builds path URI and removes stale root fruit query parameter', () {
      final current = Uri.parse('https://tootfruit.test/?fruit=kiwi#/toot');

      final next = buildFruitQueryUri(current, 'mango');

      expect(next, isNotNull);
      expect(next!.toString(), equals('https://tootfruit.test/toot/mango'));
    });

    test('builds non-hash URI using canonical toot path segment', () {
      final current = Uri.parse('https://tootfruit.test/peach');

      final next = buildFruitQueryUri(current, 'mango');

      expect(next, isNotNull);
      expect(next!.toString(), equals('https://tootfruit.test/toot/mango'));
    });

    test(
      'replaces canonical toot fruit path instead of appending segments',
      () {
        final current = Uri.parse('https://tootfruit.test/toot/peach');

        final next = buildFruitQueryUri(current, 'banana');

        expect(next, isNotNull);
        expect(next!.toString(), equals('https://tootfruit.test/toot/banana'));
      },
    );

    test(
      'drops duplicate hash fragment when path route is already present',
      () {
        final current = Uri.parse(
          'https://tootfruit.test/toot/peach#/toot/peach',
        );

        final next = buildFruitQueryUri(current, 'banana');

        expect(next, isNotNull);
        expect(next!.toString(), equals('https://tootfruit.test/toot/banana'));
      },
    );

    test('returns null when attempting to build uri for empty fruit', () {
      final current = Uri.parse('https://tootfruit.test/#/toot');

      final next = buildFruitQueryUri(current, '   ');

      expect(next, isNull);
    });
  });
}
