/// Hero Banner Widget
/// Featured channel display with parallax effect
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/channel.dart';

/// Hero banner for featured content
class HeroBanner extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPressed;
  final double height;

  const HeroBanner({
    super.key,
    required this.channel,
    this.onTap,
    this.onPlayPressed,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.large,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.surfaceElevated,
                  ],
                ),
              ),
            ),
            
            // Channel logo (if available)
            if (channel.logo != null)
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.15,
                  child: CachedNetworkImage(
                    imageUrl: channel.logo!,
                    fit: BoxFit.contain,
                    width: 200,
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),
            
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.surface.withValues(alpha: 0.95),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Category badge
                  if (channel.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        channel.category!.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Channel name
                  Text(
                    channel.name,
                    style: AppTypography.headlineLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Country
                  Text(
                    _getCountryName(channel.country),
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Play button
                  Row(
                    children: [
                      _PlayButton(onPressed: onPlayPressed ?? onTap),
                      const SizedBox(width: AppSpacing.sm),
                      _InfoButton(onPressed: onTap),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCountryName(String code) {
    // Simple country code to name mapping for common countries
    final countries = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'IN': 'India',
      'FR': 'France',
      'DE': 'Germany',
      'ES': 'Spain',
      'IT': 'Italy',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'JP': 'Japan',
      'KR': 'South Korea',
      'CN': 'China',
      'RU': 'Russia',
      'AU': 'Australia',
      'CA': 'Canada',
    };
    return countries[code.toUpperCase()] ?? code;
  }
}

/// Play button
class _PlayButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PlayButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: const Text('WATCH NOW'),
    );
  }
}

/// Info button
class _InfoButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _InfoButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.surfaceElevated3),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      icon: const Icon(Icons.info_outline_rounded, size: 20),
      label: const Text('INFO'),
    );
  }
}

/// Hero banner skeleton loader
class HeroBannerSkeleton extends StatelessWidget {
  final double height;

  const HeroBannerSkeleton({super.key, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.surfaceElevated2,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
