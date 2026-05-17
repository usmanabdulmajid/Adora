import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Tracker'**
  String get appTitle;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Tracker'**
  String get appBarTitle;

  /// No description provided for @backgroundTrackingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Tracking Requires Always Allow'**
  String get backgroundTrackingDialogTitle;

  /// No description provided for @backgroundTrackingDialogContent.
  ///
  /// In en, this message translates to:
  /// **'To track your location even when the app is closed or in the background, please enable \"Allow all the time\" location access in system settings.'**
  String get backgroundTrackingDialogContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @backgroundTracking.
  ///
  /// In en, this message translates to:
  /// **'Background Tracking'**
  String get backgroundTracking;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location: {error}'**
  String unableToGetLocation(Object error);

  /// No description provided for @trackingHistory.
  ///
  /// In en, this message translates to:
  /// **'Tracking History (Last 10)'**
  String get trackingHistory;

  /// No description provided for @noLocationData.
  ///
  /// In en, this message translates to:
  /// **'No location data recorded yet'**
  String get noLocationData;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String failedToLoadHistory(Object error);

  /// No description provided for @locationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Location Permission: Granted'**
  String get locationPermissionGranted;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location Permission: Denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequiredTitle;

  /// No description provided for @locationPermissionRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable location access to track your position'**
  String get locationPermissionRequiredDescription;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Tracker'**
  String get notificationTitle;

  /// No description provided for @notificationLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get notificationLatitude;

  /// No description provided for @notificationLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get notificationLongitude;

  /// No description provided for @notificationUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationUpdatedJustNow;

  /// No description provided for @notificationUpdatedSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds ago'**
  String notificationUpdatedSecondsAgo(Object seconds);

  /// No description provided for @notificationUpdatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String notificationUpdatedMinutesAgo(Object minutes);

  /// No description provided for @notificationUpdatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String notificationUpdatedHoursAgo(Object hours);

  /// No description provided for @notificationStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Tracking'**
  String get notificationStopButton;

  /// No description provided for @notificationAcquiringLocation.
  ///
  /// In en, this message translates to:
  /// **'Acquiring location...'**
  String get notificationAcquiringLocation;

  /// No description provided for @notificationWaitingForGPS.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS signal...'**
  String get notificationWaitingForGPS;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
