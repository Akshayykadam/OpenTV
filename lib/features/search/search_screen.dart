/// Search Screen
/// Instant search with filters
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/channel.dart';
import '../../data/repositories/channel_repository.dart';
import '../browse/widgets/channel_card.dart';
import '../player/player_screen.dart';

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results provider
final searchResultsProvider = FutureProvider<List<Channel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.searchChannels(query);
});

/// Search screen with instant results
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTypography.titleMedium,
          decoration: InputDecoration(
            hintText: 'Search channels...',
            hintStyle: AppTypography.titleMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
              icon: const Icon(Icons.clear_rounded),
            ),
        ],
      ),
      body: query.isEmpty
          ? _buildEmptyState()
          : resultsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Error searching channels',
                  style: AppTypography.bodyMedium,
                ),
              ),
              data: (channels) => channels.isEmpty
                  ? _buildNoResultsState(query)
                  : _buildResultsList(channels),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Search for channels',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find your favorite TV channels by name',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No channels found',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No results for "$query"',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Channel> channels) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ChannelCard(
          channel: channel,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerScreen(channel: channel),
              ),
            ).then((_) {
               // Force portrait mode when returning
               SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
               SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            });
          },
        );
      },
    );
  }
}
