import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/jobs_repository.dart';
import '../../domain/job_model.dart';
import '../../domain/bid_model.dart';

/// Provides [JobsRepository] singleton.
final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository();
});

/// Customer's jobs list.
final customerJobsProvider = StateNotifierProvider<CustomerJobsNotifier,
    AsyncValue<List<JobModel>>>((ref) {
  return CustomerJobsNotifier(ref.read(jobsRepositoryProvider));
});

/// Available jobs for a worker.
final availableJobsProvider = StateNotifierProvider<AvailableJobsNotifier,
    AsyncValue<List<JobModel>>>((ref) {
  return AvailableJobsNotifier(ref.read(jobsRepositoryProvider));
});

/// Bids for a specific job (realtime).
final jobBidsProvider = StreamProvider.family<List<BidModel>, String>(
    (ref, jobId) {
  final repo = ref.read(jobsRepositoryProvider);
  return repo.streamBidsForJob(jobId).map(
        (rows) => rows.map((b) => BidModel.fromJson(b)).toList(),
      );
});

/// Customer's jobs list notifier.
class CustomerJobsNotifier
    extends StateNotifier<AsyncValue<List<JobModel>>> {
  CustomerJobsNotifier(this._repo) : super(const AsyncValue.loading());

  final JobsRepository _repo;

  Future<void> loadJobs(String customerId) async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _repo.getCustomerJobs(customerId);
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create a new job.
  Future<JobModel> createJob({
    required String customerId,
    required String categoryId,
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    String? address,
    double? budgetMin,
    double? budgetMax,
    DateTime? scheduledAt,
    List<String>? photoUrls,
  }) async {
    final job = await _repo.createJob(
      customerId: customerId,
      categoryId: categoryId,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      scheduledAt: scheduledAt,
      photoUrls: photoUrls,
    );
    // Prepend to list
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([job, ...current]);
    return job;
  }

  /// Broadcast a draft job.
  Future<void> broadcastJob(String jobId) async {
    final updated = await _repo.updateJobStatus(jobId, 'broadcast');
    _replaceJob(updated);
  }

  /// Accept a bid and match worker.
  Future<void> acceptBidAndMatch({
    required String jobId,
    required String bidId,
    required String workerId,
  }) async {
    await _repo.acceptBid(bidId);
    final matched =
        await _repo.matchWorker(jobId: jobId, workerId: workerId);
    _replaceJob(matched);
  }

  /// Cancel a job.
  Future<void> cancelJob(String jobId) async {
    final updated = await _repo.updateJobStatus(jobId, 'cancelled');
    _replaceJob(updated);
  }

  void _replaceJob(JobModel updated) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((j) => j.id == updated.id ? updated : j).toList(),
    );
  }
}

/// Available jobs notifier for workers.
class AvailableJobsNotifier
    extends StateNotifier<AsyncValue<List<JobModel>>> {
  AvailableJobsNotifier(this._repo) : super(const AsyncValue.loading());

  final JobsRepository _repo;

  Future<void> loadJobs({
    required String workerId,
    required List<String> categoryIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _repo.getAvailableJobs(
        workerId: workerId,
        categoryIds: categoryIds,
      );
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Place a bid on a job.
  Future<BidModel> placeBid({
    required String jobId,
    required String workerId,
    required double amount,
    String? message,
  }) async {
    return _repo.placeBid(
      jobId: jobId,
      workerId: workerId,
      amount: amount,
      message: message,
    );
  }
}
