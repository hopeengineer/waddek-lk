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
    initialRole,
  );
});

class ActiveRoleNotifier extends StateNotifier<String> {
  ActiveRoleNotifier(this._repo, String initialRole) : super(initialRole);

  final ProfileRepository _repo;

  /// Whether the current role is worker.
  bool get isWorker => state == 'worker';

  /// Switch to the given role and persist to DB.
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
