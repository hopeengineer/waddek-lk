
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waddek_lk/core/constants/supabase_constants.dart';
import 'package:waddek_lk/core/services/supabase_service.dart';
import 'package:waddek_lk/core/utils/validators.dart';

/// Handles authentication via custom OTP flow (Notify.lk) and Supabase Auth.
class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Send OTP to the given phone number via the `send-otp` Edge Function.
  ///
  /// [context] can be `"signup"` (default) or `"login_2fa"`.
  /// Returns `true` if SMS was sent successfully.
  Future<bool> sendOtp(String phone, {String context = 'signup'}) async {
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.fnSendOtp,
        body: {'phone': phone, 'context': context},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['success'] == true;
      }
      return false;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map<String, dynamic> && details['error'] != null) {
        throw Exception(details['error']);
      }
      throw Exception(e.reasonPhrase ?? 'Failed to send OTP');
    }
  }

  /// Verify OTP code and get session tokens via `verify-otp` Edge Function.
  ///
  /// [context] can be `"signup"` (default) or `"login_2fa"`.
  /// Returns the session data on success, throws on failure.
  Future<Map<String, dynamic>> verifyOtp(String phone, String code,
      {String context = 'signup'}) async {
    final dynamic data;
    try {
      final response = await _client.functions.invoke(
        SupabaseConstants.fnVerifyOtp,
        body: {'phone': phone, 'code': code, 'context': context},
      );
      data = response.data;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map<String, dynamic> && details['error'] != null) {
        throw AuthException(details['error'] as String);
      }
      throw AuthException(e.reasonPhrase ?? 'Verification failed');
    }

    if (data is! Map<String, dynamic>) {
      throw const AuthException('Unexpected response from server');
    }

    if (data['error'] != null) {
      throw AuthException(data['error'] as String);
    }

    // Set session from the returned tokens
    if (data['access_token'] != null && data['refresh_token'] != null) {
      await _client.auth.setSession(data['refresh_token'] as String);
    }

    return data;
  }

  /// Check if the current user has a profile (role selected).
  Future<bool> hasProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;

    final result = await _client
        .from(SupabaseConstants.profiles)
        .select('id, role')
        .eq('id', userId)
        .maybeSingle();

    return result != null;
  }

  /// Set the user's role (customer or worker) during onboarding.
  Future<void> setRole(String role) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw const AuthException('Not authenticated');

    await _client.from(SupabaseConstants.profiles).upsert({
      'id': userId,
      'role': role,
      'active_role': role,
      'phone': _client.auth.currentUser?.phone ?? '',
    });
  }

  /// Log in with phone/email + password via `login` Edge Function.
  /// Returns the response data (includes `requires_2fa`, `phone`, `user_id`).
  Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    try {
      final response = await _client.functions.invoke(
        'login',
        body: {'identifier': identifier, 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] != null) {
          throw AuthException(data['error'] as String);
        }
        return data;
      }
      throw const AuthException('Unexpected response from server');
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map<String, dynamic> && details['error'] != null) {
        throw AuthException(details['error'] as String);
      }
      throw AuthException(e.reasonPhrase ?? 'Login failed');
    }
  }

  /// Register a new user: update Auth user with email/password, create profile.
  Future<void> register({
    required String phone,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw const AuthException('Not authenticated');

    // Update Supabase Auth user with real email and password
    await _client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
        data: {'full_name': fullName},
      ),
    );

    // Update the profile with registration info
    await _client.from(SupabaseConstants.profiles).upsert({
      'id': userId,
      'phone': Validators.normalizePhone(phone),
      'email': email,
      'full_name': fullName,
      'registration_completed': true,
    });
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Listen to auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
