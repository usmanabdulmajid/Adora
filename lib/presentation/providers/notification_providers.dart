import 'package:adora_assessment/data/repositories/notification_repository_impl.dart';
import 'package:adora_assessment/data/services/notification_service.dart';
import 'package:adora_assessment/domain/repositories/notification_repository.dart';
import 'package:adora_assessment/domain/usecases/hide_location_notification_usecase.dart';
import 'package:adora_assessment/domain/usecases/request_notification_permission_usecase.dart';
import 'package:adora_assessment/domain/usecases/show_location_notification_usecase.dart';
import 'package:adora_assessment/domain/usecases/update_location_notification_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<LocationNotificationService>((
  ref,
) {
  return LocationNotificationService();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationRepositoryImpl(notificationService);
});

final showLocationNotificationUseCaseProvider =
    Provider<ShowLocationNotificationUseCase>((ref) {
      return ShowLocationNotificationUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final updateLocationNotificationUseCaseProvider =
    Provider<UpdateLocationNotificationUseCase>((ref) {
      return UpdateLocationNotificationUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final hideLocationNotificationUseCaseProvider =
    Provider<HideLocationNotificationUseCase>((ref) {
      return HideLocationNotificationUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final requestNotificationPermissionUseCaseProvider =
    Provider<RequestNotificationPermissionUseCase>((ref) {
      return RequestNotificationPermissionUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });
