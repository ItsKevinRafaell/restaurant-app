import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/presentation/providers/notification/local_notification_provider.dart';

class MockLocalNotificationService extends Mock implements LocalNotificationService {}

void main() {
  late MockLocalNotificationService mockService;
  late LocalNotificationProvider provider;

  setUp(() {
    mockService = MockLocalNotificationService();
    
    // Setup default mock responses
    when(() => mockService.init()).thenAnswer((_) async {});
    when(() => mockService.getNotificationPreference()).thenAnswer((_) async => false);
    when(() => mockService.isAndroidPermissionGranted()).thenAnswer((_) async => false);
    
    provider = LocalNotificationProvider(mockService);
  });

  group('local notification provider', () {
    test('should initialize with default values when provider is created', () async {
      // arrange
      when(() => mockService.getNotificationPreference()).thenAnswer((_) async => false);
      when(() => mockService.isAndroidPermissionGranted()).thenAnswer((_) async => false);

      // act - initialization happens in constructor
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for async initialization

      // assert
      expect(provider.isScheduled, isFalse);
      expect(provider.permission, isFalse);
      verify(() => mockService.init()).called(1);
      verify(() => mockService.getNotificationPreference()).called(1);
      verify(() => mockService.isAndroidPermissionGranted()).called(1);
    });

    test('should update scheduled status when enableNotification is called', () async {
      // arrange
      when(() => mockService.setNotificationPreference(true))
          .thenAnswer((_) async {});

      // act
      await provider.enableNotification(true);

      // assert
      verify(() => mockService.setNotificationPreference(true)).called(1);
      expect(provider.isScheduled, isTrue);
    });

    test('should update permission status when requestPermissions is called', () async {
      // arrange
      when(() => mockService.requestPermissions()).thenAnswer((_) async {});
      when(() => mockService.isAndroidPermissionGranted())
          .thenAnswer((_) async => true);

      // act
      await provider.requestPermissions();

      // assert
      verify(() => mockService.requestPermissions()).called(1);
      verify(() => mockService.isAndroidPermissionGranted()).called(2); // Once in init, once after request
      expect(provider.permission, isTrue);
    });

    test('should handle notification preference change failure', () async {
      // arrange
      when(() => mockService.setNotificationPreference(true))
          .thenThrow(Exception('Failed to set preference'));

      // act & assert
      expect(() => provider.enableNotification(true), throwsException);
      verify(() => mockService.setNotificationPreference(true)).called(1);
    });

    test('should handle permission request failure', () async {
      // arrange
      when(() => mockService.requestPermissions())
          .thenThrow(Exception('Failed to request permissions'));

      // act & assert
      expect(() => provider.requestPermissions(), throwsException);
      verify(() => mockService.requestPermissions()).called(1);
    });
  });
}
