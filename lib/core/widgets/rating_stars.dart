import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Star rating display widget.
///
/// Supports half-stars and interactive mode.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = AppColors.neonAmber,
    this.showValue = true,
    this.onRatingChanged,
  });

  final double rating;
  final double size;
  final Color color;
  final bool showValue;
  final ValueChanged<int>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          IconData icon;
          if (rating >= starNumber) {
            icon = Icons.star_rounded;
          } else if (rating >= starNumber - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }

          return GestureDetector(
            onTap: onRatingChanged != null
                ? () => onRatingChanged!(starNumber)
                : null,
            child: Icon(icon, size: size, color: color),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: size * 0.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
