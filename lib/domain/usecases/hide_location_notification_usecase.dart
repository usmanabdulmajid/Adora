import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/notification_repository.dart';

class HideLocationNotificationUseCase {
  final NotificationRepository _notificationRepository;

  HideLocationNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, void>> call() {
    return _notificationRepository.hideTrackingNotification();
  }
}
