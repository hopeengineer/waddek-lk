import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waddek_lk/core/constants/supabase_constants.dart';
import 'package:waddek_lk/core/services/supabase_service.dart';

/// Handles authentication via custom OTP flow (Notify.lk) and Supabase Auth.
class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Send OTP to the given phone number via the `send-otp` Edge Function.
  ///
  /// Returns `true` if SMS was sent successfully.
  Future<bool> sendOtp(String phone) async {
    final response = await _client.functions.invoke(
      SupabaseConstants.fnSendOtp,
      body: {'phone': phone},
    );

    final data = jsonDecode(response.data as String);
    return data['success'] == true;
  }

  /// Verify OTP code and get session tokens via `verify-otp` Edge Function.
  ///
  /// Returns the session data on success, throws on failure.
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final response = await _client.functions.invoke(
      SupabaseConstants.fnVerifyOtp,
      body: {'phone': phone, 'code': code},
    );

    final data = jsonDecode(response.data as String);

    if (data['error'] != null) {
      throw AuthException(data['error'] as String);
    }

    // Set session from the returned tokens
    if (data['access_token'] != null) {
      await _client.auth.setSession(data['access_token'] as String);
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
      'phone': _client.auth.currentUser?.phone ?? '',
    });
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Listen to auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
