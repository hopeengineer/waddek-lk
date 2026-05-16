import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/profile/presentation/providers/profile_provider.dart';

/// Manages the user's preferred locale (English, Sinhala, Tamil).
///
/// Two persistence layers:
///   * SharedPreferences — fast local cache so cold start lands in the
///     user's last-chosen language without a network round-trip.
///   * profiles.preferred_locale — server-side store so the choice
///     follows the user across devices once they sign in.
///
/// Resolution order on app start:
///   1. SharedPreferences (sync-ish, very fast).
///   2. When the profile loads, the server value (if different) wins
///      and is mirrored back into the local cache.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _bootstrap();
  }

  final Ref _ref;
  static const _prefsKey = 'preferred_locale';

  static const supportedLocales = [
    Locale('en'),      // English
    Locale('si'),      // Sinhala (සිංහල)
    Locale('ta'),      // Tamil (தமிழ்)
  ];

  Future<void> _bootstrap() async {
    // 1. Local cache — fast path.
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);
    if (cached != null) {
      final loc = Locale(cached);
      if (supportedLocales.contains(loc)) {
        state = loc;
      }
    }

    // 2. Server value — once the profile loads, prefer it (handles
    //    cross-device sync after sign-in).
    _ref.listen(currentProfileProvider, (_, next) {
      final profile = next.valueOrNull;
      if (profile == null) return;
      final serverLocale = Locale(profile.preferredLocale);
      if (supportedLocales.contains(serverLocale) &&
          serverLocale != state) {
        state = serverLocale;
        // Mirror to cache so the next cold start picks this up
        // offline / before the profile has loaded.
        prefs.setString(_prefsKey, serverLocale.languageCode);
      }
    });
  }

  /// Set the locale, persisting to both local cache and server.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    state = locale;

    // Local cache — synchronous from the user's perspective.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);

    // Server sync — best-effort. If the user isn't signed in yet, or
    // the network is down, the local cache still wins.
    final profile = _ref.read(currentProfileProvider).valueOrNull;
    if (profile != null) {
      try {
        await _ref.read(profileRepositoryProvider).updateProfile(
              userId: profile.id,
              fields: {'preferred_locale': locale.languageCode},
            );
      } catch (_) {
        // Swallow — UX shouldn't break on a transient sync failure.
      }
    }
  }

  Future<void> setEnglish() => setLocale(const Locale('en'));
  Future<void> setSinhala() => setLocale(const Locale('si'));
  Future<void> setTamil() => setLocale(const Locale('ta'));
}

/// Provider for the current locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});
