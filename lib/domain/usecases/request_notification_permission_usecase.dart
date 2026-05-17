import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/notification_repository.dart';

class RequestNotificationPermissionUseCase {
  final NotificationRepository _notificationRepository;

  RequestNotificationPermissionUseCase(this._notificationRepository);

  Future<Either<Failure, bool>> call() {
    return _notificationRepository.requestNotificationPermission();
  }
}
