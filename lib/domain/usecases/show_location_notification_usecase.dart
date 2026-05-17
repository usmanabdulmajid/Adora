import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/notification_repository.dart';

class ShowLocationNotificationUseCase {
  final NotificationRepository _notificationRepository;

  ShowLocationNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, void>> call(
    double latitude,
    double longitude,
    String updatedText,
  ) {
    return _notificationRepository.showTrackingNotification(
      latitude,
      longitude,
      updatedText,
    );
  }
}
