import 'package:dartz/dartz.dart';
import '../../core/failure/failure.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocationNotificationService _notificationService;

  NotificationRepositoryImpl(this._notificationService);

  @override
  Future<Either<Failure, bool>> requestNotificationPermission() async {
    try {
      final granted = await _notificationService
          .requestNotificationPermission();
      return Right(granted);
    } catch (e) {
      return Left(Failure('Failed to request notification permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasNotificationPermission() async {
    try {
      final hasPermission = await _notificationService
          .hasNotificationPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(Failure('Failed to check notification permission: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showTrackingNotification(
    double latitude,
    double longitude,
    String updatedText,
  ) async {
    try {
      await _notificationService.showPersistentNotification(
        latitude,
        longitude,
        updatedText,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to show notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTrackingNotification(
    double latitude,
    double longitude,
    String updatedText,
  ) async {
    try {
      await _notificationService.showPersistentNotification(
        latitude,
        longitude,
        updatedText,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to update notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> hideTrackingNotification() async {
    try {
      await _notificationService.cancelNotification();
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to hide notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showAcquiringLocationNotification(
    String acquiringText,
  ) async {
    try {
      await _notificationService.showAcquiringLocationNotification(
        acquiringText,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to show acquiring notification: $e'));
    }
  }
}
