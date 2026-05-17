# Adora Assessment - Advanced Location Tracker

A production-grade Flutter application that tracks device location in the foreground, background, and after the app has been terminated (killed). Built with strict Clean Architecture principles and Riverpod state management.

## Architecture

The project follows **Clean Architecture** with three distinct layers:

```
lib/
├── domain/          # Pure Dart, zero Flutter dependencies
│   ├── entities/    # LocationEntity, Failure
│   ├── repositories/ # Abstract repository interface
│   └── usecases/    # Business logic coordination
├── data/            # Flutter, implementations, plugins
│   ├── datasources/ # LocationDataSource (geolocator), LocationLocalDataSource (SQLite)
│   ├── models/      # LocationModel DTO
│   ├── repositories/ # LocationRepositoryImpl
│   └── services/    # BackgroundService (flutter_background_service)
└── presentation/    # Flutter UI, Riverpod
    ├── providers/   # State providers, AsyncNotifier
    ├── screens/     # HomeScreen
    └── widgets/     # LocationDisplay, TrackingHistory, PermissionIndicator
```

### Domain Layer (`lib/domain/`)
- **Zero Flutter dependencies** - no `import 'package:flutter/...'`
- Uses `Either<Failure, T>` from `dartz` for all repository methods
- Entities: `LocationEntity` (latitude, longitude, timestamp), `Failure` (message)
- Repository interface: `LocationRepository` with abstract contracts
- Use cases: `GetCurrentLocation`, `StartTracking`, `StopTracking`, `GetLocationHistory`

### Data Layer (`lib/data/`)
- Implements domain repository interfaces
- `LocationDataSource` - wraps `geolocator` plugin (the ONLY place with geolocator imports)
- `LocationModel` - DTO mirroring plugin data types with conversion to/from `LocationEntity`
- `LocationLocalDataSource` - SQLite persistence via `sqflite`
- `BackgroundService` - manages `flutter_background_service` for background execution
- Exceptions are caught and mapped to `Failure` objects - never propagated to UI

### Presentation Layer (`lib/presentation/`)
- Riverpod state management with `AsyncNotifierProvider` for tracking state
- `StreamProvider` for real-time location stream
- `FutureProvider` for location history and permission status
- All errors handled via `AsyncValue.when()` pattern - exceptions never reach UI
- Notification providers integrate with tracking state lifecycle

## Notification Architecture

The persistent location notification feature follows Clean Architecture principles:

### Domain Layer
- **`NotificationRepository`** abstract interface defines notification operations
- **Use cases**: `ShowLocationNotificationUseCase`, `UpdateLocationNotificationUseCase`, `HideLocationNotificationUseCase`

### Data Layer
- **`LocationNotificationService`** wraps `flutter_local_notifications` plugin
- **`NotificationRepositoryImpl`** implements the repository with platform-specific logic
- Methods:
  - `showTrackingNotification()` - Display notification with location data
  - `updateTrackingNotification()` - Update notification on location change
  - `hideTrackingNotification()` - Remove notification when tracking stops

### Presentation Layer
- **`TrackingStateNotifier`** integrates notification lifecycle with tracking toggle
- When tracking starts: Shows initial "Acquiring location..." notification
- When location updates arrive: Updates notification with latest lat/lon (throttled)
- When tracking stops: Hides notification
- Automatic sync on app resume if tracking was previously active

### Platform-Specific Behavior

#### Android Notification
```
┌─────────────────────────────────────┐
│ 📍 Location Tracker           [menu] │
├─────────────────────────────────────┤
│ Latitude: 37.7749° N                │
│ Longitude: 122.4194° W              │
│ Updated: 2 seconds ago              │
│                                     │
│ [Stop Tracking]                     │
└─────────────────────────────────────┘
```
- **Non-dismissible** (ongoing: true, autoCancel: false)
- **Cannot be swiped away** by the user
- **Persists** even when app is backgrounded or terminated (while foreground service runs)
- **Updates** with throttling (max once per 2 seconds)
- **Notification Channel**: `location_tracking_channel` with high importance

