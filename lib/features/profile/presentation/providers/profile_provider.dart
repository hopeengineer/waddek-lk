import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import '../domain/profile_model.dart';

/// Provides [ProfileRepository] singleton.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provides the current user's profile.
final currentProfileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  return ProfileNotifier(ref.read(profileRepositoryProvider));
});

/// Provides all active categories.
final categoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(profileRepositoryProvider).getAllCategories();
});

/// Profile state management.
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  ProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  final ProfileRepository _repo;

  /// Load current user's profile.
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.getCurrentProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create profile after auth (role selection).
  Future<ProfileModel> createProfile({
    required String userId,
    required String phone,
    required String role,
    String? fullName,
  }) async {
    final profile = await _repo.createProfile(
      userId: userId,
      phone: phone,
      role: role,
      fullName: fullName,
    );
    state = AsyncValue.data(profile);
    return profile;
  }

  /// Update profile fields.
  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final updated =
          await _repo.updateProfile(userId: current.id, fields: fields);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update location.
  Future<void> updateLocation({
    required double lat,
    required double lng,
    String? address,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = await _repo.updateLocation(
      userId: current.id,
      latitude: lat,
      longitude: lng,
      addressText: address,
    );
    state = AsyncValue.data(updated);
  }

  /// Upload avatar.
  Future<String> uploadAvatar(String filePath) async {
    final current = state.valueOrNull;
    if (current == null) throw Exception('No profile loaded');
    final url =
        await _repo.uploadAvatar(userId: current.id, filePath: filePath);
    await loadProfile(); // refresh
    return url;
  }

  /// Upload NIC photos.
  Future<void> uploadNic({
    required String frontPath,
    required String backPath,
    required String nicNumber,
  }) async {
    final current = state.valueOrNull;
    if (current == null) throw Exception('No profile loaded');
    await _repo.uploadNicPhotos(
      userId: current.id,
      frontPath: frontPath,
      backPath: backPath,
      nicNumber: nicNumber,
    );
    await loadProfile();
  }

  /// Set worker categories.
  Future<void> setCategories(List<String> categoryIds) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repo.setWorkerCategories(
      workerId: current.id,
      categoryIds: categoryIds,
    );
  }
}
