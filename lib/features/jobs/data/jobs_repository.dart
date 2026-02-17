import 'dart:io' as java_io;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';
import '../domain/job_model.dart';
import '../domain/bid_model.dart';

/// Data layer for job and bid operations.
class JobsRepository {
  final _client = SupabaseService.client;

  // ── Jobs — Read ──────────────────────────────────────────

  /// Fetch a single job by ID with customer and category info.
  Future<JobModel?> getJob(String jobId) async {
    final data = await _client
        .from(SupabaseConstants.jobs)
        .select('*, customer:profiles!customer_id(id, full_name, avatar_url, phone), category:categories!category_id(id, name_en, name_si, name_ta, icon)')
        .eq('id', jobId)
        .maybeSingle();
    if (data == null) return null;
    return JobModel.fromJson(data);
  }

  /// Fetch jobs posted by a customer (My Jobs).
  Future<List<JobModel>> getCustomerJobs(String customerId) async {
    final data = await _client
        .from(SupabaseConstants.jobs)
        .select('*, category:categories!category_id(id, name_en, name_si, name_ta, icon)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return data.map<JobModel>((j) => JobModel.fromJson(j)).toList();
  }

  /// Fetch available jobs for a worker (broadcast/bidding status, in their categories).
  Future<List<JobModel>> getAvailableJobs({
    required String workerId,
    required List<String> categoryIds,
  }) async {
    if (categoryIds.isEmpty) return [];
    final data = await _client
        .from(SupabaseConstants.jobs)
        .select('*, customer:profiles!customer_id(id, full_name, avatar_url), category:categories!category_id(id, name_en, name_si, name_ta, icon)')
        .inFilter('category_id', categoryIds)
        .inFilter('status', ['broadcast', 'bidding'])
        .order('created_at', ascending: false);
    return data.map<JobModel>((j) => JobModel.fromJson(j)).toList();
  }

  /// Fetch jobs where a worker has been matched.
  Future<List<JobModel>> getWorkerActiveJobs(String workerId) async {
    final data = await _client
        .from(SupabaseConstants.jobs)
        .select('*, customer:profiles!customer_id(id, full_name, avatar_url, phone), category:categories!category_id(id, name_en, name_si, name_ta, icon)')
        .eq('matched_worker_id', workerId)
        .inFilter('status', ['matched', 'in_progress'])
        .order('updated_at', ascending: false);
    return data.map<JobModel>((j) => JobModel.fromJson(j)).toList();
  }

  // ── Jobs — Write ─────────────────────────────────────────

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
    int broadcastRadiusKm = 5,
  }) async {
    final point = 'POINT($longitude $latitude)';
    final data = await _client
        .from(SupabaseConstants.jobs)
        .insert({
          'customer_id': customerId,
          'category_id': categoryId,
          'title': title,
          'description': description,
          'location': point,
          'address': address,
          'budget_min': budgetMin,
          'budget_max': budgetMax,
          'scheduled_at': scheduledAt?.toIso8601String(),
          'photo_urls': photoUrls,
          'broadcast_radius_km': broadcastRadiusKm,
          'status': 'draft',
        })
        .select()
        .single();
    return JobModel.fromJson(data);
  }

  /// Update a job's status.
  Future<JobModel> updateJobStatus(String jobId, String status) async {
    final data = await _client
        .from(SupabaseConstants.jobs)
        .update({'status': status})
        .eq('id', jobId)
        .select()
        .single();
    return JobModel.fromJson(data);
  }

  /// Match a worker to a job.
  Future<JobModel> matchWorker({
    required String jobId,
    required String workerId,
  }) async {
    final data = await _client
        .from(SupabaseConstants.jobs)
        .update({
          'matched_worker_id': workerId,
          'status': 'matched',
        })
        .eq('id', jobId)
        .select()
        .single();
    return JobModel.fromJson(data);
  }

  /// Upload job photos and return URLs.
  Future<List<String>> uploadJobPhotos({
    required String jobId,
    required List<String> filePaths,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < filePaths.length; i++) {
      final file = await java_io.File(filePaths[i]).readAsBytes();
      final url = await StorageService.uploadJobPhoto(
        jobId,
        'photo_$i',
        file,
      );
      urls.add(url);
    }
    return urls;
  }

  // ── Bids — Read ──────────────────────────────────────────

  /// Fetch bids for a job (customer view — includes worker info).
  Future<List<BidModel>> getBidsForJob(String jobId) async {
    final data = await _client
        .from(SupabaseConstants.bids)
        .select('*, worker:profiles!worker_id(id, full_name, avatar_url, tier, average_rating, jobs_completed_count, verification_status)')
        .eq('job_id', jobId)
        .order('created_at', ascending: false);
    return data.map<BidModel>((b) => BidModel.fromJson(b)).toList();
  }

  /// Fetch bids placed by a worker (worker view).
  Future<List<BidModel>> getWorkerBids(String workerId) async {
    final data = await _client
        .from(SupabaseConstants.bids)
        .select()
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);
    return data.map<BidModel>((b) => BidModel.fromJson(b)).toList();
  }

  // ── Bids — Write ─────────────────────────────────────────

  /// Place a bid on a job.
  Future<BidModel> placeBid({
    required String jobId,
    required String workerId,
    required double amount,
    String? message,
  }) async {
    final data = await _client
        .from(SupabaseConstants.bids)
        .insert({
          'job_id': jobId,
          'worker_id': workerId,
          'amount': amount,
          'message': message,
          'status': 'pending',
        })
        .select()
        .single();
    return BidModel.fromJson(data);
  }

  /// Accept a bid (customer action).
  Future<BidModel> acceptBid(String bidId) async {
    final data = await _client
        .from(SupabaseConstants.bids)
        .update({'status': 'accepted'})
        .eq('id', bidId)
        .select()
        .single();
    return BidModel.fromJson(data);
  }

  /// Reject a bid.
  Future<BidModel> rejectBid(String bidId) async {
    final data = await _client
        .from(SupabaseConstants.bids)
        .update({'status': 'rejected'})
        .eq('id', bidId)
        .select()
        .single();
    return BidModel.fromJson(data);
  }

  // ── Realtime ─────────────────────────────────────────────

  /// Stream bids for a job in realtime (customer watches incoming bids).
  Stream<List<Map<String, dynamic>>> streamBidsForJob(String jobId) {
    return _client
        .from(SupabaseConstants.bids)
        .stream(primaryKey: ['id'])
        .eq('job_id', jobId);
  }
}
