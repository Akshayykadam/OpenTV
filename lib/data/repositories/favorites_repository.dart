/// Favorites Repository
/// Local storage for favorite channels and watch history
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';


/// Watch history entry
class WatchHistoryEntry {
  final String channelId;
  final DateTime watchedAt;
  final Duration watchDuration;

  const WatchHistoryEntry({
    required this.channelId,
    required this.watchedAt,
    required this.watchDuration,
  });

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'watchedAt': watchedAt.toIso8601String(),
        'watchDuration': watchDuration.inSeconds,
      };

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WatchHistoryEntry(
      channelId: json['channelId'] as String,
      watchedAt: DateTime.parse(json['watchedAt'] as String),
      watchDuration: Duration(seconds: json['watchDuration'] as int),
    );
  }
}

/// Favorites repository with local persistence
class FavoritesRepository {
  static const String _favoritesBoxName = 'favorites';
  static const String _historyBoxName = 'watch_history';
  static const String _lastChannelKey = 'last_channel';
  static const int _maxHistoryEntries = 100;

  Box<dynamic>? _favoritesBox;
  Box<dynamic>? _historyBox;

  /// Initialize the repository
  Future<void> init() async {
    await Hive.initFlutter();
    _favoritesBox = await Hive.openBox(_favoritesBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);
  }

  /// Get favorite channel IDs
  Set<String> getFavoriteIds() {
    final list = _favoritesBox?.get('favorites') as List<dynamic>?;
    return list?.cast<String>().toSet() ?? {};
  }

  /// Check if channel is favorite
  bool isFavorite(String channelId) {
    return getFavoriteIds().contains(channelId);
  }

  /// Add channel to favorites
  Future<void> addFavorite(String channelId) async {
    final favorites = getFavoriteIds();
    favorites.add(channelId);
    await _favoritesBox?.put('favorites', favorites.toList());
  }

  /// Remove channel from favorites
  Future<void> removeFavorite(String channelId) async {
    final favorites = getFavoriteIds();
    favorites.remove(channelId);
    await _favoritesBox?.put('favorites', favorites.toList());
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String channelId) async {
    if (isFavorite(channelId)) {
      await removeFavorite(channelId);
      return false;
    } else {
      await addFavorite(channelId);
      return true;
    }
  }

  /// Get watch history
  List<WatchHistoryEntry> getWatchHistory() {
    final list = _historyBox?.get('history') as List<dynamic>?;
    if (list == null) return [];
    
    return list
        .map((json) => WatchHistoryEntry.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
  }

  /// Get recently watched channel IDs (ordered by recency)
  List<String> getRecentlyWatchedIds({int limit = 20}) {
    final history = getWatchHistory();
    final seen = <String>{};
    final result = <String>[];
    
    for (final entry in history) {
      if (!seen.contains(entry.channelId)) {
        seen.add(entry.channelId);
        result.add(entry.channelId);
        if (result.length >= limit) break;
      }
    }
    
    return result;
  }

  /// Add watch history entry
  Future<void> addWatchHistory(String channelId, Duration watchDuration) async {
    final history = getWatchHistory();
    
    history.add(WatchHistoryEntry(
      channelId: channelId,
      watchedAt: DateTime.now(),
      watchDuration: watchDuration,
    ));
    
    // Keep only recent entries
    if (history.length > _maxHistoryEntries) {
      history.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      history.removeRange(_maxHistoryEntries, history.length);
    }
    
    await _historyBox?.put(
      'history',
      history.map((e) => e.toJson()).toList(),
    );
  }

  /// Set last watched channel
  Future<void> setLastChannel(String channelId) async {
    await _historyBox?.put(_lastChannelKey, channelId);
  }

  /// Get last watched channel ID
  String? getLastChannelId() {
    return _historyBox?.get(_lastChannelKey) as String?;
  }

  /// Get most watched channels (by total watch time)
  Map<String, Duration> getMostWatched({int limit = 10}) {
    final history = getWatchHistory();
    final watchTimes = <String, Duration>{};
    
    for (final entry in history) {
      watchTimes.update(
        entry.channelId,
        (current) => current + entry.watchDuration,
        ifAbsent: () => entry.watchDuration,
      );
    }
    
    final sorted = watchTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(limit));
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _historyBox?.delete('history');
    await _historyBox?.delete(_lastChannelKey);
  }

  /// Clear favorites
  Future<void> clearFavorites() async {
    await _favoritesBox?.delete('favorites');
  }
}

/// Provider for favorites repository
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Provider for favorite channel IDs
final favoriteIdsProvider = StateNotifierProvider<FavoriteIdsNotifier, Set<String>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoriteIdsNotifier(repository);
});

/// Notifier for favorite IDs
class FavoriteIdsNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repository;

  FavoriteIdsNotifier(this._repository) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _repository.init();
    state = _repository.getFavoriteIds();
  }

  Future<void> toggle(String channelId) async {
    final isFavorite = await _repository.toggleFavorite(channelId);
    if (isFavorite) {
      state = {...state, channelId};
    } else {
      state = {...state}..remove(channelId);
    }
  }

  bool isFavorite(String channelId) => state.contains(channelId);
}

/// Provider for recently watched IDs
final recentlyWatchedIdsProvider = Provider<List<String>>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getRecentlyWatchedIds();
});

/// Provider for last channel ID
final lastChannelIdProvider = Provider<String?>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getLastChannelId();
});
