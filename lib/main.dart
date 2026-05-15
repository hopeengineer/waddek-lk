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

  // Initialize Supabase
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
