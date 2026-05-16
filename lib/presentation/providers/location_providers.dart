import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/location_datasource.dart';
import '../../data/datasources/location_local_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_location_history_usecase.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  return LocationDataSource();
});

final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((
  ref,
) {
  return LocationLocalDataSource();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  final localDataSource = ref.watch(locationLocalDataSourceProvider);
  return LocationRepositoryImpl(dataSource, localDataSource);
});

final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocationUseCase>((
  ref,
) {
  return GetCurrentLocationUseCase(ref.watch(locationRepositoryProvider));
});

final startTrackingUseCaseProvider = Provider<StartTrackingUseCase>((ref) {
  return StartTrackingUseCase(ref.watch(locationRepositoryProvider));
});

final stopTrackingUseCaseProvider = Provider<StopTrackingUseCase>((ref) {
  return StopTrackingUseCase(ref.watch(locationRepositoryProvider));
});

final getLocationHistoryUseCaseProvider = Provider<GetLocationHistoryUseCase>((
  ref,
) {
  return GetLocationHistoryUseCase(ref.watch(locationRepositoryProvider));
});

final currentLocationStreamProvider = StreamProvider<LocationEntity>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.getLocationStream().map((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (location) => location,
    );
  });
});

final locationHistoryProvider = FutureProvider<List<LocationEntity>>((ref) {
  final useCase = ref.watch(getLocationHistoryUseCaseProvider);
  return useCase.call().then((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (locations) => locations,
    );
  });
});

final permissionStatusProvider = FutureProvider<bool>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return dataSource.hasPermission();
});

class PendingPermissionDialogNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void dismiss() => state = false;
}

final pendingPermissionDialogProvider =
    NotifierProvider<PendingPermissionDialogNotifier, bool>(
      PendingPermissionDialogNotifier.new,
    );

class TrackingStateNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repository = ref.read(locationRepositoryProvider);
    final either = await repository.isBackgroundTrackingActive();
    return either.fold((_) => false, (running) => running);
  }

  Future<bool> _hasBackgroundPermission() async {
    final repository = ref.read(locationRepositoryProvider);
    final either = await repository.hasBackgroundPermission();
    return either.fold((_) => false, (has) => has);
  }

  Future<void> toggle() async {
    final current = state.value ?? false;

    if (!current) {
      final hasPerm = await _hasBackgroundPermission();
      if (!hasPerm) {
        ref.read(pendingPermissionDialogProvider.notifier).show();
        return;
      }
    }

    state = const AsyncLoading();

    if (current) {
      final either = await ref.read(stopTrackingUseCaseProvider).call();
      either.fold(
        (_) => state = const AsyncData(false),
        (_) => state = const AsyncData(false),
      );
    } else {
      final either = await ref.read(startTrackingUseCaseProvider).call();
      either.fold(
        (_) => state = const AsyncData(false),
        (_) => state = const AsyncData(true),
      );
    }
  }
}

final trackingStateProvider =
    AsyncNotifierProvider<TrackingStateNotifier, bool>(
      TrackingStateNotifier.new,
    );
