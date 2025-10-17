import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'hexaGen'**
  String get app;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'hexaGen App'**
  String get appName;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @generateSignal.
  ///
  /// In en, this message translates to:
  /// **'Generate Signal'**
  String get generateSignal;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @ourProducts.
  ///
  /// In en, this message translates to:
  /// **'Our Products'**
  String get ourProducts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @frequencyGeneration.
  ///
  /// In en, this message translates to:
  /// **'Frequency Generation'**
  String get frequencyGeneration;

  /// No description provided for @manualFrequency.
  ///
  /// In en, this message translates to:
  /// **'Manual Frequency'**
  String get manualFrequency;

  /// Label above the slider showing the currently selected frequency
  ///
  /// In en, this message translates to:
  /// **'Selected frequency: {value}'**
  String selectedFrequency(String value);

  /// No description provided for @stepMinus10kHz.
  ///
  /// In en, this message translates to:
  /// **'-10 kHz'**
  String get stepMinus10kHz;

  /// No description provided for @stepPlus10kHz.
  ///
  /// In en, this message translates to:
  /// **'+10 kHz'**
  String get stepPlus10kHz;

  /// No description provided for @stepPlus1MHz.
  ///
  /// In en, this message translates to:
  /// **'+1 MHz'**
  String get stepPlus1MHz;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (s)'**
  String get secondsLabel;

  /// No description provided for @secondsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0.5'**
  String get secondsHint;

  /// No description provided for @secondsPositiveError.
  ///
  /// In en, this message translates to:
  /// **'Duration (s) must be a positive number'**
  String get secondsPositiveError;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @listTitle.
  ///
  /// In en, this message translates to:
  /// **'List (Frequency + Duration)'**
  String get listTitle;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Add from above.'**
  String get noItems;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Short seconds unit next to a numeric value
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(String seconds);

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Summary label on the left
  ///
  /// In en, this message translates to:
  /// **'Total items: {count}'**
  String totalItems(int count);

  /// Summary label on the right
  ///
  /// In en, this message translates to:
  /// **'Repeat: {count}'**
  String repeatCount(int count);

  /// No description provided for @invalidCommand.
  ///
  /// In en, this message translates to:
  /// **'Not an AT command'**
  String get invalidCommand;

  /// No description provided for @invalidBase64.
  ///
  /// In en, this message translates to:
  /// **'Invalid base64 param'**
  String get invalidBase64;

  /// No description provided for @invalidUtf8.
  ///
  /// In en, this message translates to:
  /// **'Invalid UTF-8 in param'**
  String get invalidUtf8;

  /// No description provided for @invalidSysEx.
  ///
  /// In en, this message translates to:
  /// **'Invalid SysEx'**
  String get invalidSysEx;

  /// No description provided for @invalidDataLength.
  ///
  /// In en, this message translates to:
  /// **'Invalid data length'**
  String get invalidDataLength;

  /// No description provided for @paramCount.
  ///
  /// In en, this message translates to:
  /// **'Param count'**
  String get paramCount;

  /// No description provided for @paramValue.
  ///
  /// In en, this message translates to:
  /// **'Param value'**
  String get paramValue;

  /// No description provided for @notAQuery.
  ///
  /// In en, this message translates to:
  /// **'Not a query'**
  String get notAQuery;

  /// No description provided for @unknownCommand.
  ///
  /// In en, this message translates to:
  /// **'Unknown command'**
  String get unknownCommand;

  /// No description provided for @deviceNoDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'No Device Connected'**
  String get deviceNoDeviceConnected;

  /// No description provided for @devicePleaseConnect.
  ///
  /// In en, this message translates to:
  /// **'Please connect a hexaTune device'**
  String get devicePleaseConnect;

  /// No description provided for @deviceQueryingVersion.
  ///
  /// In en, this message translates to:
  /// **'Querying version...'**
  String get deviceQueryingVersion;

  /// Device version label
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String deviceVersion(String version);

  /// Device error message with code
  ///
  /// In en, this message translates to:
  /// **'Error: {message} ({code})'**
  String deviceError(String message, String code);
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
