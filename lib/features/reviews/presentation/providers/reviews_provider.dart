import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reviews_repository.dart';
import '../../domain/review_model.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository();
});

/// Worker reviews.
final workerReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, workerId) async {
  return ref.read(reviewsRepositoryProvider).getWorkerReviews(workerId);
});
