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
  String get clearAll => 'Tümünü Temizle';

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
  String get invalidBase64 => 'Geçersiz base64 parametresi';

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
}
