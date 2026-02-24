import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/services/image_precache_service.dart';

void main() {
  group('ImagePrecacheService', () {
    testWidgets(
      'precacheLaunchImages preloads toot fairy rasters and all fruit svgs',
      (WidgetTester tester) async {
        final rasterCalls = <String>[];
        final svgCalls = <String>[];

        final service = ImagePrecacheService(
          fruitAssetResolver: () async => [
            'assets/images/fruit/appleGreen.svg',
            'assets/images/fruit/banana.svg',
            'assets/images/fruit/strawberry.svg',
          ],
          rasterPrecache: (context, assetPath) async {
            rasterCalls.add(assetPath);
          },
          svgPrecache: (assetPath) async {
            svgCalls.add(assetPath);
          },
        );

        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (buildContext) {
                  context = buildContext;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        await service.precacheLaunchImages(context);

        expect(
          rasterCalls.toSet(),
          equals(ImagePrecacheService.tootFairyRasterAssets.toSet()),
        );
        expect(
          svgCalls,
          equals([
            'assets/images/fruit/appleGreen.svg',
            'assets/images/fruit/banana.svg',
            'assets/images/fruit/strawberry.svg',
          ]),
        );
      },
    );
  });
}
