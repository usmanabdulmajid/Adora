import 'dart:async';

import 'package:adora_assessment/core/constants/duration.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../datasources/location_local_datasource.dart';
import '../models/location_model.dart';
import 'notification_service.dart';

class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        initialNotificationTitle: 'Location Tracker',
        initialNotificationContent: 'Tracking location in background',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
    );
  }

  static Future<void> start() async {
    await _service.startService();
  }

  static Future<void> stop() async {
    _service.invoke('stopService');
  }

  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final localDataSource = LocationLocalDataSource();
  await localDataSource.initialize();

  final notificationService = LocationNotificationService();
  await notificationService.initialize();

  DateTime? lastNotificationUpdate;
  late Timer periodicTimer;
  late StreamSubscription<dynamic> stopServiceSubscription;

  stopServiceSubscription = service.on('stopService').listen((event) {
    service.stopSelf();
    periodicTimer.cancel();
    stopServiceSubscription.cancel();
  });

  periodicTimer = Timer.periodic(KDuration.backgroundDelay, (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final model = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      await localDataSource.insertLocation(model);

      // Update notification with throttling
      final now = DateTime.now();
      if (lastNotificationUpdate == null ||
          now.difference(lastNotificationUpdate!) >= KDuration.throttle) {
        await notificationService.showPersistentNotification(
          model.latitude,
          model.longitude,
          DateFormat('HH:mm:ss').format(model.timestamp),
        );

        lastNotificationUpdate = now;
      }
    } catch (e) {
      debugPrint('start background service failed: ${e.toString()}');
    }
  });
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
