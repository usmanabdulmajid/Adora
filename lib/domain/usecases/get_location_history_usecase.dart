import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../../core/failure/failure.dart';
import '../repositories/location_repository.dart';

class GetLocationHistoryUseCase {
  final LocationRepository _repository;

  GetLocationHistoryUseCase(this._repository);

  Future<Either<Failure, List<LocationEntity>>> call() {
    return _repository.getLocationHistory();
  }
}
