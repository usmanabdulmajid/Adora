import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../../core/failure/failure.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<Either<Failure, LocationEntity>> call() {
    return _repository.getCurrentLocation();
  }
}
