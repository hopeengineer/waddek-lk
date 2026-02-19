import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/role_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/role_switch_widget.dart';

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
            _NavItem(Icons.home, 'Home', '/customer/home'),
            _NavItem(Icons.work, 'My Jobs', '/customer/jobs'),
            _NavItem(Icons.notifications, 'Alerts', '/notifications'),
            _NavItem(Icons.person, 'Profile', '/customer/profile'),
          ];
  }

  @override
  Widget build(BuildContext context) {
    // Watch role to rebuild when it changes
    final activeRole = ref.watch(activeRoleProvider);
    final items = _items;

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
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
    );
  }
}

class _NavItem {
  _NavItem(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}
