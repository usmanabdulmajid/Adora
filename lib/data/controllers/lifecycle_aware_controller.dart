import 'dart:async';

import 'package:flutter/widgets.dart';

class LifecycleAwareController {
  late final AppLifecycleListener _listener;

  LifecycleAwareController() {
    _listener = AppLifecycleListener(
      onResume: () => _stateStreamController.add(AppLifecycleState.resumed),
      onPause: () => _stateStreamController.add(AppLifecycleState.paused),
    );
  }

  final StreamController<AppLifecycleState> _stateStreamController =
      StreamController<AppLifecycleState>.broadcast();

  Stream<AppLifecycleState> get stateStream => _stateStreamController.stream;

  void dispose() {
    _listener.dispose();
    _stateStreamController.close();
  }
}
