import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/role_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/role_switch_widget.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';

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

  List<_NavItem> get _items {
    final isWorker = ref.read(activeRoleProvider) == 'worker';
    return isWorker
        ? [
            _NavItem(Icons.work, 'Jobs', '/worker/jobs'),
            _NavItem(Icons.handshake, 'My Bids', '/worker/bids'),
            _NavItem(Icons.account_balance_wallet, 'Wallet', '/wallet'),
            _NavItem(Icons.person, 'Profile', '/worker/profile'),
          ]
        : [
            // Profile lives behind the top-right avatar on the home
            // screen, so it doesn't need a nav slot. Messages takes
            // that slot since it's a primary action customers reach
            // for during a job.
            _NavItem(Icons.home, 'Home', '/customer/home'),
            _NavItem(Icons.work, 'My Jobs', '/customer/jobs'),
            _NavItem(Icons.chat_bubble, 'Messages', '/customer/messages'),
            _NavItem(Icons.notifications, 'Alerts', '/customer/notifications'),
          ];
  }

  @override
  Widget build(BuildContext context) {
    // Watch role to rebuild when it changes
    final activeRole = ref.watch(activeRoleProvider);
    final items = _items;

    // Reset tab index when role changes to prevent stale selection
    if (_currentIndex >= items.length) {
      _currentIndex = 0;
    }

    return Scaffold(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Role switch strip
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activeRole == 'worker' ? '🔧 Worker Mode' : '🏠 Customer Mode',
                      style: TextStyle(
                        color: activeRole == 'worker'
                            ? AppColors.neonGreen
                            : AppColors.neonCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const RoleSwitchWidget(),
                  ],
                ),
              ),
              // Nav buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive, VoidCallback onTap) {
    // Show badge for Alerts tab
    Widget? badge;
    if (item.label == 'Alerts') {
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
