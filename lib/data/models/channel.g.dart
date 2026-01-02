// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChannelImpl _$$ChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChannelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      country: json['country'] as String,
      category: json['category'] as String?,
      streamUrl: json['streamUrl'] as String,
      quality: $enumDecodeNullable(_$StreamQualityEnumMap, json['quality']) ??
          StreamQuality.unknown,
      isNsfw: json['isNsfw'] as bool? ?? false,
      health: $enumDecodeNullable(_$HealthStatusEnumMap, json['health']) ??
          HealthStatus.unknown,
      altNames: (json['altNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      network: json['network'] as String?,
      website: json['website'] as String?,
      referrer: json['referrer'] as String?,
      userAgent: json['userAgent'] as String?,
    );

Map<String, dynamic> _$$ChannelImplToJson(_$ChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'country': instance.country,
      'category': instance.category,
      'streamUrl': instance.streamUrl,
      'quality': _$StreamQualityEnumMap[instance.quality]!,
      'isNsfw': instance.isNsfw,
      'health': _$HealthStatusEnumMap[instance.health]!,
      'altNames': instance.altNames,
      'network': instance.network,
      'website': instance.website,
      'referrer': instance.referrer,
      'userAgent': instance.userAgent,
    };

const _$StreamQualityEnumMap = {
  StreamQuality.uhd4k: '4k',
  StreamQuality.hd1080: '1080p',
  StreamQuality.hd720: '720p',
  StreamQuality.sd480: '480p',
  StreamQuality.low360: '360p',
  StreamQuality.unknown: 'unknown',
};

const _$HealthStatusEnumMap = {
  HealthStatus.online: 'online',
  HealthStatus.degraded: 'degraded',
  HealthStatus.offline: 'offline',
  HealthStatus.unknown: 'unknown',
};

_$ChannelCategoryImpl _$$ChannelCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ChannelCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$ChannelCategoryImplToJson(
        _$ChannelCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

_$CountryImpl _$$CountryImplFromJson(Map<String, dynamic> json) =>
    _$CountryImpl(
      name: json['name'] as String,
      code: json['code'] as String,
      flag: json['flag'] as String?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CountryImplToJson(_$CountryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'flag': instance.flag,
      'languages': instance.languages,
    };

_$StreamInfoImpl _$$StreamInfoImplFromJson(Map<String, dynamic> json) =>
    _$StreamInfoImpl(
      channel: json['channel'] as String?,
      feed: json['feed'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      referrer: json['referrer'] as String?,
      userAgent: json['user_agent'] as String?,
      quality: json['quality'] as String?,
    );

Map<String, dynamic> _$$StreamInfoImplToJson(_$StreamInfoImpl instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'feed': instance.feed,
      'title': instance.title,
      'url': instance.url,
      'referrer': instance.referrer,
      'user_agent': instance.userAgent,
      'quality': instance.quality,
    };

_$ChannelInfoImpl _$$ChannelInfoImplFromJson(Map<String, dynamic> json) =>
    _$ChannelInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      altNames: (json['alt_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      network: json['network'] as String?,
      owners: (json['owners'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      country: json['country'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isNsfw: json['is_nsfw'] as bool? ?? false,
      launched: json['launched'] as String?,
      closed: json['closed'] as String?,
      replacedBy: json['replaced_by'] as String?,
      website: json['website'] as String?,
    );

Map<String, dynamic> _$$ChannelInfoImplToJson(_$ChannelInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'alt_names': instance.altNames,
      'network': instance.network,
      'owners': instance.owners,
      'country': instance.country,
      'categories': instance.categories,
      'is_nsfw': instance.isNsfw,
      'launched': instance.launched,
      'closed': instance.closed,
      'replaced_by': instance.replacedBy,
      'website': instance.website,
    };

_$LogoInfoImpl _$$LogoInfoImplFromJson(Map<String, dynamic> json) =>
    _$LogoInfoImpl(
      channel: json['channel'] as String?,
      feed: json['feed'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      format: json['format'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$LogoInfoImplToJson(_$LogoInfoImpl instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'feed': instance.feed,
      'tags': instance.tags,
      'width': instance.width,
      'height': instance.height,
      'format': instance.format,
      'url': instance.url,
    };
