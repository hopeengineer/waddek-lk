import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Three-position trust-badge ring layered around a circular avatar.
///
///   * 0°   (top, 12 o'clock) — earned tier (`professional` / `supiri`).
///                              Hidden when `tier == 'waddek'`.
///   * 120° (bottom-right)    — verified (ID-verified through Shufti).
///   * 240° (bottom-left)     — Pro (active Pro Pass subscription).
///
/// Positions are measured clockwise from north so they hug the
/// avatar's circumference at the angles the design called for. The
/// widget assumes [child] is a circular avatar with the given radius —
/// it's the caller's responsibility to ensure that.
class TrustBadges extends StatelessWidget {
  const TrustBadges({
    super.key,
    required this.child,
    required this.avatarRadius,
    this.isVerified = false,
    this.isPro = false,
    this.tier = 'waddek',
    this.badgeRadius = 12,
  });

  final Widget child;
  final double avatarRadius;
  final bool isVerified;
  final bool isPro;
  final String tier;
  final double badgeRadius;

  /// Convert "clockwise-from-north" angle in degrees to Cartesian
  /// offset on the avatar's circumference. Flutter's y axis grows
  /// downward, so the +cos term gets negated for the top half.
  Offset _offsetForAngle(double degrees) {
    final theta = degrees * math.pi / 180.0;
    final r = avatarRadius - badgeRadius * 0.25;
    return Offset(
      math.sin(theta) * r,
      -math.cos(theta) * r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = (avatarRadius + badgeRadius) * 2;
    final tierBadge = _tierBadge();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          child,
          if (tierBadge != null) _positioned(0, tierBadge),
          if (isVerified) _positioned(120, _badge(Icons.verified,
              AppColors.neonGreen, 'Verified')),
          if (isPro) _positioned(240, _badge(Icons.workspace_premium,
              AppColors.neonPurple, 'Pro')),
        ],
      ),
    );
  }

  Widget _positioned(double degrees, Widget badge) {
    final offset = _offsetForAngle(degrees);
    return Positioned(
      // Stack alignment is center, so translate from there.
      left: avatarRadius + offset.dx + badgeRadius - badgeRadius,
      top: avatarRadius + offset.dy + badgeRadius - badgeRadius,
      child: badge,
    );
  }

  Widget? _tierBadge() {
    switch (tier) {
      case 'supiri':
        return _badge(Icons.workspace_premium, AppColors.neonAmber, 'Supiri');
      case 'professional':
        return _badge(Icons.military_tech, AppColors.neonCyan, 'Pro tier');
      default:
        return null;
    }
  }

  Widget _badge(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: badgeRadius * 2,
        height: badgeRadius * 2,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bgDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: badgeRadius * 1.1, color: Colors.white),
      ),
    );
  }
}
