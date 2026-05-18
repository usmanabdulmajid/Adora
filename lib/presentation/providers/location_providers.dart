import 'package:adora_assessment/presentation/providers/notification_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/location_datasource.dart';
import '../../data/datasources/location_local_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_location_history_usecase.dart';
import '../../domain/usecases/request_location_permission_usecase.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';

//Note: Dependecies are also injected in the provider file

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

final requestLocationPermissionUseCaseProvider =
    Provider<RequestLocationPermissionUseCase>((ref) {
      return RequestLocationPermissionUseCase(
        ref.watch(locationRepositoryProvider),
      );
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
  final locationRepo = ref.watch(locationRepositoryProvider);
  return locationRepo.hasPermission().then((either) {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (hasPermission) => hasPermission,
    );
  });
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
    final isRunning = either.fold((_) => false, (running) => running);

    if (isRunning) {
      _scheduleNotificationUpdates();
    }

    return isRunning;
  }

  Future<bool> _hasBackgroundPermission() async {
    final repository = ref.read(locationRepositoryProvider);
    final either = await repository.hasBackgroundPermission();
    return either.fold((_) => false, (has) => has);
  }

  void _scheduleNotificationUpdates() {
    final locationStream = ref.watch(currentLocationStreamProvider);
    locationStream.whenData((location) {
      _updateNotificationWithLocation(location);
    });
  }

  void _updateNotificationWithLocation(LocationEntity location) {
    final updateUseCase = ref.read(updateLocationNotificationUseCaseProvider);
    updateUseCase.call(
      location.latitude,
      location.longitude,
      DateFormat('HH:mm:ss').format(location.timestamp),
    );
  }

  Future<void> toggle() async {
    final current = state.value ?? false;

    if (!current) {
      final hasPerm = await _hasBackgroundPermission();
      if (!hasPerm) {
        ref.read(pendingPermissionDialogProvider.notifier).show();
        return;
      }

      // Request notification permission before starting tracking
      final requestPermUseCase = ref.read(
        requestNotificationPermissionUseCaseProvider,
      );
      final permissionResult = await requestPermUseCase.call();
      final hasNotificationPerm = permissionResult.fold(
        (_) => false,
        (granted) => granted,
      );

      if (!hasNotificationPerm) {
        state = const AsyncData(false);
        // Optionally show a dialog to inform user about notification permission
        return;
      }
    }

    state = const AsyncLoading();

    if (current) {
      // Stopping tracking - hide notification
      final hideUseCase = ref.read(hideLocationNotificationUseCaseProvider);
      await hideUseCase.call();

      final either = await ref.read(stopTrackingUseCaseProvider).call();
      either.fold(
        (_) => state = const AsyncData(false),
        (_) => state = const AsyncData(false),
      );
    } else {
      final showUseCase = ref.read(showLocationNotificationUseCaseProvider);

      await showUseCase.call(0, 0, 'Acquiring location...');

      final either = await ref.read(startTrackingUseCaseProvider).call();
      either.fold((_) => state = const AsyncData(false), (_) {
        state = const AsyncData(true);
        _scheduleNotificationUpdates();
      });
    }
  }
}

final trackingStateProvider =
    AsyncNotifierProvider<TrackingStateNotifier, bool>(
      TrackingStateNotifier.new,
    );
