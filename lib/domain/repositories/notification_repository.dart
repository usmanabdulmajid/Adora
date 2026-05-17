import 'package:dartz/dartz.dart';
import '../entities/failure.dart';

abstract class NotificationRepository {
  Future<Either<Failure, bool>> requestNotificationPermission();

  Future<Either<Failure, bool>> hasNotificationPermission();

  Future<Either<Failure, void>> showTrackingNotification(
    double latitude,
    double longitude,
    String updatedText,
  );

  Future<Either<Failure, void>> updateTrackingNotification(
    double latitude,
    double longitude,
    String updatedText,
  );

  Future<Either<Failure, void>> showAcquiringLocationNotification(
    String acquiringText,
  );

  Future<Either<Failure, void>> hideTrackingNotification();
}
