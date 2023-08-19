import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tootfruit/main.dart' as app;
import 'package:tootfruit/widgets/screen_title.dart';

// Note: couldn't get these tests to work
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Can See:", () {
    testWidgets('toot screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tootScreen = find.byKey(const Key('tootScreen'));
      expect(tootScreen, findsOneWidget);

      final tootName = find.byType(AppScreenTitle);
      expect(tootName, findsOneWidget);

      final fruit = find.byType(SvgPicture);
      expect(fruit, findsOneWidget);

      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('toot fairy screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final button = find.byType(OutlinedButton);
      tester.tap(button);
      await tester.pumpAndSettle();

      final tootName = find.byType(AppScreenTitle);
      expect(tootName, findsOneWidget);

      // final fruit = find.byType(SvgPicture);
      // expect(fruit, findsOneWidget);

      // final button = find.byType(OutlinedButton);
      // expect(button, findsOneWidget);
    });
  });
}
