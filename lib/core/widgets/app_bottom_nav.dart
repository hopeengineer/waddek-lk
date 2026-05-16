import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/role_provider.dart';
import '../theme/app_colors.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../l10n/app_localizations.dart';
import 'app_global_top_bar.dart';

/// Bottom navigation shell — different tabs for customers vs workers.
/// Uses [activeRoleProvider] to determine the current role dynamically.
class AppBottomNav extends ConsumerStatefulWidget {
  const AppBottomNav({required this.child, required this.isWorker, super.key});
  final Widget child;
  final bool isWorker;

  @override
  ConsumerState<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends ConsumerState<AppBottomNav> {
  int _currentIndex = 0;

  List<_NavItem> _itemsFor(AppLocalizations l10n) {
    final isWorker = ref.read(activeRoleProvider) == 'worker';
    // Profile lives behind the top-right avatar on every page, so it
    // doesn't occupy a nav slot. Messages + Alerts take its place since
    // both roles need quick access to them during an active job.
    return isWorker
        ? [
            _NavItem(Icons.work, l10n.jobs, '/worker/jobs'),
            _NavItem(Icons.handshake, l10n.myBids, '/worker/bids'),
            _NavItem(Icons.account_balance_wallet, l10n.wallet, '/wallet'),
            _NavItem(Icons.chat_bubble, l10n.messages, '/worker/messages'),
            _NavItem(Icons.notifications, l10n.alerts, '/worker/notifications'),
          ]
        : [
            _NavItem(Icons.home, l10n.home, '/customer/home'),
            _NavItem(Icons.work, l10n.myJobs, '/customer/jobs'),
            _NavItem(Icons.chat_bubble, l10n.messages, '/customer/messages'),
            _NavItem(Icons.notifications, l10n.alerts, '/customer/notifications'),
          ];
  }

  @override
  Widget build(BuildContext context) {
    // Watch role to rebuild when it changes
    final activeRole = ref.watch(activeRoleProvider);
    final l10n = AppLocalizations.of(context)!;
    final items = _itemsFor(l10n);

    // Reset tab index when role changes to prevent stale selection
    if (_currentIndex >= items.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppGlobalTopBar(isWorker: activeRole == 'worker'),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isActive = i == _currentIndex;
                return _buildNavItem(item, isActive, () {
                  setState(() => _currentIndex = i);
                  context.go(item.route);
                });
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive, VoidCallback onTap) {
    // Show badge for Alerts tab — keyed off the route so localization
    // of the label doesn't break the comparison.
    Widget? badge;
    if (item.route.endsWith('/notifications')) {
      final unreadAsync = ref.watch(unreadCountProvider);
      final count = unreadAsync.valueOrNull ?? 0;
      if (count > 0) {
        badge = Positioned(
          right: 8,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.neonRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.neonCyan.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: isActive ? AppColors.neonCyan : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color:
                        isActive ? AppColors.neonCyan : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }
}

class _NavItem {
  _NavItem(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}
