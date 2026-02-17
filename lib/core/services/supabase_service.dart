import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton accessor for the Supabase client.
///
/// Usage: `SupabaseService.client.from('table')...`
abstract class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user or null
  static User? get currentUser => client.auth.currentUser;

  /// Current user ID or null
  static String? get currentUserId => currentUser?.id;

  /// Whether a user is currently authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Invoke a Supabase Edge Function
  static Future<FunctionResponse> invokeFunction(
    String name, {
    Map<String, dynamic>? body,
  }) {
    return client.functions.invoke(name, body: body);
  }
}
