import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/widgets/fruit_asset.dart';

void main() {
  testWidgets('renders all fruits at the same container size', (
    WidgetTester tester,
  ) async {
    const fruitNames = ['blueberry', 'appleGreen', 'strawberry'];
    const containerSize = 240.0;

    for (final fruit in fruitNames) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: containerSize,
                height: containerSize,
                child: FruitAsset(fruit: fruit),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsOneWidget);
      expect(tester.getSize(svgFinder), equals(const Size(240, 240)));
    }
  });
}
