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

  /// Fetch available jobs for a worker (broadcast/bidding status, in
  /// their categories). Uses a SECURITY DEFINER RPC so the customer's
  /// public profile fields come through even though the worker isn't
  /// yet a counterparty under the tightened profiles RLS.
  Future<List<JobModel>> getAvailableJobs({
    required String workerId,
    required List<String> categoryIds,
  }) async {
    if (categoryIds.isEmpty) return [];
    final data = await _client.rpc(
      'get_available_jobs_for_worker',
      params: {
        'p_worker_id': workerId,
        'p_category_ids': categoryIds,
      },
    );
    return (data as List)
        .map<JobModel>(
            (row) => JobModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
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

  /// Create a draft job proposed inside an existing chat. The job
  /// is pre-bound to its two parties (customer_id + matched_worker_id)
  /// and has broadcast_radius_km=0 because it isn't a marketplace
  /// listing. `proposedBy` is whichever auth user is making this
  /// offer — the OTHER party is the one who can accept/amend/reject.
  /// Status stays 'draft' until a settlement RPC fires.
  Future<JobModel> createChatProposedJob({
    required String customerId,
    required String workerId,
    required String proposedBy,
    required String categoryId,
    required String title,
    double? price,
    DateTime? scheduledAt,
    required double customerLat,
    required double customerLng,
  }) async {
    final point = 'POINT($customerLng $customerLat)';
    final data = await _client
        .from(SupabaseConstants.jobs)
        .insert({
          'customer_id': customerId,
          'matched_worker_id': workerId,
          'proposed_by': proposedBy,
          'category_id': categoryId,
          'title': title,
          'budget_min': price,
          'budget_max': price,
          'scheduled_at': scheduledAt?.toIso8601String(),
          'location': point,
          'status': 'draft',
          'broadcast_radius_km': 0,
        })
        .select()
        .single();
    return JobModel.fromJson(data);
  }

  /// Receiver of the current proposal accepts. RPC flips status to
  /// `matched` and binds the conversation to the job, atomically,
  /// under a server-side check that caller != proposed_by.
  Future<void> acceptChatProposedJob({
    required String jobId,
    required String conversationId,
  }) async {
    await _client.rpc('accept_chat_proposed_job', params: {
      'p_job_id': jobId,
      'p_conversation_id': conversationId,
    });
  }

  /// Receiver of the current proposal rejects. Job status → 'cancelled'.
  Future<void> rejectChatProposedJob({required String jobId}) async {
    await _client.rpc('reject_chat_proposed_job', params: {
      'p_job_id': jobId,
    });
  }

  /// Receiver amends the live proposal — updates the editable
  /// fields on the existing job row and flips `proposed_by` so the
  /// original sender becomes the new receiver. Caller then posts a
  /// fresh `job_proposal` message referencing the same job_id.
  Future<void> amendChatProposedJob({
    required String jobId,
    required String title,
    required String categoryId,
    double? price,
    DateTime? scheduledAt,
  }) async {
    await _client.rpc('amend_chat_proposed_job', params: {
      'p_job_id': jobId,
      'p_title': title,
      'p_category_id': categoryId,
      'p_price': price,
      'p_scheduled_at': scheduledAt?.toIso8601String(),
    });
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

  /// Replace the `photo_urls` array on a job row.
  Future<void> setJobPhotos(String jobId, List<String> urls) async {
    await _client
        .from(SupabaseConstants.jobs)
        .update({'photo_urls': urls})
        .eq('id', jobId);
  }

  // ── Bids — Read ──────────────────────────────────────────

  /// Fetch bids for a job (customer view — includes worker info).
  /// Goes through a SECURITY DEFINER RPC so worker public fields show
  /// up before the bid is matched (the counterparty RLS policy would
  /// otherwise hide bidder profiles).
  Future<List<BidModel>> getBidsForJob(String jobId) async {
    final data = await _client.rpc(
      'get_job_bids_with_workers',
      params: {'p_job_id': jobId},
    );
    return (data as List)
        .map<BidModel>(
            (row) => BidModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
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
