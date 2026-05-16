import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class GetLocationHistoryUseCase {
  final LocationRepository repository;

  GetLocationHistoryUseCase(this.repository);

  Future<Either<Failure, List<LocationEntity>>> call() {
    return repository.getLocationHistory();
  }
}
