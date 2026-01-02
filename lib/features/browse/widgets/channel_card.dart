/// Channel Card Widget
/// Modern, minimal, and immersive channel card
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../data/models/channel.dart';

/// Channel card for grid/list displays
class ChannelCard extends StatefulWidget {
  final Channel channel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFocused;
  final bool showCategory;

  const ChannelCard({
    super.key,
    required this.channel,
    this.onTap,
    this.onLongPress,
    this.isFocused = false,
    this.showCategory = true,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isFocused || _isHovered;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.defaultCurve,
          transform: Matrix4.diagonal3Values(isActive ? 1.05 : 1.0, isActive ? 1.05 : 1.0, 1.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.cardRadius,
            border: isActive
                ? Border.all(color: AppColors.focusRing, width: 2)
                : Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
            boxShadow: isActive ? AppShadows.large : AppShadows.small,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Logo (Centered)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg), // More breathing room
                  child: _buildLogo(),
                ),
              ),

              // Gradient Overlay (Bottom)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80, // Covers bottom part
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),

              // Content (Text overlay)
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category & Country Pill
                    if (widget.showCategory)
                      Row(
                        children: [
                          if (widget.channel.category != null)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: AppColors.categoryColors[widget.channel.category!.toLowerCase()] ?? AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            _getCountryFlag(widget.channel.country),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      widget.channel.name,
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Quality Badge (Top Right)
              if (widget.channel.quality.displayName != null)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      widget.channel.quality.displayName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (widget.channel.logo == null) {
      return Center(
        child: Text(
          widget.channel.name.substring(0, 2).toUpperCase(),
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.channel.logo!,
      fit: BoxFit.contain,
      memCacheWidth: 200, // Optimize memory
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surfaceElevated2),
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 32),
      ),
    );
  }

  String _getCountryFlag(String countryCode) {
    if (countryCode.length != 2) return '';
    final code = countryCode.toUpperCase();
    final first = code.codeUnitAt(0) - 65 + 127462;
    final second = code.codeUnitAt(1) - 65 + 127462;
    return String.fromCharCodes([first, second]);
  }
}

/// Skeleton loader for channel cards
class ChannelCardSkeleton extends StatelessWidget {
  const ChannelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.surfaceElevated2,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.cardRadius,
        ),
      ),
    );
  }
}
