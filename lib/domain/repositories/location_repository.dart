import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../entities/failure.dart';

abstract class LocationRepository {
  Future<Either<Failure, bool>> requestPermission();
  Future<Either<Failure, bool>> hasPermission();
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Future<Either<Failure, Unit>> startBackgroundTracking();
  Future<Either<Failure, Unit>> stopBackgroundTracking();
  Future<Either<Failure, List<LocationEntity>>> getLocationHistory();
  Future<Either<Failure, bool>> isBackgroundTrackingActive();
  Future<Either<Failure, bool>> hasBackgroundPermission();
  Stream<Either<Failure, LocationEntity>> getLocationStream();
}
