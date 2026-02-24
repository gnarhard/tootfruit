import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
