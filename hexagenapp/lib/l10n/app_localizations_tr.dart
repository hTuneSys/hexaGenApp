// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get app => 'hexaGen';

  @override
  String get appName => 'hexaGen App';

  @override
  String get profile => 'Profil';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get generateSignal => 'Sinyal Oluştur';

  @override
  String get howToUse => 'Nasıl Kullanılır';

  @override
  String get history => 'Geçmiş';

  @override
  String get ourProducts => 'Ürünlerimiz';

  @override
  String get settings => 'Ayarlar';

  @override
  String get frequencyGeneration => 'Frekans Üretimi';

  @override
  String get manualFrequency => 'Manuel Frekans';

  @override
  String selectedFrequency(String value) {
    return 'Seçili frekans: $value';
  }

  @override
  String get stepMinus10kHz => '-10 kHz';

  @override
  String get stepPlus10kHz => '+10 kHz';

  @override
  String get stepPlus1MHz => '+1 MHz';

  @override
  String get secondsLabel => 'Süre (sn)';

  @override
  String get secondsHint => 'Örn: 0.5';

  @override
  String get secondsPositiveError => 'Süre (sn) pozitif bir sayı olmalı';

  @override
  String get add => 'Ekle';

  @override
  String get listTitle => 'Liste (Frekans + Süre)';

  @override
  String get noItems => 'Henüz öğe yok. Yukarıdan ekleyin.';

  @override
  String get delete => 'Sil';

  @override
  String secondsShort(String seconds) {
    return '$seconds sn';
  }

  @override
  String get repeat => 'Tekrar';

  @override
  String get decrease => 'Azalt';

  @override
  String get increase => 'Arttır';

  @override
  String get clearAll => 'Temizle';

  @override
  String get maxItemsReached => 'Maksimum 64 öğe eklenebilir';

  @override
  String totalItems(int count) {
    return 'Toplam öğe: $count';
  }

  @override
  String repeatCount(int count) {
    return 'Tekrar: $count';
  }

  @override
  String get invalidCommand => 'AT komutu değil';

  @override
  String get ddsBusy => 'DDS meşgul';

  @override
  String get invalidUtf8 => 'Parametrede geçersiz UTF-8';

  @override
  String get invalidSysEx => 'Geçersiz SysEx';

  @override
  String get invalidDataLength => 'Geçersiz veri uzunluğu';

  @override
  String get paramCount => 'Parametre sayısı hatası';

  @override
  String get paramValue => 'Parametre değeri hatası';

  @override
  String get notAQuery => 'Sorgu değil';

  @override
  String get unknownCommand => 'Bilinmeyen komut';

  @override
  String get deviceNoDeviceConnected => 'Cihaz Bağlı Değil';

  @override
  String get devicePleaseConnect => 'Lütfen bir hexaTune cihazı bağlayın';

  @override
  String get deviceQueryingVersion => 'Versiyon sorgulanıyor...';

  @override
  String deviceVersion(String version) {
    return 'Versiyon: $version';
  }

  @override
  String deviceError(String message, String code) {
    return 'Hata: $message ($code)';
  }

  @override
  String get comingSoon => 'Yakında Hizmette';

  @override
  String get comingSoonMessage =>
      'Bu özellik yakında kullanıma sunulacak. Takipte kalın!';

  @override
  String get themeMode => 'Tema Modu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get operationCompletedSuccessfully => 'Üretim başarıyla tamamlandı';

  @override
  String get operationStoppedByUser => 'İşlem kullanıcı tarafından durduruldu';

  @override
  String get operationFailedWithErrors => 'İşlem hatalarla başarısız oldu';

  @override
  String get operationStopped => 'İşlem durduruldu';

  @override
  String get operationCompletedAndSaved => 'İşlem tamamlandı ve kaydedildi';

  @override
  String get operationFailedCheckDevice =>
      'İşlem başarısız oldu. Lütfen cihazı kontrol edin.';

  @override
  String commandTimeout(String command) {
    return 'Komut zaman aşımı: $command';
  }

  @override
  String deviceConnected(String name) {
    return 'Cihaz bağlandı: $name';
  }

  @override
  String deviceStatusChanged(String status) {
    return 'Cihaz durumu değişti: $status';
  }

  @override
  String commandFailed(String code) {
    return 'Komut başarısız: $code';
  }

  @override
  String deviceVersionReceived(String version) {
    return 'Cihaz sürümü: $version';
  }

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get noNotifications => 'Bildirim yok';

  @override
  String get resetCommandSent => 'Reset komutu gönderildi';

  @override
  String get debug => 'Hata Ayıklama';

  @override
  String get autoScroll => 'Otomatik Kaydırma';

  @override
  String get clear => 'Temizle';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterInfo => 'Bilgi+';

  @override
  String get filterWarning => 'Uyarı+';

  @override
  String get filterError => 'Hata+';

  @override
  String get noLogsYet => 'Henüz log yok';
}
