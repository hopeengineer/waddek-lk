import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

/// Thin REST wrapper around the Shufti edge functions + the
/// `profiles.verification_status` poll.
class VerificationRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Begin verification. The edge function increments the lifetime
  /// attempts counter and returns a hosted-page URL to open in a
  /// browser. Throws on any non-2xx response.
  Future<String> startVerification(String docType) async {
    final response = await _client.functions.invoke(
      SupabaseConstants.fnShuftiStartVerification,
      body: {'doc_type': docType},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['error'] != null) {
        throw Exception(data['error'] as String);
      }
      final url = data['verification_url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Server did not return a verification URL.');
      }
      return url;
    }
    throw Exception('Unexpected response from server.');
  }

  /// Recover account when duplicate is detected. Edge function
  /// transfers caller's phone/email onto the target, deletes the
  /// caller, and returns a magic-link `token_hash` the client can
  /// pass to `auth.verifyOtp` to establish a session as the target.
  Future<Map<String, dynamic>> recoverAccountById() async {
    final response = await _client.functions.invoke(
      SupabaseConstants.fnRecoverAccountById,
      body: const {},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['error'] != null) {
        throw Exception(data['error'] as String);
      }
      return data;
    }
    throw Exception('Unexpected response from server.');
  }
}
