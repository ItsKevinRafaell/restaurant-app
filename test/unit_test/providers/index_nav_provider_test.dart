import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/presentation/providers/navigation/index_nav_provider.dart';

void main() {
  late IndexNavProvider provider;

  setUp(() {
    provider = IndexNavProvider();
  });

  group('index navigation provider', () {
    test('should return 0 when provider is initialized', () {
      expect(provider.currentIndex, equals(0));
    });

    test('should update current index when updateIndex is called', () {
      // arrange
      const newIndex = 1;

      // act
      provider.updateIndex(newIndex);

      // assert
      expect(provider.currentIndex, equals(newIndex));
    });

    test('should maintain new index after multiple updates', () {
      // arrange
      const firstIndex = 1;
      const secondIndex = 2;

      // act
      provider.updateIndex(firstIndex);
      expect(provider.currentIndex, equals(firstIndex));

      provider.updateIndex(secondIndex);
      expect(provider.currentIndex, equals(secondIndex));
    });
  });
}
