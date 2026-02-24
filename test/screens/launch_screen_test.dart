import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/screens/launch_screen.dart';
import 'package:tootfruit/services/image_precache_service.dart';
import 'package:tootfruit/services/init_service.dart';

void main() {
  group('LaunchScreen', () {
    tearDown(() async {
      await GetIt.I.reset();
    });

    testWidgets('pre-caches images before init service runs', (
      WidgetTester tester,
    ) async {
      final steps = <String>[];
      final fakeInit = _FakeInitService(onInit: () => steps.add('init'));
      final fakePrecache = _FakeImagePrecacheService(steps: steps);

      GetIt.I.registerSingleton<InitService>(fakeInit);
      GetIt.I.registerSingleton<ImagePrecacheService>(fakePrecache);

      await tester.pumpWidget(const MaterialApp(home: LaunchScreen()));

      await tester.pump(const Duration(milliseconds: 50));

      expect(steps, equals(<String>['precache-start', 'precache-end', 'init']));
      expect(fakeInit.initCalls, equals(1));
      expect(fakePrecache.precacheCalls, equals(1));
    });
  });

  group('resolveLaunchBackgroundColor', () {
    test('defaults to peach when query parameter is absent', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/#/toot'),
      );

      expect(color, equals(toots.first.color));
    });

    test('uses fruit color when fruit query parameter is valid', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/?fruit=banana'),
      );

      expect(color, equals(const Color(0xfffff263)));
    });

    test('uses fruit color from hash-based query parameter', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/#/toot?fruit=kiwi'),
      );

      expect(color, equals(const Color(0xffB9CA50)));
    });

    test('falls back to peach when fruit query parameter is unknown', () {
      final color = resolveLaunchBackgroundColor(
        Uri.parse('https://tootfruit.test/?fruit=dragonfruit'),
      );

      expect(color, equals(toots.first.color));
    });
  });
}

class _FakeInitService extends InitService {
  final VoidCallback onInit;
  int initCalls = 0;

  _FakeInitService({required this.onInit});

  @override
  Future<void> init() async {
    initCalls++;
    onInit();
  }
}

class _FakeImagePrecacheService extends ImagePrecacheService {
  final List<String> steps;
  int precacheCalls = 0;

  _FakeImagePrecacheService({required this.steps});

  @override
  Future<void> precacheLaunchImages(BuildContext context) async {
    precacheCalls++;
    steps.add('precache-start');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    steps.add('precache-end');
  }
}
