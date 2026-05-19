import 'package:dartz/dartz.dart';
import '../../core/failure/failure.dart';
import '../repositories/notification_repository.dart';

class UpdateLocationNotificationUseCase {
  final NotificationRepository _notificationRepository;

  UpdateLocationNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
    required String updatedText,
  }) {
    return _notificationRepository.updateTrackingNotification(
      latitude,
      longitude,
      updatedText,
    );
  }
}
