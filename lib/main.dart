import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/location_datasource.dart';
import 'data/datasources/location_local_datasource.dart';
import 'data/services/background_service.dart';
import 'data/services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localDataSource = LocationLocalDataSource();
  await localDataSource.initialize();
  await BackgroundService.initialize();

  final notificationService = LocationNotificationService();
  await notificationService.initialize();

  await LocationDataSource().requestPermission();

  final wasTracking = await localDataSource.getTrackingState();
  await localDataSource.clearOldLocations(const Duration(hours: 24));

  runApp(const ProviderScope(child: LocationTrackerApp()));

  if (wasTracking) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await BackgroundService.start();
    });
  }
}

class LocationTrackerApp extends StatelessWidget {
  const LocationTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}
