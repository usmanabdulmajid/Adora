import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class StopTrackingUseCase {
  final LocationRepository repository;

  StopTrackingUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.stopBackgroundTracking();
  }
}
