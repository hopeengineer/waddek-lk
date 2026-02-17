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

  /// Fetch reviews for a worker.
  Future<List<ReviewModel>> getWorkerReviews(String workerId,
      {int limit = 20}) async {
    final data = await _client
        .from(SupabaseConstants.reviews)
        .select('''
          *,
          customer:profiles!customer_id(full_name, avatar_url),
          job:jobs!job_id(title, category_id)
        ''')
        .eq('worker_id', workerId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data
        .map<ReviewModel>((r) => ReviewModel.fromJson(r))
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
