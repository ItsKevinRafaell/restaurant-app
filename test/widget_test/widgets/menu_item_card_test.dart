import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/presentation/widgets/menu_item_card.dart';

void main() {
  late Widget testWidget;

  setUp(() {
    testWidget = const MaterialApp(
      home: Scaffold(
        body: MenuItemCard(
          itemName: 'Test Menu Item',
          imageUrl: 'https://example.com/test-image.jpg',
        ),
      ),
    );
  });

  group('MenuItemCard Widget Test', () {
    testWidgets('should display menu item name correctly', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Test Menu Item'), findsOneWidget);
    });

    testWidgets('should handle long text with ellipsis', (tester) async {
      final longTextWidget = MaterialApp(
        home: Scaffold(
          body: MenuItemCard(
            itemName: 'Very Long Menu Item Name That Should Be Truncated ' * 3,
            imageUrl: 'https://example.com/test-image.jpg',
          ),
        ),
      );

      await tester.pumpWidget(longTextWidget);

      final textWidget = tester.widget<Text>(
        find.byType(Text),
      );
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should display network image correctly', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url.contains('test-image.jpg'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should have correct card styling', (tester) async {
      await tester.pumpWidget(testWidget);

      final card = tester.widget<Card>(
        find.byType(Card),
      );
      expect(card.elevation, 5);
      expect(
        card.margin,
        const EdgeInsets.all(8),
      );
      expect(
        card.shape,
        isA<RoundedRectangleBorder>().having(
          (shape) => shape.borderRadius,
          'borderRadius',
          BorderRadius.circular(12),
        ),
      );
    });

    testWidgets('should have correct image styling', (tester) async {
      await tester.pumpWidget(testWidget);

      final image = tester.widget<Image>(
        find.byType(Image),
      );
      expect(image.fit, BoxFit.cover);
      expect(image.width, double.infinity);
      expect(image.height, 100);
    });
  });
}
