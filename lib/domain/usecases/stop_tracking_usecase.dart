import 'package:dartz/dartz.dart';
import '../../core/failure/failure.dart';
import '../repositories/location_repository.dart';

class StopTrackingUseCase {
  final LocationRepository _repository;

  StopTrackingUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.stopBackgroundTracking();
  }
}
