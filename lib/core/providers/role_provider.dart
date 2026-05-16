import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Active role provider — determines whether the user is in customer or worker mode.
///
/// This is the single source of truth for the current role across the app.
/// It reads from the profile's `active_role` field and can be switched.
final activeRoleProvider =
    StateNotifierProvider<ActiveRoleNotifier, String>((ref) {
  final profile = ref.watch(currentProfileProvider).valueOrNull;
  final initialRole = profile?.activeRole ?? 'customer';
  return ActiveRoleNotifier(
    ref.read(profileRepositoryProvider),
    ref,
    initialRole,
  );
});

class ActiveRoleNotifier extends StateNotifier<String> {
  ActiveRoleNotifier(this._repo, this._ref, String initialRole)
      : super(initialRole);

  final ProfileRepository _repo;
  final Ref _ref;

  /// Whether the current role is worker.
  bool get isWorker => state == 'worker';

  /// Switch to the given role and persist to DB.
  ///
  /// We intentionally do NOT invalidate `currentProfileProvider` here.
  /// `activeRoleProvider` watches the profile to get its initial value,
  /// so invalidating mid-switch causes the notifier to be recreated
  /// with a stale `initialRole` while the profile reloads — which
  /// makes the role briefly flap back to 'customer', the router
  /// redirects back to /customer/home, and the user sees a flicker of
  /// the previous shell. The runtime source of truth is this
  /// notifier's state (already updated above); the DB column is
  /// updated below. The cached `profile.activeRole` field will catch
  /// up on the next natural profile refresh.
  Future<void> switchRole(String role) async {
    if (role == state) return;
    state = role;
    await _repo.updateActiveRole(role);
  }

  /// Toggle between customer and worker.
  Future<void> toggleRole() async {
    final newRole = state == 'customer' ? 'worker' : 'customer';
    await switchRole(newRole);
  }
}
