import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';
import '../domain/profile_model.dart';

/// Data layer for profile operations.
class ProfileRepository {
  final _client = SupabaseService.client;
  final _storage = StorageService();

  // ── Read ──────────────────────────────────────────────────

  /// Fetch the current user's profile.
  Future<ProfileModel?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// Fetch a profile by user ID.
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from(SupabaseConstants.profiles)
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
      if (addressText != null) 'address_text': addressText,
    };
    return updateProfile(userId: userId, fields: fields);
  }

  /// Upload avatar and update profile.
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    final url = await _storage.uploadFile(
      bucket: SupabaseConstants.avatarsBucket,
      path: '$userId/avatar.jpg',
      filePath: filePath,
    );
    await updateProfile(userId: userId, fields: {'avatar_url': url});
    return url;
  }

  /// Upload NIC photos and update profile.
  Future<void> uploadNicPhotos({
    required String userId,
    required String frontPath,
    required String backPath,
    required String nicNumber,
  }) async {
    final frontUrl = await _storage.uploadFile(
      bucket: SupabaseConstants.nicPhotosBucket,
      path: '$userId/front.jpg',
      filePath: frontPath,
    );
    final backUrl = await _storage.uploadFile(
      bucket: SupabaseConstants.nicPhotosBucket,
      path: '$userId/back.jpg',
      filePath: backPath,
    );
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
    required String filePath,
    String? caption,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await _storage.uploadFile(
      bucket: SupabaseConstants.portfolioBucket,
      path: '$workerId/$fileName',
      filePath: filePath,
    );
    await _client.from(SupabaseConstants.portfolioImages).insert({
      'worker_id': workerId,
      'image_url': url,
      'caption': caption,
    });
    return url;
  }
}
