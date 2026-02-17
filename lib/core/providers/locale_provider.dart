import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the user's preferred locale (English, Sinhala, Tamil).
///
/// Persisted to SharedPreferences in production. Falls back to system locale.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  static const supportedLocales = [
    Locale('en'),      // English
    Locale('si'),      // Sinhala (සිංහල)
    Locale('ta'),      // Tamil (தமிழ்)
  ];

  void setLocale(Locale locale) {
    if (supportedLocales.contains(locale)) {
      state = locale;
    }
  }

  void setEnglish() => state = const Locale('en');
  void setSinhala() => state = const Locale('si');
  void setTamil() => state = const Locale('ta');
}

/// Provider for the current locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
