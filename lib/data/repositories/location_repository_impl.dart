import 'package:dartz/dartz.dart';

import '../../core/failure/failure.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';
import '../datasources/location_local_datasource.dart';
import '../services/background_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource _dataSource;
  final LocationLocalDataSource _localDataSource;

  LocationRepositoryImpl(this._dataSource, this._localDataSource);

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final hasPermission = await _dataSource.requestPermission();
      if (!hasPermission) {
        return const Left(Failure('Location permission not granted'));
      }
      final model = await _dataSource.getCurrentLocation();
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> startBackgroundTracking() async {
    try {
      final hasPermission = await _dataSource.requestBackgroundPermission();
      if (!hasPermission) {
        return const Left(
          Failure(
            'Background location permission not granted. Open system settings and allow "Always" location access.',
          ),
        );
      }
      await BackgroundService.start();
      await _localDataSource.saveTrackingState(true);
      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopBackgroundTracking() async {
    try {
      await BackgroundService.stop();
      await _localDataSource.saveTrackingState(false);
      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocationHistory() async {
    try {
      final models = await _localDataSource.getLocations(limit: 50);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBackgroundTrackingActive() async {
    try {
      final running = await BackgroundService.isRunning();
      return Right(running);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasBackgroundPermission() async {
    try {
      final has = await _dataSource.hasBackgroundPermission();
      return Right(has);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, LocationEntity>> getLocationStream() {
    return _dataSource
        .getLocationStream()
        .map((model) => Right<Failure, LocationEntity>(model.toEntity()))
        .handleError(
          (e) => Left<Failure, LocationEntity>(Failure(e.toString())),
        );
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final has = await _dataSource.requestPermission();
      return Right(has);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission() async {
    try {
      final has = await _dataSource.hasPermission();
      return Right(has);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
