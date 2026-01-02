/// Horizontal Channel Carousel
/// Smooth horizontal scrolling carousel for channel categories
library;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../data/models/channel.dart';
import '../../browse/widgets/channel_card.dart';

/// Horizontal carousel for channel categories
class ChannelCarousel extends StatelessWidget {
  final String title;
  final List<Channel> channels;
  final Function(Channel)? onChannelTap;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;
  final double cardWidth;
  final double cardHeight;

  const ChannelCarousel({
    super.key,
    required this.title,
    required this.channels,
    this.onChannelTap,
    this.onSeeAll,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.cardWidth = 160,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmall,
              ),
              if (channels.length > 5)
                TextButton(
    onPressed: onSeeAll,
                  child: Text(
                    'See All',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Horizontal scroll
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < channels.length - 1 ? AppSpacing.sm : 0,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: ChannelCard(
                    channel: channel,
                    onTap: () => onChannelTap?.call(channel),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Loading state carousel with skeleton cards
class ChannelCarouselSkeleton extends StatelessWidget {
  final String title;
  final int itemCount;
  final EdgeInsets padding;
  final double cardWidth;
  final double cardHeight;

  const ChannelCarouselSkeleton({
    super.key,
    required this.title,
    this.itemCount = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.cardWidth = 160,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            title,
            style: AppTypography.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: padding,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < itemCount - 1 ? AppSpacing.sm : 0,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: const ChannelCardSkeleton(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
