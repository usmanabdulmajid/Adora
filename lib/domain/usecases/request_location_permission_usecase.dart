import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../repositories/location_repository.dart';

class RequestLocationPermissionUseCase {
  final LocationRepository _repository;

  RequestLocationPermissionUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.requestPermission();
  }
}
