/// Channel model - Core domain entity
/// Represents a single TV channel with all metadata
// ignore_for_file: invalid_annotation_target
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

/// Stream quality levels
enum StreamQuality {
  @JsonValue('4k')
  uhd4k,
  @JsonValue('1080p')
  hd1080,
  @JsonValue('720p')
  hd720,
  @JsonValue('480p')
  sd480,
  @JsonValue('360p')
  low360,
  unknown,
}

extension StreamQualityDisplay on StreamQuality {
  String? get displayName {
    switch (this) {
      case StreamQuality.uhd4k:
        return '4K';
      case StreamQuality.hd1080:
        return 'FHD';
      case StreamQuality.hd720:
        return 'HD';
      case StreamQuality.sd480:
        return 'SD';
      default:
        return null;
    }
  }
}

/// Health status of a stream
enum HealthStatus {
  online,
  degraded,
  offline,
  unknown,
}

/// Main channel model
@freezed
class Channel with _$Channel {
  const factory Channel({
    required String id,
    required String name,
    String? logo,
    required String country,
    String? category,
    required String streamUrl,
    @Default(StreamQuality.unknown) StreamQuality quality,
    @Default(false) bool isNsfw,
    @Default(HealthStatus.unknown) HealthStatus health,
    List<String>? altNames,
    String? network,
    String? website,
    String? referrer,
    String? userAgent,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

/// Channel category model
@freezed
class ChannelCategory with _$ChannelCategory {
  const factory ChannelCategory({
    required String id,
    required String name,
    String? description,
  }) = _ChannelCategory;

  factory ChannelCategory.fromJson(Map<String, dynamic> json) =>
      _$ChannelCategoryFromJson(json);
}

/// Country model
@freezed
class Country with _$Country {
  const factory Country({
    required String name,
    required String code,
    String? flag,
    @Default([]) List<String> languages,
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
}

/// Stream info from API - ALL FIELDS NULLABLE to handle API variations
@freezed
class StreamInfo with _$StreamInfo {
  const factory StreamInfo({
    String? channel,  // CAN BE NULL in API!
    String? feed,
    String? title,
    String? url,  // CAN BE NULL in API!
    String? referrer,
    @JsonKey(name: 'user_agent') String? userAgent,
    String? quality,
  }) = _StreamInfo;

  factory StreamInfo.fromJson(Map<String, dynamic> json) =>
      _$StreamInfoFromJson(json);
}

/// Channel info from API (before merging with streams)
@freezed
class ChannelInfo with _$ChannelInfo {
  const factory ChannelInfo({
    required String id,
    required String name,
    @JsonKey(name: 'alt_names') @Default([]) List<String> altNames,
    String? network,
    @Default([]) List<String> owners,
    @Default('') String country,  // Can be null in API
    @Default([]) List<String> categories,
    @JsonKey(name: 'is_nsfw') @Default(false) bool isNsfw,
    String? launched,
    String? closed,
    @JsonKey(name: 'replaced_by') String? replacedBy,
    String? website,
  }) = _ChannelInfo;

  factory ChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoFromJson(json);
}

/// Logo info from API
@freezed
class LogoInfo with _$LogoInfo {
  const factory LogoInfo({
    String? channel,  // Can be null
    String? feed,
    @Default([]) List<String> tags,
    int? width,
    int? height,
    String? format,
    String? url,  // Can be null
  }) = _LogoInfo;

  factory LogoInfo.fromJson(Map<String, dynamic> json) =>
      _$LogoInfoFromJson(json);
}
