import 'package:dartz/dartz.dart';
import '../../core/failure/failure.dart';
import '../repositories/notification_repository.dart';

class ShowLocationNotificationUseCase {
  final NotificationRepository _notificationRepository;

  ShowLocationNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
    required String updatedText,
  }) {
    return _notificationRepository.showTrackingNotification(
      latitude,
      longitude,
      updatedText,
    );
  }
}
