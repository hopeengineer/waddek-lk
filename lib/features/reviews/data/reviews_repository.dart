import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/review_model.dart';

/// Data layer for review operations.
class ReviewsRepository {
  final _client = SupabaseService.client;

  /// Submit a review for a completed job.
  Future<ReviewModel> submitReview({
    required String jobId,
    required String workerId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client
        .from(SupabaseConstants.reviews)
        .insert({
          'job_id': jobId,
          'customer_id': userId,
          'worker_id': workerId,
          'rating': rating,
          'comment': comment,
        })
        .select()
        .single();

    return ReviewModel.fromJson(data);
  }

  /// Fetch reviews for a worker. Uses a SECURITY DEFINER RPC so the
  /// reviewer's public fields are returned even when the viewing user
  /// isn't a counterparty of that reviewer. Also bridges the schema
  /// mismatch (DB columns reviewer_id/reviewee_id ↔ model's
  /// customer_id/worker_id).
  Future<List<ReviewModel>> getWorkerReviews(String workerId,
      {int limit = 20}) async {
    final data = await _client.rpc(
      'get_worker_reviews_with_authors',
      params: {'p_worker_id': workerId, 'p_limit': limit},
    );
    return (data as List)
        .map<ReviewModel>(
            (row) => ReviewModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Check if customer already reviewed a job.
  Future<bool> hasReviewed(String jobId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final data = await _client
        .from(SupabaseConstants.reviews)
        .select('id')
        .eq('job_id', jobId)
        .eq('customer_id', userId)
        .maybeSingle();

    return data != null;
  }
}
