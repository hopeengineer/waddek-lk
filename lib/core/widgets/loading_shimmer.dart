import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Skeleton loading shimmer for list items while data loads.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.itemCount = 3,
    this.height = 100,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  final int itemCount;
  final double height;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.cardDark,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Container(
            height: height,
            margin: margin,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-line shimmer for text placeholders.
class TextShimmer extends StatelessWidget {
  const TextShimmer({super.key, this.width = 120, this.height = 16});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.cardDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
