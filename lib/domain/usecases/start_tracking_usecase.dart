import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class StartTrackingUseCase {
  final LocationRepository repository;

  StartTrackingUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.startBackgroundTracking();
  }
}
