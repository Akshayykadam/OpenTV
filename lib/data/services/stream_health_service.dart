/// Stream Health Service
/// Background health checker for streams
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../repositories/channel_repository.dart';

/// Health check result
class HealthCheckResult {
  final String channelId;
  final HealthStatus status;
  final int? responseTimeMs;
  final String? error;
  final DateTime checkedAt;

  const HealthCheckResult({
    required this.channelId,
    required this.status,
    this.responseTimeMs,
    this.error,
    required this.checkedAt,
  });
}

/// Stream health service - checks if streams are alive
class StreamHealthService {
  final Dio _dio;
  final Map<String, HealthCheckResult> _healthCache = {};
  Timer? _backgroundTimer;
  
  static const Duration _checkInterval = Duration(minutes: 30);
  static const Duration _timeout = Duration(seconds: 5);

  StreamHealthService(this._dio);

  /// Get cached health status for a channel
  HealthStatus getHealthStatus(String channelId) {
    return _healthCache[channelId]?.status ?? HealthStatus.unknown;
  }

  /// Check health of a single stream
  Future<HealthCheckResult> checkStreamHealth(Channel channel) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _dio.head(
        channel.streamUrl,
        options: Options(
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
          headers: {
            if (channel.referrer != null) 'Referer': channel.referrer,
            if (channel.userAgent != null) 'User-Agent': channel.userAgent,
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      stopwatch.stop();
      
      HealthStatus status;
      if (response.statusCode == 200 || response.statusCode == 206) {
        status = HealthStatus.online;
      } else if (response.statusCode == 403 || response.statusCode == 451) {
        // Geo-blocked or unavailable in region
        status = HealthStatus.offline;
      } else if (response.statusCode == 429) {
        // Rate limited, assume online
        status = HealthStatus.degraded;
      } else {
        status = HealthStatus.offline;
      }
      
      final result = HealthCheckResult(
        channelId: channel.id,
        status: status,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        checkedAt: DateTime.now(),
      );
      
      _healthCache[channel.id] = result;
      return result;
    } on DioException catch (e) {
      stopwatch.stop();
      
      HealthStatus status;
      String error;
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          status = HealthStatus.degraded;
          error = 'Connection timeout';
          break;
        case DioExceptionType.connectionError:
          status = HealthStatus.offline;
          error = 'Connection error';
          break;
        default:
          status = HealthStatus.offline;
          error = e.message ?? 'Unknown error';
      }
      
      final result = HealthCheckResult(
        channelId: channel.id,
        status: status,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        error: error,
        checkedAt: DateTime.now(),
      );
      
      _healthCache[channel.id] = result;
      return result;
    }
  }

  /// Check health of multiple channels in parallel
  Future<List<HealthCheckResult>> checkBatchHealth(
    List<Channel> channels, {
    int concurrency = 5,
  }) async {
    final results = <HealthCheckResult>[];
    
    for (var i = 0; i < channels.length; i += concurrency) {
      final batch = channels.skip(i).take(concurrency);
      final batchResults = await Future.wait(
        batch.map((c) => checkStreamHealth(c)),
      );
      results.addAll(batchResults);
    }
    
    return results;
  }

  /// Start background health checking
  void startBackgroundChecking(List<Channel> channels) {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(_checkInterval, (_) {
      // Check a random sample of channels
      final sample = (channels.toList()..shuffle()).take(50).toList();
      checkBatchHealth(sample);
    });
  }

  /// Stop background health checking
  void stopBackgroundChecking() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  /// Filter channels to only healthy ones
  List<Channel> filterHealthyChannels(List<Channel> channels) {
    return channels.where((c) {
      final status = getHealthStatus(c.id);
      return status == HealthStatus.online || 
             status == HealthStatus.unknown ||
             status == HealthStatus.degraded;
    }).toList();
  }

  /// Get all cached health results
  Map<String, HealthCheckResult> get healthCache => Map.unmodifiable(_healthCache);

  /// Clear health cache
  void clearCache() {
    _healthCache.clear();
  }

  /// Dispose resources
  void dispose() {
    stopBackgroundChecking();
    _healthCache.clear();
  }
}

/// Provider for stream health service
final streamHealthServiceProvider = Provider<StreamHealthService>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  
  final service = StreamHealthService(dio);
  ref.onDispose(() => service.dispose());
  
  return service;
});

/// Provider for getting health-filtered channels
final healthyChannelsProvider = FutureProvider<List<Channel>>((ref) async {
  final channels = await ref.watch(channelsProvider.future);

  
  // Don't filter on first load - just return all
  // Background health checks will update status over time
  return channels;
});
