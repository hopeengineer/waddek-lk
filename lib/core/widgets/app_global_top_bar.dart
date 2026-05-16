import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import 'role_switch_widget.dart';

/// Slim top app bar — role toggle pinned to the left corner, profile
/// badge pinned to the right. Hosted on the bottom-nav shell so it
/// appears on every shell-routed page.
///
/// Can also be passed to a standalone screen's `appBar:` slot via
/// `appBar: const PreferredSize(preferredSize: Size.fromHeight(48), child: AppGlobalTopBar(isWorker: ...))`.
class AppGlobalTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppGlobalTopBar({super.key, required this.isWorker});

  final bool isWorker;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final avatarUrl = profile?.avatarUrl;
    final profileRoute = isWorker ? '/worker/profile' : '/customer/profile';

    return Material(
      color: AppColors.bgCard,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const RoleSwitchWidget(),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go(profileRoute),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.neonCyan, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.bgSurface,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person,
                              color: AppColors.neonCyan, size: 18)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
