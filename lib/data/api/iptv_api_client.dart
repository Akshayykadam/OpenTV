/// IPTV API Client
/// Fetches data from iptv-org.github.io/api
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';

/// Base URL for IPTV API
const String _baseUrl = 'https://iptv-org.github.io/api';

/// API endpoints
class IptvApiEndpoints {
  static const String channels = '/channels.json';
  static const String streams = '/streams.json';
  static const String categories = '/categories.json';
  static const String countries = '/countries.json';
  static const String logos = '/logos.json';
  static const String languages = '/languages.json';
}

/// Dio provider for dependency injection
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor in debug mode
  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) {
        // Only log in debug mode should be handled by caller or config, 
        // but explicit print is discouraged.
      },

    ),
  );

  return dio;
});

/// IPTV API client
class IptvApiClient {
  final Dio _dio;

  IptvApiClient(this._dio);

  /// Fetch all channel metadata
  Future<List<ChannelInfo>> fetchChannels() async {
    final response = await _dio.get<List<dynamic>>(IptvApiEndpoints.channels);
    return (response.data ?? [])
        .map((json) => ChannelInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all stream URLs
  Future<List<StreamInfo>> fetchStreams() async {
    final response = await _dio.get<List<dynamic>>(IptvApiEndpoints.streams);
    return (response.data ?? [])
        .map((json) => StreamInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all categories
  Future<List<ChannelCategory>> fetchCategories() async {
    final response = await _dio.get<List<dynamic>>(IptvApiEndpoints.categories);
    return (response.data ?? [])
        .map((json) => ChannelCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all countries
  Future<List<Country>> fetchCountries() async {
    final response = await _dio.get<List<dynamic>>(IptvApiEndpoints.countries);
    return (response.data ?? [])
        .map((json) => Country.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch logos
  Future<List<LogoInfo>> fetchLogos() async {
    final response = await _dio.get<List<dynamic>>(IptvApiEndpoints.logos);
    return (response.data ?? [])
        .map((json) => LogoInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Merge channel info with streams and logos to create full Channel objects
  Future<List<Channel>> fetchMergedChannels() async {
    // Fetch all data in parallel
    final results = await Future.wait([
      fetchChannels(),
      fetchStreams(),
      fetchLogos(),
    ]);

    final channels = results[0] as List<ChannelInfo>;
    final streams = results[1] as List<StreamInfo>;
    final logos = results[2] as List<LogoInfo>;

    // Create lookup maps - filter out null channels and urls
    final streamsByChannel = <String, List<StreamInfo>>{};
    for (final stream in streams) {
      // Skip streams with null channel or url
      if (stream.channel == null || stream.url == null) continue;
      streamsByChannel.putIfAbsent(stream.channel!, () => []).add(stream);
    }

    final logosByChannel = <String, LogoInfo>{};
    for (final logo in logos) {
      // Skip logos with null channel
      if (logo.channel == null) continue;
      logosByChannel.putIfAbsent(logo.channel!, () => logo);
    }

    // Merge data
    final mergedChannels = <Channel>[];
    for (final info in channels) {
      final channelStreams = streamsByChannel[info.id];
      if (channelStreams == null || channelStreams.isEmpty) continue;

      // Skip closed/replaced channels
      if (info.closed != null || info.replacedBy != null) continue;
      
      // Skip channels with empty country
      if (info.country.isEmpty) continue;

      final logo = logosByChannel[info.id];
      final stream = channelStreams.first;

      mergedChannels.add(
        Channel(
          id: info.id,
          name: info.name,
          logo: logo?.url,
          country: info.country,
          category: info.categories.isNotEmpty ? info.categories.first : null,
          streamUrl: stream.url!,  // Safe - we filtered nulls above
          quality: _parseQuality(stream.quality),
          isNsfw: info.isNsfw,
          altNames: info.altNames,
          network: info.network,
          website: info.website,
          referrer: stream.referrer,
          userAgent: stream.userAgent,
        ),
      );
    }

    return mergedChannels;
  }

  StreamQuality _parseQuality(String? quality) {
    if (quality == null) return StreamQuality.unknown;
    switch (quality.toLowerCase()) {
      case '4k':
      case '2160p':
        return StreamQuality.uhd4k;
      case '1080p':
        return StreamQuality.hd1080;
      case '720p':
        return StreamQuality.hd720;
      case '480p':
        return StreamQuality.sd480;
      case '360p':
        return StreamQuality.low360;
      default:
        return StreamQuality.unknown;
    }
  }
}

/// Provider for IPTV API client
final iptvApiClientProvider = Provider<IptvApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return IptvApiClient(dio);
});
