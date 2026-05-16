// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Location Tracker';

  @override
  String get appBarTitle => 'Location Tracker';

  @override
  String get backgroundTrackingDialogTitle =>
      'Background Tracking Requires Always Allow';

  @override
  String get backgroundTrackingDialogContent =>
      'To track your location even when the app is closed or in the background, please enable \"Allow all the time\" location access in system settings.';

  @override
  String get cancel => 'Cancel';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get backgroundTracking => 'Background Tracking';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get loading => 'Loading...';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get timestamp => 'Timestamp';

  @override
  String unableToGetLocation(Object error) {
    return 'Unable to get location: $error';
  }

  @override
  String get trackingHistory => 'Tracking History (Last 10)';

  @override
  String get noLocationData => 'No location data recorded yet';

  @override
  String failedToLoadHistory(Object error) {
    return 'Failed to load history: $error';
  }

  @override
  String get locationPermissionGranted => 'Location Permission: Granted';

  @override
  String get locationPermissionDenied => 'Location Permission: Denied';
}
