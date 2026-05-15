import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_service.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_model.dart';

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

/// Fetch a specific worker's profile by id. Used by the worker detail
/// screen. autoDispose so each navigation away frees the row.
final workerProfileProvider = FutureProvider.autoDispose
    .family<ProfileModel?, String>((ref, workerId) async {
  return ref.read(profileRepositoryProvider).getProfile(workerId);
});

/// Worker's selected categories joined with category data.
final workerSkillsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, workerId) async {
  return ref.read(profileRepositoryProvider).getWorkerCategories(workerId);
});

/// Worker's portfolio images.
final workerPortfolioProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, workerId) async {
  return ref.read(profileRepositoryProvider).getPortfolioImages(workerId);
});

// ── Customer home discovery state ────────────────────────────────

/// Selected category id for the customer home discovery list.
/// Null means "All categories".
final selectedDiscoveryCategoryProvider =
    StateProvider<String?>((ref) => null);

/// Whether the customer home filters to online-only workers.
final discoveryOnlineOnlyProvider = StateProvider<bool>((ref) => false);

/// The customer's current device location, fetched once per session.
/// Null while pending or if permission was denied.
final customerLocationProvider =
    FutureProvider<({double lat, double lng})?>((ref) async {
  final pos = await LocationService().getCurrentPosition();
  if (pos == null) return null;
  return (lat: pos.latitude, lng: pos.longitude);
});

/// Discovery results — nearest workers, filtered by selected category
/// and online toggle. Returns empty list until location resolves.
final nearbyWorkersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final loc = await ref.watch(customerLocationProvider.future);
  if (loc == null) return [];
  final categoryId = ref.watch(selectedDiscoveryCategoryProvider);
  final onlineOnly = ref.watch(discoveryOnlineOnlyProvider);
  return ref.read(profileRepositoryProvider).findWorkersNearCustomer(
        lat: loc.lat,
        lng: loc.lng,
        categoryId: categoryId,
        onlineOnly: onlineOnly,
      );
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
