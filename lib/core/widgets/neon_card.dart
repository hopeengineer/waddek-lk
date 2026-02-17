import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A card with a subtle neon glow border effect.
///
/// Used for job cards, bid cards, transaction items, etc.
class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor = AppColors.neonCyan,
    this.glowIntensity = 0.15,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.borderRadius = 16,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color glowColor;
  final double glowIntensity;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withOpacity(glowIntensity),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
