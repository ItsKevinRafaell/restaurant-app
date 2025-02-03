import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/main.dart' as app;
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    setUp(() {
      debugPrint('Setting up test...');
    });

    testWidgets('Verify Restaurant List Loading and UI Elements',
        (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();

      bool foundRestaurantText = false;
      int attempts = 0;
      while (!foundRestaurantText && attempts < 10) {
        await tester.pump(
          const Duration(seconds: 1),
        );
        foundRestaurantText = find.text('Restaurant').evaluate().isNotEmpty;
        attempts++;
      }

      expect(find.text('Restaurant App'), findsOneWidget);

      expect(find.text('Restaurant'), findsOneWidget);

      expect(
        find.text('Berikut adalah daftar restoran yang tersedia'),
        findsOneWidget,
      );

      bool foundCards = false;
      attempts = 0;
      while (!foundCards && attempts < 10) {
        await tester.pump(
          const Duration(seconds: 1),
        );
        foundCards = find.byType(Card).evaluate().isNotEmpty;
        attempts++;
      }

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Test Restaurant List Scrolling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      bool foundCards = false;
      int attempts = 0;
      while (!foundCards && attempts < 10) {
        await tester.pump(
          const Duration(seconds: 1),
        );
        foundCards = find.byType(Card).evaluate().isNotEmpty;
        attempts++;
      }

      expect(find.byType(Card), findsWidgets);

      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      await tester.fling(
        listViewFinder,
        const Offset(0.0, -200.0),
        3000,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Test Restaurant Favorite Functionality',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      bool foundCards = false;
      int attempts = 0;
      while (!foundCards && attempts < 10) {
        await tester.pump(
          const Duration(seconds: 1),
        );
        foundCards = find.byType(Card).evaluate().isNotEmpty;
        attempts++;
      }

      final firstCard = find.byType(Card).first;
      expect(firstCard, findsOneWidget);

      expect(
        () => Provider.of<LocalDatabaseProvider>(
          tester.element(firstCard),
          listen: false,
        ),
        returnsNormally,
      );
    });

    testWidgets('Test Restaurant Detail Navigation and Content',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      bool foundCards = false;
      int attempts = 0;
      while (!foundCards && attempts < 10) {
        await tester.pump(
          const Duration(seconds: 1),
        );
        foundCards = find.byType(Card).evaluate().isNotEmpty;
        attempts++;
      }

      final firstCard = find.byType(Card).first;
      expect(firstCard, findsOneWidget);

      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Restaurant App'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });
  });
}
