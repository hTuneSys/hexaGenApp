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
  String get maxItemsReached => 'Maximum 64 items allowed';

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
  String get ddsBusy => 'DDS busy';

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

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get comingSoonMessage =>
      'This feature will be available soon. Stay tuned!';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get operationCompletedSuccessfully =>
      'Generation completed successfully';

  @override
  String get operationStoppedByUser => 'Operation stopped by user';

  @override
  String get operationFailedWithErrors => 'Operation failed with errors';

  @override
  String get operationStopped => 'Operation stopped';

  @override
  String get operationCompletedAndSaved => 'Operation completed and saved';

  @override
  String get operationFailedCheckDevice =>
      'Operation failed. Please check the device.';

  @override
  String commandTimeout(String command) {
    return 'Command timeout: $command';
  }

  @override
  String deviceConnected(String name) {
    return 'Device connected: $name';
  }

  @override
  String deviceStatusChanged(String status) {
    return 'Device status changed to $status';
  }

  @override
  String commandFailed(String code) {
    return 'Command failed: $code';
  }

  @override
  String deviceVersionReceived(String version) {
    return 'Device version: $version';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get resetCommandSent => 'Reset command sent';

  @override
  String get debug => 'Debug';

  @override
  String get autoScroll => 'Auto Scroll';

  @override
  String get clear => 'Clear';

  @override
  String get filterAll => 'All';

  @override
  String get filterInfo => 'Info+';

  @override
  String get filterWarning => 'Warn+';

  @override
  String get filterError => 'Error+';

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get historyTitle => 'Operation History';

  @override
  String get noOperationsYet => 'No operations saved yet';

  @override
  String get operationDate => 'Operation Date';

  @override
  String totalItemsCount(int count) {
    return 'Total Items: $count';
  }

  @override
  String totalDuration(String duration) {
    return 'Total Duration: $duration';
  }

  @override
  String get regenerate => 'Regenerate';

  @override
  String get frequency => 'Frequency';

  @override
  String get duration => 'Duration';

  @override
  String get operationRegenerated => 'Operation loaded to generation page';
}