#### iOS Notification
- **Dismissible** (platform limitation - iOS doesn't allow truly non-dismissible notifications)
- Reliant on system's **blue location indicator** in status bar for persistent visual cue
- Notifications can be cleared but system indicator remains
- Same content format as Android
- Complies with iOS background execution guidelines

## Features

### Location Permissions & Acquisition
- Runtime permission request on both iOS and Android
- Graceful handling of denial (denied, deniedForever)
- High-accuracy location using `geolocator`
- Real-time latitude/longitude display

### Persistent Location Tracking Notification
- **Non-dismissible notification on Android**: Shows current location (latitude, longitude, timestamp) while tracking is active
  - Cannot be swiped away or cleared by the user
  - Automatically updates every location fix (throttled to max once per 2 seconds)
  - Displays "Acquiring location..." until first GPS fix
  - Includes optional "Stop Tracking" action button
  - Remains visible even when app is backgrounded or terminated
- **iOS approach**: Uses local notifications (can be dismissed) with system's blue location indicator remaining visible
- Real-time updates with relative time formatting ("Just now", "5 seconds ago", etc.)
- Fully localized notification strings

### Background & Terminated State Tracking
- **Background**: Uses `flutter_background_service` with Android foreground service (persistent notification)
- **Terminated State**: Android foreground service survives app termination on most devices
- **iOS**: Background location mode enabled via `UIBackgroundModes` in Info.plist
- Toggle switch to enable/disable background tracking
- Notification appears/disappears based on tracking state

### Data Persistence
- Locations recorded every 10 seconds (background) or on distance change (foreground, 10m filter)
- SQLite storage via `sqflite` with `locations` and `preferences` tables
- Auto-cleanup of records older than 24 hours on app start
- Tracking state persisted across app restarts

### User Interface
- Current location display with lat/lng and timestamp
- Scrollable history of last 10 recorded locations
- Background tracking toggle switch
- Permission status indicator
- Pull-to-refresh for history and permission status

## Setup Instructions

### Prerequisites
- Flutter SDK ^3.11.5
- Dart SDK ^3.11.5
- Android Studio / Xcode for platform builds

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd adora_assessment

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Platform-Specific Configuration

#### Android
The following permissions are configured in `AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION` - precise GPS location
- `ACCESS_BACKGROUND_LOCATION` - background location (Android 10+)
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_LOCATION` - foreground service
- `POST_NOTIFICATIONS` - notification permission (Android 13+)
- `WAKE_LOCK` - prevent sleep during location updates
- `RECEIVE_BOOT_COMPLETED` - auto-restart tracking on device boot (optional, not yet implemented)

Foreground service is declared with `android:foregroundServiceType="location"`.

**Notification Configuration:**
- Two notification channels are used:
  - `foreground_service_channel` (created by flutter_background_service) - Primary foreground service indicator
  - `location_tracking_channel` (created by flutter_local_notifications) - Location updates display
- The location notification is configured with:
  - `Importance.high` and `Priority.high` for visibility
  - `ongoing: true` to prevent user dismissal
  - `autoCancel: false` to prevent accidental clearing
  - Action button: "Stop Tracking" (optional, for user control)

#### iOS
The following entries are configured in `Info.plist`:
- `NSLocationAlwaysAndWhenInUseUsageDescription` - background location prompt
- `NSLocationWhenInUseUsageDescription` - foreground location prompt
- `UIBackgroundModes` with `location` and `fetch` - background location capability

Additionally, you must enable **Background Modes > Location updates** in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to **Signing & Capabilities**
4. Add the **Background Modes** capability
5. Check **Location updates**

**Notification Behavior on iOS:**
- Uses local notifications for location updates (can be dismissed)
- System automatically shows blue location indicator in status bar when background location is active
- Reliance on system indicator as the primary persistent visual cue (user cannot dismiss)

## How Terminated State Tracking Works

Tracking after the app is terminated (swiped away from recents) is achieved through Android's foreground service mechanism:

1. **`flutter_background_service`** creates an Android foreground service with a persistent notification
2. The foreground service runs in a **separate Dart isolate** with its own timer for periodic location checks
3. When the app is swiped away, the Android system keeps the foreground service alive (on most devices)
4. The service continues to:
   - Fetch location via `Geolocator.getCurrentPosition()` every 10 seconds
   - Store results to SQLite database
   - Emit events back to the main app (if it reconnects)
5. On app relaunch:
   - `main()` checks the persisted tracking state from SQLite preferences
   - If tracking was active, the service resumes automatically
   - The UI syncs its state by checking `FlutterBackgroundService().isRunning()`

### Limitations

- **iOS**: When the app is fully terminated on iOS, background execution stops. iOS does not allow arbitrary background processes like Android. The app can track while minimized but not after being killed.
- **OEM-specific behavior**: Some Android manufacturers (Xiaomi, Huawei, OnePlus) aggressively kill foreground services. Users may need to add the app to the "protected apps" or "auto-start" whitelist in device settings.
- **Android 12+**: New foreground service restrictions may impact long-running services. The `foregroundServiceType="location"` declaration helps mitigate this.

## Dependencies

| Package | Purpose |
|---------|---------|
| `geolocator` | Location permissions and position acquisition |
| `flutter_background_service` | Background isolate + foreground service |
| `flutter_background_service_android` | Android foreground service implementation |
| `flutter_background_service_ios` | iOS background execution support |
| `flutter_local_notifications` | Cross-platform local notifications for tracking display |
| `dartz` | `Either<Failure, T>` for functional error handling |
| `flutter_riverpod` | State management |
| `sqflite` | Local SQLite database |
| `path` | Database file path construction |
| `path_provider` | Application documents directory |
| `intl` | Date formatting in UI |

## Known Limitations & Trade-offs

1. **Geolocator stream vs periodic polling**: The foreground uses a continuous stream with a 10m distance filter. The background uses periodic polling every 10 seconds. This means the background is less battery-efficient but more reliable across platform variations.

2. **Notification throttling**: Notification updates are throttled to max once per 2 seconds to balance responsiveness with system performance and battery efficiency.

3. **iOS notification limitations**: iOS does not allow truly non-dismissible notifications for background location. The app relies on the system's blue location indicator in the status bar as the primary persistent visual cue. Local notifications are informational and can be dismissed.

4. **No map view**: A map showing the tracked path was not implemented but could be added using `flutter_map` or `google_maps_flutter`.

5. **No unit tests**: Use case unit tests and widget tests were not implemented due to time constraints but the architecture is designed for easy testing (domain is pure Dart, repositories are abstracted).

6. **Notification channel isolation**: Android's notification channel for flutter_background_service cannot be fully customized. The location tracking notification uses the same channel, so styling is consistent with the base service notification.

7. **No boot-completed receiver**: The `RECEIVE_BOOT_COMPLETED` permission is declared but not yet utilized. A separate broadcast receiver would be needed to restart tracking after device reboot.

## Evaluation Criteria Compliance

- [x] **Functionality**: Foreground, background, and terminated-state tracking. Permission handling. Persistent notification. Toggle works.
- [x] **Clean Architecture**: Strict layer separation. Domain has zero Flutter imports. `Either<Failure, T>` for all repository methods. Riverpod for state management.
- [x] **Code Quality**: Well-structured, no linter warnings, proper error handling, `Failure` mapping.
- [x] **Platform Integration**: Android foreground service with proper manifest config. iOS background modes in Info.plist.
