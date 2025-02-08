import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/presentation/providers/navigation/payload_provider.dart';

void main() {
  late PayloadProvider provider;

  setUp(() {
    provider = PayloadProvider();
  });

  group('payload provider', () {
    test('should return empty string when provider is initialized', () {
      expect(provider.payload, isEmpty);
    });

    test('should update payload when updatePayload is called', () {
      const newPayload = 'test_payload';

      provider.updatePayload(newPayload);

      expect(
        provider.payload,
        equals(newPayload),
      );
    });

    test('should maintain new payload after multiple updates', () {
      const firstPayload = 'first_payload';
      const secondPayload = 'second_payload';

      provider.updatePayload(firstPayload);
      expect(
        provider.payload,
        equals(firstPayload),
      );

      provider.updatePayload(secondPayload);
      expect(
        provider.payload,
        equals(secondPayload),
      );
    });

    test('should handle empty payload update', () {
      const initialPayload = 'initial_payload';
      provider.updatePayload(initialPayload);

      provider.updatePayload('');

      expect(provider.payload, isEmpty);
    });
  });
}
