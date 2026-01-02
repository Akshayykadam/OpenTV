/// Home Screen
/// Content-forward discovery experience
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/channel.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../browse/category_screen.dart';
import '../search/search_screen.dart';
import '../player/player_screen.dart';
import 'widgets/channel_carousel.dart';
import 'widgets/country_search_sheet.dart';
import 'providers/selected_country_provider.dart';

/// Home screen - main discovery page
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: channelsAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
          data: (channels) => _buildContent(channels),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        // App bar
        _buildAppBar(),
        
        // Loading skeletons
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(height: AppSpacing.lg),
              const ChannelCarouselSkeleton(title: 'Trending'),
              const SizedBox(height: AppSpacing.lg),
              const ChannelCarouselSkeleton(title: 'News'),
              const SizedBox(height: AppSpacing.lg),
              const ChannelCarouselSkeleton(title: 'Sports'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    // Log error for debugging
    debugPrint('OpenTV ERROR: $error');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load channels',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              // Show actual error for debugging
              error.toString(),
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(channelsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Channel> channels) {
    // Get selected country
    final selectedCountry = ref.watch(selectedCountryProvider);
    
    // Filter channels by country
    final filteredChannels = selectedCountry == null 
        ? channels 
        : channels.where((c) => c.country.toUpperCase() == selectedCountry).toList();

    // Group channels by category
    final trendingChannels = filteredChannels.take(20).toList();
    final newsChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'news').take(20).toList();
    final sportsChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'sports').take(20).toList();
    final entertainmentChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'entertainment').take(20).toList();
    final moviesChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'movies').take(20).toList();
    final musicChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'music').take(20).toList();
    final kidsChannels = filteredChannels.where((c) => 
        c.category?.toLowerCase() == 'kids').take(20).toList();

    // Get recently watched
    final recentIds = ref.watch(recentlyWatchedIdsProvider);
    final recentChannels = recentIds
        .map((id) => channels.where((c) => c.id == id).firstOrNull)
        .whereType<Channel>()
        .take(10)
        .toList();

    // Get favorites
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favoriteChannels = channels
        .where((c) => favoriteIds.contains(c.id))
        .take(20)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(channelsProvider);
      },
      child: CustomScrollView(
        slivers: [
          // App bar
          _buildAppBar(),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const SizedBox(height: AppSpacing.md),
                
                // Country Selector
                _buildCountrySelector(),
                const SizedBox(height: AppSpacing.md),
                
                // Continue Watching / Recently watched
                if (recentChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Continue Watching',
                    channels: recentChannels,
                    onChannelTap: _playChannel,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Favorites
                if (favoriteChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Your Favorites',
                    channels: favoriteChannels,
                    onChannelTap: _playChannel,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Trending
                if (trendingChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Trending',
                    channels: trendingChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Trending', filteredChannels),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // News
                if (newsChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'News',
                    channels: newsChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('News', filteredChannels.where((c) => c.category?.toLowerCase() == 'news').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Sports
                if (sportsChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Sports',
                    channels: sportsChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Sports', filteredChannels.where((c) => c.category?.toLowerCase() == 'sports').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Entertainment
                if (entertainmentChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Entertainment',
                    channels: entertainmentChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Entertainment', filteredChannels.where((c) => c.category?.toLowerCase() == 'entertainment').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Movies
                if (moviesChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Movies',
                    channels: moviesChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Movies', filteredChannels.where((c) => c.category?.toLowerCase() == 'movies').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Music
                if (musicChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Music',
                    channels: musicChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Music', filteredChannels.where((c) => c.category?.toLowerCase() == 'music').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Kids
                if (kidsChannels.isNotEmpty) ...[
                  ChannelCarousel(
                    title: 'Kids',
                    channels: kidsChannels,
                    onChannelTap: _playChannel,
                    onSeeAll: () => _openCategory('Kids', filteredChannels.where((c) => c.category?.toLowerCase() == 'kids').toList()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Bottom padding
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      title: Text(
        'OpenTV',
        style: AppTypography.headlineMedium.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  void _playChannel(Channel channel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(channel: channel),
      ),
    ).then((_) async {
      // Force orientation reset when returning, just in case
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  void _openCategory(String title, List<Channel> channels) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryScreen(title: title, channels: channels),
      ),
    );
  }

  Widget _buildCountrySelector() {
    final availableCountriesAsync = ref.watch(availableCountriesProvider);
    final selectedCountryCode = ref.watch(selectedCountryProvider);

    return availableCountriesAsync.when(
      data: (countries) {
        if (countries.isEmpty) return const SizedBox.shrink();

        Country? selectedCountry;
        if (selectedCountryCode != null) {
          try {
            selectedCountry = countries.firstWhere(
              (c) => c.code.toUpperCase() == selectedCountryCode,
            );
          } catch (_) {
            selectedCountry = Country(
              name: selectedCountryCode, 
              code: selectedCountryCode, 
              flag: '🌍',
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CountrySearchSheet(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                    width: 24, height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                   ),
                   const SizedBox(width: AppSpacing.sm),
                   Text(
                     selectedCountry?.name ?? 'All Countries',
                     style: AppTypography.labelLarge.copyWith(
                       color: AppColors.textPrimary,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   const SizedBox(width: AppSpacing.sm),
                   Icon(
                     Icons.keyboard_arrow_down_rounded,
                     size: 16,
                     color: AppColors.textTertiary,
                   ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
