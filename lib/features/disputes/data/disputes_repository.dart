import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/dispute_model.dart';

/// Data layer for dispute operations.
class DisputesRepository {
  final _client = SupabaseService.client;

  /// Raise a dispute.
  Future<DisputeModel> raiseDispute({
    required String jobId,
    required String reason,
    String? description,
    List<String>? evidenceUrls,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client
        .from(SupabaseConstants.disputes)
        .insert({
          'job_id': jobId,
          'raised_by': userId,
          'reason': reason,
          'description': description,
          'evidence_urls': evidenceUrls,
          'status': 'open',
        })
        .select()
        .single();

    // Update job status
    await _client
        .from(SupabaseConstants.jobs)
        .update({'status': 'disputed'})
        .eq('id', jobId);

    return DisputeModel.fromJson(data);
  }

  /// Fetch disputes for the current user.
  Future<List<DisputeModel>> getMyDisputes() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(SupabaseConstants.disputes)
        .select()
        .eq('raised_by', userId)
        .order('created_at', ascending: false);

    return data
        .map<DisputeModel>((d) => DisputeModel.fromJson(d))
        .toList();
  }

  /// Upload evidence photo.
  Future<String> uploadEvidence(String jobId, String filePath) async {
    final userId = _client.auth.currentUser!.id;
    final ext = filePath.split('.').last;
    final path = '$userId/$jobId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage
        .from(SupabaseConstants.evidenceBucket)
        .upload(path, Uri.parse(filePath) as dynamic);

    return _client.storage
        .from(SupabaseConstants.evidenceBucket)
        .getPublicUrl(path);
  }
}
