/// Waddek.lk — On-demand service marketplace for Sri Lanka
///
/// App entry point. Initializes Supabase, Firebase, and
/// launches the MaterialApp with the dark neon theme.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast if secrets weren't injected. Run with
  //   flutter run --dart-define-from-file=.env
  // (.env is gitignored — see .env.example for the required keys).
  if (AppConstants.supabaseUrl.isEmpty ||
      AppConstants.supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
      'Run with `flutter run --dart-define-from-file=.env` '
      '(copy .env.example to .env and fill in the values).',
    );
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // OneSignal push notifications. Self-aborts if ONESIGNAL_APP_ID
  // is not provided via --dart-define, so it's safe in dev.
  unawaited(NotificationService().init());

  runApp(
    const ProviderScope(
      child: WaddekApp(),
    ),
  );
}
