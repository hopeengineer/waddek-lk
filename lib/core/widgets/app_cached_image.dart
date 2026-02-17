import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../theme/app_colors.dart';

/// Cached network image with consistent placeholder and error handling.
/// Use this everywhere instead of direct [Image.network].
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppColors.bgSurface,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neonCyan,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.bgSurface,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Circle avatar with caching.
class AppCachedAvatar extends StatelessWidget {
  const AppCachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackText,
  });

  final String? imageUrl;
  final double radius;
  final String? fallbackText;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.neonCyan.withOpacity(0.15),
        child: Text(
          fallbackText?.isNotEmpty == true
              ? fallbackText![0].toUpperCase()
              : '?',
          style: TextStyle(
            color: AppColors.neonCyan,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.bgSurface,
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.bgSurface,
        child: const Icon(Icons.person, color: AppColors.textSecondary),
      ),
    );
  }
}
