import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<Either<Failure, LocationEntity>> call() {
    return _repository.getCurrentLocation();
  }
}
