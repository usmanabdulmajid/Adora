import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocationNotificationService {
  static const int notificationId = 999;
  static const String channelId = 'location_tracking_channel';
  static const String channelName = 'Location Tracking';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription:
            'Shows current location information while tracking is active',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        playSound: false,
      );

  static const DarwinNotificationDetails _iOSDetails =
      DarwinNotificationDetails();

  static const NotificationDetails _platformDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iOSDetails,
  );

  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  LocationNotificationService() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    await _createNotificationChannel();
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final android = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        try {
          final granted = await android.requestNotificationsPermission();
          return granted ?? false;
        } catch (e) {
          return false;
        }
      }
    }
    // iOS notifications are generally enabled by default when app starts
    // No additional permission request needed
    return true;
  }

  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final android = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        try {
          final permitted = await android.areNotificationsEnabled();
          return permitted ?? false;
        } catch (e) {
          return false;
        }
      }
    }
    // iOS notifications assumed to be enabled
    return true;
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description:
          'Shows current location information while tracking is active',
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showPersistentNotification(
    double latitude,
    double longitude,
    String updatedText,
  ) async {
    final position =
        '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    final body = '$position\nTime: $updatedText';

    await _notificationsPlugin.show(
      notificationId,
      '📍 Location Tracker',
      body,
      _platformDetails,
    );
  }

  Future<void> showAcquiringLocationNotification(String acquiringText) async {
    await _notificationsPlugin.show(
      notificationId,
      '📍 Location Tracker',
      acquiringText,
      _platformDetails,
    );
  }

  Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(notificationId);
  }
}
