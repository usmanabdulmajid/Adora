import 'package:dartz/dartz.dart';
import '../../core/failure/failure.dart';
import '../repositories/location_repository.dart';

class StartTrackingUseCase {
  final LocationRepository _repository;

  StartTrackingUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.startBackgroundTracking();
  }
}
