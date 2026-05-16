import 'dart:typed_data';

import 'package:waddek_lk/core/constants/supabase_constants.dart';
import 'package:waddek_lk/core/services/supabase_service.dart';
import 'package:waddek_lk/core/services/storage_service.dart';
import 'package:waddek_lk/features/profile/domain/profile_model.dart';

/// Data layer for profile operations.
class ProfileRepository {
  final _client = SupabaseService.client;

  // ── Read ──────────────────────────────────────────────────

  /// Fetch the current user's profile. Reads from `profiles` directly
  /// because the owner-only RLS policy lets the user see their own
  /// private fields (phone, email, NIC).
  Future<ProfileModel?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _client
        .from(SupabaseConstants.profiles)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Fetch a profile by user ID for cross-user reads (worker detail,
  /// search result tap, etc). Goes through the `public_profiles` view
  /// which is `security_invoker = off`, so it bypasses the profiles
  /// RLS while exposing only the safe columns.
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('public_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Fetch categories for a worker.
  Future<List<Map<String, dynamic>>> getWorkerCategories(
      String workerId) async {
    final data = await _client
        .from(SupabaseConstants.workerCategories)
        .select('*, categories(*)')
        .eq('worker_id', workerId);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch all active categories.
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final data = await _client
        .from(SupabaseConstants.categories)
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetch portfolio images for a worker.
  Future<List<Map<String, dynamic>>> getPortfolioImages(
      String workerId) async {
    final data = await _client
        .from(SupabaseConstants.portfolioImages)
        .select()
        .eq('worker_id', workerId)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Distance-sorted worker discovery for the customer home screen.
  /// Returns rows from the `find_workers_for_customer` RPC including
  /// each worker's distance from the given coordinates (meters).
  /// Workers without a stored location are excluded by the RPC.
  Future<List<Map<String, dynamic>>> findWorkersNearCustomer({
    required double lat,
    required double lng,
    String? categoryId,
    bool onlineOnly = false,
    int radiusMeters = 50000,
    int limit = 50,
  }) async {
    final data = await _client.rpc(
      'find_workers_for_customer',
      params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_category_id': categoryId,
        'p_online_only': onlineOnly,
        'p_radius_meters': radiusMeters,
        'p_limit': limit,
      },
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Search workers by name OR service/category name. If [categoryId]
  /// is supplied (e.g. from a chip), results are intersected with
  /// workers registered in that specific category.
  ///
  /// Match strategy when [query] is set:
  ///   1. Workers whose `full_name` ILIKE %query%.
  ///   2. Categories whose `name_en` / `name_si` / `name_ta` ILIKE
  ///      %query% → look up workers registered in those categories.
  ///   3. Union both sets, dedupe by id.
  ///   4. Intersect with the [categoryId] chip filter if any.
  Future<List<ProfileModel>> searchWorkers({
    required String query,
    String? categoryId,
  }) async {
    final hasQuery = query.isNotEmpty;
    final hasChip = categoryId != null && categoryId.isNotEmpty;
    if (!hasQuery && !hasChip) return [];

    // No text query — just return all workers in the chip's category.
    if (!hasQuery) {
      final rows = await _client
          .from(SupabaseConstants.workerCategories)
          .select('worker_id')
          .eq('category_id', categoryId!);
      final workerIds = rows
          .map<String>((r) => r['worker_id'] as String)
          .toList(growable: false);
      if (workerIds.isEmpty) return [];
      final data = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .or('role.eq.worker,active_role.eq.worker')
          .inFilter('id', workerIds)
          .order('average_rating', ascending: false)
          .limit(20);
      return data.map<ProfileModel>((p) => ProfileModel.fromJson(p)).toList();
    }

    // Text query path: name match ∪ service-name match.
    final results = <String, ProfileModel>{};

    // 1. Name match.
    final byName = await _client
        .from(SupabaseConstants.profiles)
        .select()
        .or('role.eq.worker,active_role.eq.worker')
        .ilike('full_name', '%$query%')
        .limit(20);
    for (final row in byName) {
      final m = ProfileModel.fromJson(row);
      results[m.id] = m;
    }

    // 2. Service/category-name match → workers registered in those.
    final cats = await _client
        .from(SupabaseConstants.categories)
        .select('id')
        .or('name_en.ilike.%$query%,name_si.ilike.%$query%,name_ta.ilike.%$query%');
    final catIds =
        cats.map<String>((c) => c['id'] as String).toList(growable: false);
    if (catIds.isNotEmpty) {
      final wcRows = await _client
          .from(SupabaseConstants.workerCategories)
          .select('worker_id')
          .inFilter('category_id', catIds);
      final workerIds = wcRows
          .map<String>((r) => r['worker_id'] as String)
          .toSet()
          .toList(growable: false);
      if (workerIds.isNotEmpty) {
        final byService = await _client
            .from(SupabaseConstants.profiles)
            .select()
            .or('role.eq.worker,active_role.eq.worker')
            .inFilter('id', workerIds)
            .limit(20);
        for (final row in byService) {
          final m = ProfileModel.fromJson(row);
          results[m.id] = m;
        }
      }
    }

    // 3. Tier match — query starts to match a known tier name in any
    //    supported language. Returns all workers on that tier.
    final matchedTier = _matchTier(query);
    if (matchedTier != null) {
      final byTier = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .or('role.eq.worker,active_role.eq.worker')
          .eq('tier', matchedTier)
          .limit(20);
      for (final row in byTier) {
        final m = ProfileModel.fromJson(row);
        results[m.id] = m;
      }
    }

    // 4. Intersect with chip filter if any.
    if (hasChip) {
      final chipRows = await _client
          .from(SupabaseConstants.workerCategories)
          .select('worker_id')
          .eq('category_id', categoryId!);
      final keep = chipRows
          .map<String>((r) => r['worker_id'] as String)
          .toSet();
      results.removeWhere((id, _) => !keep.contains(id));
    }

    // Sort by rating desc, cap.
    final list = results.values.toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return list.take(20).toList();
  }

  // ── Create / Update ──────────────────────────────────────

  /// Create a new profile after auth.
  Future<ProfileModel> createProfile({
    required String userId,
    required String phone,
    required String role,
    String? fullName,
  }) async {
    final data = await _client
        .from(SupabaseConstants.profiles)
        .insert({
          'id': userId,
          'phone': phone,
          'role': role,
          'full_name': fullName,
        })
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  /// Update profile fields.
  Future<ProfileModel> updateProfile({
    required String userId,
    Map<String, dynamic>? fields,
  }) async {
    final data = await _client
        .from(SupabaseConstants.profiles)
        .update(fields ?? {})
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  /// Update the user's active role (customer or worker).
  Future<void> updateActiveRole(String role) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from(SupabaseConstants.profiles)
        .update({'active_role': role})
        .eq('id', userId);
  }

  /// Update profile with location (PostGIS point).
  Future<ProfileModel> updateLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? addressText,
  }) async {
    final point = 'POINT($longitude $latitude)';
    final fields = <String, dynamic>{
      'location': point,
      // Mirror the same coordinates as plain doubles so PostgREST
      // returns them on every read — the geography column comes
      // back as opaque WKB hex which the Flutter model can't parse.
      'latitude': latitude,
      'longitude': longitude,
      if (addressText != null) 'address_text': addressText,
    };
    return updateProfile(userId: userId, fields: fields);
  }

  /// Upload avatar and update profile. Takes raw bytes so the path
  /// works on Flutter web (where `dart:io.File` throws _Namespace
  /// errors) and mobile alike — callers should hand over the result
  /// of `XFile.readAsBytes()` from image_picker.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
  }) async {
    final url = await StorageService.uploadAvatar(userId, bytes);
    await updateProfile(userId: userId, fields: {'avatar_url': url});
    return url;
  }

  /// Upload NIC photos and update profile.
  Future<void> uploadNicPhotos({
    required String userId,
    required Uint8List frontBytes,
    required Uint8List backBytes,
    required String nicNumber,
  }) async {
    final frontUrl = await StorageService.uploadNicPhoto(userId, 'front', frontBytes);
    final backUrl = await StorageService.uploadNicPhoto(userId, 'back', backBytes);
    await updateProfile(userId: userId, fields: {
      'nic_front_url': frontUrl,
      'nic_back_url': backUrl,
      'nic_number': nicNumber,
      'verification_status': 'pending',
    });
  }

  // ── Worker Categories ────────────────────────────────────

  /// Set worker's selected categories (replace all).
  Future<void> setWorkerCategories({
    required String workerId,
    required List<String> categoryIds,
  }) async {
    // Delete existing
    await _client
        .from(SupabaseConstants.workerCategories)
        .delete()
        .eq('worker_id', workerId);
    // Insert new
    if (categoryIds.isNotEmpty) {
      await _client.from(SupabaseConstants.workerCategories).insert(
            categoryIds
                .map((catId) => {
                      'worker_id': workerId,
                      'category_id': catId,
                    })
                .toList(),
          );
    }
  }

  // ── Portfolio ─────────────────────────────────────────────

  /// Upload a portfolio image.
  Future<String> addPortfolioImage({
    required String workerId,
    required Uint8List bytes,
    String? caption,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}';
    final url = await StorageService.uploadPortfolioImage(workerId, fileName, bytes);
    await _client.from(SupabaseConstants.portfolioImages).insert({
      'worker_id': workerId,
      'image_url': url,
      'caption': caption,
    });
    return url;
  }

  /// Delete a portfolio image row. RLS limits this to the row's owner.
  Future<void> deletePortfolioImage(String imageId) async {
    await _client
        .from(SupabaseConstants.portfolioImages)
        .delete()
        .eq('id', imageId);
  }
}

/// Returns the tier enum value that the search query is a prefix of,
/// across English, Sinhala and Tamil. Returns null when the query is
/// too short or doesn't match any tier prefix. Using `startsWith` keeps
/// the matching tight — typing "wad" matches `waddek`, but typing "p"
/// alone won't match all tiers (it has to start the tier word).
String? _matchTier(String query) {
  final q = query.trim().toLowerCase();
  if (q.length < 2) return null;

  // waddek (Sinhala slang for "expert") — brand-aware in SI / TA.
  const waddekAliases = ['waddek', 'වැඩ්ඩෙක්', 'வத்தெக்'];
  for (final a in waddekAliases) {
    if (a.toLowerCase().startsWith(q)) return 'waddek';
  }

  const professionalAliases = [
    'professional',
    'pro',
    'වෘත්තීය',
    'தொழில்முறை',
  ];
  for (final a in professionalAliases) {
    if (a.toLowerCase().startsWith(q)) return 'professional';
  }

  const supiriAliases = ['supiri', 'සුපිරි', 'சூப்பிரி'];
  for (final a in supiriAliases) {
    if (a.toLowerCase().startsWith(q)) return 'supiri';
  }

  return null;
}
