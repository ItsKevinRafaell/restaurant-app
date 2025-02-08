import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/presentation/providers/notification/local_notification_provider.dart';

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  late MockLocalNotificationService mockService;
  late LocalNotificationProvider provider;

  setUp(() {
    mockService = MockLocalNotificationService();

    when(
      () => mockService.init(),
    ).thenAnswer((_) async {});
    when(
      () => mockService.getNotificationPreference(),
    ).thenAnswer((_) async => false);
    when(
      () => mockService.isAndroidPermissionGranted(),
    ).thenAnswer((_) async => false);

    provider = LocalNotificationProvider(mockService);
  });

  group('local notification provider', () {
    test('should initialize with default values when provider is created',
        () async {
      when(
        () => mockService.getNotificationPreference(),
      ).thenAnswer((_) async => false);
      when(
        () => mockService.isAndroidPermissionGranted(),
      ).thenAnswer((_) async => false);

      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      expect(provider.isScheduled, isFalse);
      expect(provider.permission, isFalse);
      verify(
        () => mockService.init(),
      ).called(1);
      verify(
        () => mockService.getNotificationPreference(),
      ).called(1);
      verify(
        () => mockService.isAndroidPermissionGranted(),
      ).called(1);
    });

    test('should update scheduled status when enableNotification is called',
        () async {
      when(
        () => mockService.setNotificationPreference(true),
      ).thenAnswer((_) async {});

      await provider.enableNotification(true);

      verify(
        () => mockService.setNotificationPreference(true),
      ).called(1);
      expect(provider.isScheduled, isTrue);
    });

    test('should update permission status when requestPermissions is called',
        () async {
      when(
        () => mockService.requestPermissions(),
      ).thenAnswer((_) async {
        return null;
      });
      when(
        () => mockService.isAndroidPermissionGranted(),
      ).thenAnswer((_) async => true);

      await provider.requestPermissions();

      verify(
        () => mockService.requestPermissions(),
      ).called(1);
      verify(
        () => mockService.isAndroidPermissionGranted(),
      ).called(2);
      expect(provider.permission, isTrue);
    });

    test('should handle notification preference change failure', () async {
      when(
        () => mockService.setNotificationPreference(true),
      ).thenThrow(
        Exception('Failed to set preference'),
      );

      expect(() => provider.enableNotification(true), throwsException);
      verify(
        () => mockService.setNotificationPreference(true),
      ).called(1);
    });

    test('should handle permission request failure', () async {
      when(
        () => mockService.requestPermissions(),
      ).thenThrow(
        Exception('Failed to request permissions'),
      );

      expect(() => provider.requestPermissions(), throwsException);
      verify(
        () => mockService.requestPermissions(),
      ).called(1);
    });
  });
}
