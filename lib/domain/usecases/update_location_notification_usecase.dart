import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/notification_repository.dart';

class UpdateLocationNotificationUseCase {
  final NotificationRepository _notificationRepository;

  UpdateLocationNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, void>> call(
    double latitude,
    double longitude,
    String updatedText,
  ) {
    return _notificationRepository.updateTrackingNotification(
      latitude,
      longitude,
      updatedText,
    );
  }
}
