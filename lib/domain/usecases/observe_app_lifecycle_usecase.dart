import 'dart:ui';

import '../../data/controllers/lifecycle_aware_controller.dart';

class ObserveAppLifecycleUseCase {
  final LifecycleAwareController _lifecycleController;

  ObserveAppLifecycleUseCase({
    required LifecycleAwareController lifecycleController,
  }) : _lifecycleController = lifecycleController;

  Stream<AppLifecycleState> call() {
    return _lifecycleController.stateStream;
  }
}
