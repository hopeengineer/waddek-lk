
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waddek_lk/core/constants/supabase_constants.dart';
import 'package:waddek_lk/core/services/supabase_service.dart';
import 'package:waddek_lk/core/utils/validators.dart';

/// Handles authentication via custom OTP flow (Notify.lk) and Supabase Auth.
class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Dev-only flag. When the build is launched with
  /// `--dart-define=DEV_SKIP_2FA=true`, [login] calls
  /// `auth.signInWithPassword` directly instead of the `login` edge
  /// function, bypassing the OTP step. The production login flow on
  /// the server is untouched.
  static const _devSkip2fa =
      bool.fromEnvironment('DEV_SKIP_2FA', defaultValue: false);

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
  ///
  /// When built with `--dart-define=DEV_SKIP_2FA=true`, we bypass the
  /// edge function entirely and call `signInWithPassword` directly —
  /// gives a session with no OTP. Server auth flow is untouched.
  Future<Map<String, dynamic>> login(
      String identifier, String password) async {
    if (_devSkip2fa) {
      return _devDirectSignIn(identifier, password);
    }

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

  /// Dev-only direct sign-in. Mirrors the email-derivation logic of
  /// `login/index.ts:36-56` so phone-based identifiers map to the
  /// same fake email used during signup.
  Future<Map<String, dynamic>> _devDirectSignIn(
      String identifier, String password) async {
    final id = identifier.trim();
    String email;
    if (id.contains('@')) {
      email = id.toLowerCase();
    } else {
      final normalized = Validators.normalizePhone(id);
      final phoneWithoutPlus = normalized.replaceFirst('+', '');
      email = 'phone_$phoneWithoutPlus@waddek.lk';
    }
    try {
      final res = await _client.auth
          .signInWithPassword(email: email, password: password);
      return {
        'requires_2fa': false,
        'phone': res.user?.phone ?? '',
        'user_id': res.user?.id ?? '',
      };
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Dev sign-in failed: $e');
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

  /// Update the current authenticated user's password. Called after a
  /// successful password-reset OTP verification (which establishes the
  /// session used by this call).
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Begin a phone-change. Sends an OTP to [newPhone] via send-otp
  /// (context=change_phone). The server stages the new value in
  /// `profiles.pending_phone`; the live `phone` column is untouched
  /// until [confirmPhoneChange] succeeds.
  Future<void> requestPhoneChange(String newPhone) async {
    final ok = await sendOtp(newPhone, context: 'change_phone');
    if (!ok) throw const AuthException('Failed to send verification code.');
  }

  /// Finish a phone-change. The edge function verifies the OTP and
  /// atomically swaps the new phone into both auth.users and profiles,
  /// rolling back if either side fails.
  Future<void> confirmPhoneChange({
    required String newPhone,
    required String code,
  }) async {
    await verifyOtp(newPhone, code, context: 'change_phone');
  }

  /// Begin an email-change. Uses Supabase's built-in flow: an email
  /// containing a confirmation link is sent to [newEmail]. The live
  /// `auth.users.email` (and via trigger, `profiles.email`) only
  /// changes after the user clicks that link. We also stage the new
  /// address in `profiles.pending_email` for UI display.
  Future<void> requestEmailChange(String newEmail) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw const AuthException('Not authenticated');
    await _client.auth.updateUser(UserAttributes(email: newEmail));
    await _client
        .from(SupabaseConstants.profiles)
        .update({'pending_email': newEmail}).eq('id', userId);
  }

  /// Discard a staged phone change. Clears `pending_phone` so the
  /// edit screen doesn't keep showing a stale "pending verification".
  Future<void> cancelPhoneChange() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    await _client
        .from(SupabaseConstants.profiles)
        .update({'pending_phone': null}).eq('id', userId);
  }

  /// Discard a staged email change. Note Supabase still holds the
  /// pending email confirmation server-side until it expires — this
  /// just clears the UI-visible pending_email column.
  Future<void> cancelEmailChange() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    await _client
        .from(SupabaseConstants.profiles)
        .update({'pending_email': null}).eq('id', userId);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Listen to auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
