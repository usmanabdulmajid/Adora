import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class StartTrackingUseCase {
  final LocationRepository _repository;

  StartTrackingUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.startBackgroundTracking();
  }
}
