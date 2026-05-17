import 'dart:async';

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

  static void listen(void Function(Map<String, dynamic> data) callback) {
    _service.on('locationUpdate').listen((event) {
      if (event != null) callback(event);
    });
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
  const throttleDuration = Duration(seconds: 2);

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
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

      service.invoke('locationUpdate', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update notification with throttling
      final now = DateTime.now();
      if (lastNotificationUpdate == null ||
          now.difference(lastNotificationUpdate!) >= throttleDuration) {
        await notificationService.showPersistentNotification(
          model.latitude,
          model.longitude,
          DateFormat('HH:mm:ss').format(model.timestamp),
        );

        lastNotificationUpdate = now;
      }
    } catch (_) {}
  });
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
