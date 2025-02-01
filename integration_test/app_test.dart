import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets('Verify Restaurant List Screen and Navigation',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that we're on the restaurant list screen
      expect(find.byType(ListView), findsOneWidget);

      // Wait for the restaurant list to load
      await tester.pump(const Duration(seconds: 3));

      // Verify that restaurant cards are displayed
      expect(find.byType(Card), findsWidgets);

      // Tap on the first restaurant card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify that we've navigated to the detail screen
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
