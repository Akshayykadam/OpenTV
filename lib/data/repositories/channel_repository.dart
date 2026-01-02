/// Channel Repository
/// Manages channel data caching and provides async channel access
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/iptv_api_client.dart';
import '../models/channel.dart';

/// Cache key for channels box
const String _channelsBoxName = 'channels_cache';
const String _lastFetchKey = 'last_fetch_timestamp';
const Duration _cacheValidDuration = Duration(hours: 6);

/// Channel repository for data access
class ChannelRepository {
  final IptvApiClient _apiClient;
  Box<dynamic>? _cacheBox;
  List<Channel>? _channelsCache;

  ChannelRepository(this._apiClient);

  /// Initialize the repository
  Future<void> init() async {
    if (_cacheBox != null) return; // Already initialized
    _cacheBox = await Hive.openBox(_channelsBoxName);
  }

  /// Get all channels (from cache or API)
  Future<List<Channel>> getChannels({bool forceRefresh = false}) async {
    // Return memory cache if available
    if (_channelsCache != null && !forceRefresh) {
      return _channelsCache!;
    }

    // Check disk cache freshness
    if (!forceRefresh && _isCacheValid()) {
      final cached = _loadFromCache();
      if (cached != null) {
        _channelsCache = cached;
        return cached;
      }
    }

    // Fetch from API
    try {
      final channels = await _apiClient.fetchMergedChannels();
      await _saveToCache(channels);
      _channelsCache = channels;
      return channels;
    } catch (e) {
      // Fall back to cache on error
      final cached = _loadFromCache();
      if (cached != null) {
        _channelsCache = cached;
        return cached;
      }
      rethrow;
    }
  }

  /// Get channels filtered by country
  Future<List<Channel>> getChannelsByCountry(String countryCode) async {
    final channels = await getChannels();
    return channels
        .where((c) => c.country.toUpperCase() == countryCode.toUpperCase())
        .toList();
  }

  /// Get channels filtered by category
  Future<List<Channel>> getChannelsByCategory(String category) async {
    final channels = await getChannels();
    return channels
        .where((c) =>
            c.category?.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Search channels by name
  Future<List<Channel>> searchChannels(String query) async {
    if (query.isEmpty) return [];
    
    final channels = await getChannels();
    final lowerQuery = query.toLowerCase();
    
    return channels.where((c) {
      if (c.name.toLowerCase().contains(lowerQuery)) return true;
      if (c.altNames?.any((n) => n.toLowerCase().contains(lowerQuery)) ?? false) {
        return true;
      }
      return false;
    }).toList();
  }

  /// Get a single channel by ID
  Future<Channel?> getChannelById(String id) async {
    final channels = await getChannels();
    try {
      return channels.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get unique countries from channels with rich data
  Future<List<Country>> getAvailableCountries() async {
    final channels = await getChannels();
    final usedCodes = channels.map((c) => c.country.toUpperCase()).toSet();
    
    try {
      final allCountries = await _apiClient.fetchCountries();
      
      // Filter to only included countries
      return allCountries
          .where((c) => usedCodes.contains(c.code.toUpperCase()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      // Fallback: Return dummy objects with codes if API fails
      return usedCodes.map((code) => Country(
        name: code,
        code: code,
        flag: '', // Emoji flag could be generated from code but we'll leave empty for now
      )).toList()..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  /// Get unique categories from channels
  Future<List<String>> getAvailableCategories() async {
    final channels = await getChannels();
    return channels
        .map((c) => c.category)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();
  }

  bool _isCacheValid() {
    final lastFetch = _cacheBox?.get(_lastFetchKey) as int?;
    if (lastFetch == null) return false;
    
    final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
    return DateTime.now().difference(lastFetchTime) < _cacheValidDuration;
  }

  List<Channel>? _loadFromCache() {
    try {
      final cached = _cacheBox?.get('channels') as List<dynamic>?;
      if (cached == null) return null;
      
      return cached
          .map((json) => Channel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToCache(List<Channel> channels) async {
    await _cacheBox?.put(
      'channels',
      channels.map((c) => c.toJson()).toList(),
    );
    await _cacheBox?.put(
      _lastFetchKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _cacheBox?.clear();
    _channelsCache = null;
  }
}

/// Provider for channel repository
final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  final apiClient = ref.watch(iptvApiClientProvider);
  return ChannelRepository(apiClient);
});

/// Provider for all channels (async)
final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.getChannels();
});

/// Provider for channels by country
final channelsByCountryProvider =
    FutureProvider.family<List<Channel>, String>((ref, countryCode) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.getChannelsByCountry(countryCode);
});

/// Provider for channels by category
final channelsByCategoryProvider =
    FutureProvider.family<List<Channel>, String>((ref, category) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.getChannelsByCategory(category);
});

/// Provider for channel search 
final channelSearchProvider =
    FutureProvider.family<List<Channel>, String>((ref, query) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.searchChannels(query);
});

/// Provider for available countries
final availableCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.getAvailableCountries();
});

/// Provider for available categories  
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(channelRepositoryProvider);
  await repository.init();
  return repository.getAvailableCategories();
});
