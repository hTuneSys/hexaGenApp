// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app => 'hexaGen';

  @override
  String get appName => 'hexaGen App';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get generateSignal => 'Generate Signal';

  @override
  String get howToUse => 'How to use';

  @override
  String get history => 'History';

  @override
  String get ourProducts => 'Our Products';

  @override
  String get settings => 'Settings';

  @override
  String get frequencyGeneration => 'Frequency Generation';

  @override
  String get manualFrequency => 'Manual Frequency';

  @override
  String selectedFrequency(String value) {
    return 'Selected frequency: $value';
  }

  @override
  String get stepMinus10kHz => '-10 kHz';

  @override
  String get stepPlus10kHz => '+10 kHz';

  @override
  String get stepPlus1MHz => '+1 MHz';

  @override
  String get secondsLabel => 'Duration (s)';

  @override
  String get secondsHint => 'e.g. 0.5';

  @override
  String get secondsPositiveError => 'Duration (s) must be a positive number';

  @override
  String get add => 'Add';

  @override
  String get listTitle => 'List (Frequency + Duration)';

  @override
  String get noItems => 'No items yet. Add from above.';

  @override
  String get delete => 'Delete';

  @override
  String secondsShort(String seconds) {
    return '$seconds s';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get clearAll => 'Clear All';

  @override
  String totalItems(int count) {
    return 'Total items: $count';
  }

  @override
  String repeatCount(int count) {
    return 'Repeat: $count';
  }

  @override
  String get invalidCommand => 'Not an AT command';

  @override
  String get invalidBase64 => 'Invalid base64 param';

  @override
  String get invalidUtf8 => 'Invalid UTF-8 in param';

  @override
  String get invalidSysEx => 'Invalid SysEx';

  @override
  String get invalidDataLength => 'Invalid data length';

  @override
  String get paramCount => 'Param count';

  @override
  String get paramValue => 'Param value';

  @override
  String get notAQuery => 'Not a query';

  @override
  String get unknownCommand => 'Unknown command';

  @override
  String get deviceNoDeviceConnected => 'No Device Connected';

  @override
  String get devicePleaseConnect => 'Please connect a hexaTune device';

  @override
  String get deviceQueryingVersion => 'Querying version...';

  @override
  String deviceVersion(String version) {
    return 'Version: $version';
  }

  @override
  String deviceError(String message, String code) {
    return 'Error: $message ($code)';
  }
}
