# OpenTV Technical Documentation

> **Complete Developer Reference for OpenTV**

This document provides comprehensive technical documentation for the OpenTV IPTV streaming application. It covers architecture decisions, implementation details, API integrations, data models, and development workflows.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Folder Structure](#3-folder-structure)
4. [Core Layer](#4-core-layer)
5. [Data Layer](#5-data-layer)
6. [Features Layer](#6-features-layer)
7. [State Management](#7-state-management)
8. [IPTV-ORG API Integration](#8-iptv-org-api-integration)
9. [Data Models](#9-data-models)
10. [Video Player Implementation](#10-video-player-implementation)
11. [Caching Strategy](#11-caching-strategy)
12. [Theming & Design System](#12-theming--design-system)
13. [Development Workflow](#13-development-workflow)
14. [Testing](#14-testing)
15. [Build & Deployment](#15-build--deployment)
16. [Troubleshooting](#16-troubleshooting)

---

## 1. Project Overview

### 1.1 What is OpenTV?

OpenTV is a Flutter-based IPTV streaming application that provides a Netflix-like experience for watching free, publicly available live TV streams. The app aggregates channel data from the [iptv-org](https://github.com/iptv-org/iptv) open-source database, which contains metadata for over 10,000 channels from around the world.

### 1.2 Key Features

| Feature | Description |
|---------|-------------|
| **Channel Discovery** | Browse 10,000+ channels organized by country and category |
| **Smart Search** | Real-time search with debouncing for instant results |
| **Country Filtering** | Filter channels by country with rich country metadata |
| **Favorites** | Persistent favorite channels with instant access |
| **Watch History** | Automatic tracking of recently watched channels |
| **Video Player** | Fullscreen immersive player with system volume control |
| **Offline Support** | Cached channel data available when offline |
| **Quality Indicators** | Stream quality badges (4K, 1080p, 720p, SD) |

### 1.3 Target Platforms

- **Primary**: Android (API 21+)
- **Secondary**: iOS (planned)
- **Tertiary**: Web (experimental)

### 1.4 Flutter Version

```yaml
environment:
  sdk: ^3.10.4
```

---

## 2. Architecture

OpenTV follows a **Feature-First Architecture** combined with the **Repository Pattern**. This architecture was chosen for:

1. **Scalability**: New features can be added without modifying existing code
2. **Testability**: Each layer can be tested in isolation
3. **Maintainability**: Clear separation of concerns
4. **Team Collaboration**: Multiple developers can work on different features

### 2.1 Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                              │
│  (Widgets, Screens, Providers)                               │
├─────────────────────────────────────────────────────────────┤
│                    STATE MANAGEMENT                          │
│  (Riverpod Providers, StateNotifiers)                        │
├─────────────────────────────────────────────────────────────┤
│                   REPOSITORY LAYER                           │
│  (ChannelRepository, FavoritesRepository)                    │
├─────────────────────────────────────────────────────────────┤
│                      DATA LAYER                              │
│  (API Client, Local Storage, Models)                         │
├─────────────────────────────────────────────────────────────┤
│                    EXTERNAL SERVICES                         │
│  (IPTV-ORG API, Hive, Video Player)                          │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
User Interaction → Widget → Provider → Repository → API/Cache → Response
                                                              ↓
User sees update ← Widget rebuilds ← Provider notifies ← Data parsed
```

---

## 3. Folder Structure

```
lib/
├── core/                           # Shared utilities & configurations
│   ├── config/                     # App configuration
│   ├── constants/                  # App-wide constants
│   ├── theme/                      # Design system
│   │   ├── app_theme.dart          # ThemeData configuration
│   │   └── design_tokens.dart      # Colors, spacing, typography
│   └── utils/                      # Utility functions
│
├── data/                           # Data layer (pure Dart)
│   ├── api/                        # API clients
│   │   └── iptv_api_client.dart    # IPTV-ORG API integration
│   ├── models/                     # Data models
│   │   ├── channel.dart            # Channel model (Freezed)
│   │   ├── channel.freezed.dart    # Generated code
│   │   └── channel.g.dart          # JSON serialization
│   ├── repositories/               # Repository implementations
│   │   ├── channel_repository.dart # Channel data access
│   │   └── favorites_repository.dart # Local favorites storage
│   └── services/                   # External service wrappers
│       └── stream_health_service.dart
│
├── features/                       # Feature modules
│   ├── browse/                     # Category browsing
│   │   ├── category_screen.dart
│   │   └── widgets/
│   │       └── channel_card.dart
│   ├── home/                       # Main discovery screen
│   │   ├── home_screen.dart
│   │   ├── providers/
│   │   │   └── selected_country_provider.dart
│   │   └── widgets/
│   │       ├── channel_carousel.dart
│   │       ├── country_search_sheet.dart
│   │       └── hero_banner.dart
│   ├── player/                     # Video player
│   │   └── player_screen.dart
│   ├── search/                     # Search functionality
│   │   └── search_screen.dart
│   └── settings/                   # App settings
│
├── platform/                       # Platform-specific code
│
└── main.dart                       # Application entry point
```

---

## 4. Core Layer

The core layer contains shared utilities, configuration, and the design system.

### 4.1 Design Tokens (`design_tokens.dart`)

All visual constants are defined as design tokens for consistency:

#### Colors

```dart
class AppColors {
  // Brand colors
  static const Color primary = Color(0xFFE50914);  // TV Red
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color primaryDark = Color(0xFFB71C1C);

  // Surface colors (Dark theme)
  static const Color surface = Color(0xFF0F0F14);
  static const Color surfaceElevated = Color(0xFF1A1A24);
  static const Color surfaceElevated2 = Color(0xFF252532);
  static const Color surfaceElevated3 = Color(0xFF2F2F40);

  // Text colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
```

#### Spacing (8pt Grid)

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

#### Typography

```dart
class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  // ... more styles
}
```

#### Border Radius

```dart
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 9999.0;  // Pill shape
  
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(full));
}
```

---

## 5. Data Layer

### 5.1 API Client (`iptv_api_client.dart`)

The API client handles all communication with the IPTV-ORG API.

#### Base Configuration

```dart
const String _baseUrl = 'https://iptv-org.github.io/api';

class IptvApiEndpoints {
  static const String channels = '/channels.json';
  static const String streams = '/streams.json';
  static const String categories = '/categories.json';
  static const String countries = '/countries.json';
  static const String logos = '/logos.json';
  static const String languages = '/languages.json';
}
```

#### Dio Provider

```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));
  return dio;
});
```

#### Data Merging Strategy

The IPTV-ORG API provides data in separate files (channels, streams, logos). The `fetchMergedChannels()` method combines them:

```dart
Future<List<Channel>> fetchMergedChannels() async {
  // Fetch all data in parallel for speed
  final results = await Future.wait([
    fetchChannels(),
    fetchStreams(),
    fetchLogos(),
  ]);

  final channels = results[0] as List<ChannelInfo>;
  final streams = results[1] as List<StreamInfo>;
  final logos = results[2] as List<LogoInfo>;

  // Create lookup maps for O(1) access
  final streamsByChannel = <String, List<StreamInfo>>{};
  final logosByChannel = <String, LogoInfo>{};
  
  // Merge data into unified Channel objects
  // ... merging logic
}
```

### 5.2 Channel Repository (`channel_repository.dart`)

The repository abstracts data access and implements caching.

#### Key Methods

| Method | Description |
|--------|-------------|
| `getChannels()` | Get all channels (cached or from API) |
| `getChannelsByCountry(code)` | Filter channels by country code |
| `getChannelsByCategory(cat)` | Filter channels by category |
| `searchChannels(query)` | Search by name or alt names |
| `getAvailableCountries()` | Get countries with channels |
| `clearCache()` | Force refresh on next fetch |

#### Caching Strategy

```dart
const Duration _cacheValidDuration = Duration(hours: 6);

Future<List<Channel>> getChannels({bool forceRefresh = false}) async {
  // 1. Return memory cache if available
  if (_channelsCache != null && !forceRefresh) {
    return _channelsCache!;
  }

  // 2. Check disk cache freshness
  if (!forceRefresh && _isCacheValid()) {
    final cached = _loadFromCache();
    if (cached != null) return cached;
  }

  // 3. Fetch from API
  try {
    final channels = await _apiClient.fetchMergedChannels();
    await _saveToCache(channels);
    return channels;
  } catch (e) {
    // 4. Fall back to stale cache on error
    final cached = _loadFromCache();
    if (cached != null) return cached;
    rethrow;
  }
}
```

### 5.3 Favorites Repository (`favorites_repository.dart`)

Manages local storage for favorites and watch history using Hive.

#### Features

| Feature | Storage Key | Max Entries |
|---------|-------------|-------------|
| Favorites | `favorites` | Unlimited |
| Watch History | `history` | 100 |
| Last Channel | `last_channel` | 1 |

#### Watch History Entry

```dart
class WatchHistoryEntry {
  final String channelId;
  final DateTime watchedAt;
  final Duration watchDuration;
}
```

---

## 6. Features Layer

Each feature is a self-contained module with its own screens, widgets, and providers.

### 6.1 Home Feature

**Location**: `lib/features/home/`

The home screen is the main discovery interface.

#### Components

| Component | Description |
|-----------|-------------|
| `HomeScreen` | Main screen with app bar and content |
| `ChannelCarousel` | Horizontal scrolling channel list |
| `CountrySearchSheet` | Bottom sheet for country selection |
| `HeroBanner` | Featured content banner (unused) |

#### Content Sections

1. **Search Bar** - Full-width pill-shaped search trigger
2. **Continue Watching** - Recently watched channels
3. **Your Favorites** - User's favorite channels
4. **Trending** - First 20 channels
5. **News** - Channels with category "news"
6. **Sports** - Channels with category "sports"
7. **Entertainment** - Channels with category "entertainment"
8. **Movies** - Channels with category "movies"
9. **Music** - Channels with category "music"
10. **Kids** - Channels with category "kids"

### 6.2 Player Feature

**Location**: `lib/features/player/`

Fullscreen video player with immersive UI.

#### Player Screen Lifecycle

```dart
@override
void initState() {
  super.initState();
  _initializePlayer();
  
  // Enter fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  _initVolume();
}

@override
void dispose() {
  // Record watch duration
  if (_startTime != null) {
    final duration = DateTime.now().difference(_startTime!);
    ref.read(favoritesRepositoryProvider).addWatchHistory(
      widget.channel.id, 
      duration,
    );
  }
  
  // Restore portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  super.dispose();
}
```

#### Controls Overlay

- **Top Bar**: Back button, channel name, volume slider, favorite button
- **Center**: Play/Pause button
- **Bottom Bar**: Live indicator, quality badge

#### Auto-Hide Controls

Controls automatically hide after 3 seconds of inactivity:

```dart
void _startHideTimer() {
  _hideTimer?.cancel();
  _hideTimer = Timer(const Duration(seconds: 3), () {
    if (mounted && _isInitialized) {
      setState(() => _showControls = false);
    }
  });
}
```

### 6.3 Search Feature

**Location**: `lib/features/search/`

Real-time search with debouncing.

#### Debounced Search

```dart
void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    ref.read(searchQueryProvider.notifier).state = query;
  });
}
```

#### Search Algorithm

Searches by:
1. Channel name (case-insensitive contains)
2. Alternative names (alt_names from API)

### 6.4 Browse Feature

**Location**: `lib/features/browse/`

Category and channel browsing.

#### Channel Card

The `ChannelCard` widget displays:
- Channel logo (cached)
- Channel name
- Quality badge (if available)
- Category color indicator

---

## 7. State Management

OpenTV uses **Riverpod** for state management.

### 7.1 Provider Types Used

| Type | Use Case |
|------|----------|
| `Provider` | Simple read-only values (repositories, services) |
| `FutureProvider` | Async data fetching (channels, countries) |
| `StateProvider` | Simple mutable state (search query) |
| `StateNotifierProvider` | Complex mutable state (favorites) |

### 7.2 Key Providers

```dart
// Data Access
final channelRepositoryProvider = Provider<ChannelRepository>((ref) {...});
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {...});

// Async Data
final channelsProvider = FutureProvider<List<Channel>>((ref) async {...});
final availableCountriesProvider = FutureProvider<List<Country>>((ref) async {...});

// User State
final favoriteIdsProvider = StateNotifierProvider<FavoriteIdsNotifier, Set<String>>(...);
final selectedCountryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
```

### 7.3 Provider Dependencies

```
channelsProvider
    └── channelRepositoryProvider
            └── iptvApiClientProvider
                    └── dioProvider

favoriteIdsProvider
    └── favoritesRepositoryProvider
```

---

## 8. IPTV-ORG API Integration

### 8.1 API Overview

The [iptv-org API](https://github.com/iptv-org/api) provides JSON files with IPTV metadata:

| Endpoint | Description | Size |
|----------|-------------|------|
| `/channels.json` | Channel metadata | ~5MB |
| `/streams.json` | Stream URLs | ~2MB |
| `/logos.json` | Logo URLs | ~1MB |
| `/countries.json` | Country metadata | ~50KB |
| `/categories.json` | Category metadata | ~5KB |

### 8.2 Data Relationships

```
Channel (id)
    │
    ├── Stream (channel → id, url)
    │
    └── Logo (channel → id, url)
```

### 8.3 Handling Null Fields

The API has inconsistent null handling. All fields are declared nullable:

```dart
@freezed
class StreamInfo with _$StreamInfo {
  const factory StreamInfo({
    String? channel,  // CAN BE NULL!
    String? url,      // CAN BE NULL!
    String? quality,
    String? referrer,
    @JsonKey(name: 'user_agent') String? userAgent,
  }) = _StreamInfo;
}
```

### 8.4 Filtering Logic

Channels are filtered during merge:

```dart
// Skip if no stream URL
if (channelStreams == null || channelStreams.isEmpty) continue;

// Skip closed/replaced channels
if (info.closed != null || info.replacedBy != null) continue;

// Skip channels with empty country
if (info.country.isEmpty) continue;
```

---

## 9. Data Models

### 9.1 Channel Model

The primary domain entity:

```dart
@freezed
class Channel with _$Channel {
  const factory Channel({
    required String id,              // "ABCNews.au"
    required String name,            // "ABC News"
    String? logo,                    // Logo URL
    required String country,         // "AU"
    String? category,                // "news"
    required String streamUrl,       // HLS/DASH URL
    @Default(StreamQuality.unknown) StreamQuality quality,
    @Default(false) bool isNsfw,
    @Default(HealthStatus.unknown) HealthStatus health,
    List<String>? altNames,          // Alternative names
    String? network,                 // "ABC"
    String? website,                 // Official website
    String? referrer,                // Required referrer header
    String? userAgent,               // Required user agent
  }) = _Channel;
}
```

### 9.2 Stream Quality Enum

```dart
enum StreamQuality {
  @JsonValue('4k')    uhd4k,    // 2160p
  @JsonValue('1080p') hd1080,   // Full HD
  @JsonValue('720p')  hd720,    // HD
  @JsonValue('480p')  sd480,    // SD
  @JsonValue('360p')  low360,   // Low
  unknown,                       // Unspecified
}
```

### 9.3 Country Model

```dart
@freezed
class Country with _$Country {
  const factory Country({
    required String name,            // "United States"
    required String code,            // "US"
    String? flag,                    // "🇺🇸"
    @Default([]) List<String> languages,
  }) = _Country;
}
```

---

## 10. Video Player Implementation

### 10.1 Technology Stack

- **video_player**: Flutter's official video plugin
- **chewie**: Material Design video player wrapper (optional)
- **flutter_volume_controller**: System volume control

### 10.2 Stream Headers

Some streams require custom headers:

```dart
_controller = VideoPlayerController.networkUrl(
  Uri.parse(channel.streamUrl),
  httpHeaders: {
    if (channel.referrer != null) 'Referer': channel.referrer!,
    if (channel.userAgent != null) 'User-Agent': channel.userAgent!,
  },
);
```

### 10.3 Error Handling

Human-readable error messages:

```dart
String _getHumanReadableError(dynamic error) {
  final errorStr = error.toString().toLowerCase();
  
  if (errorStr.contains('403') || errorStr.contains('forbidden')) {
    return 'This channel is not available in your region';
  }
  if (errorStr.contains('timeout')) {
    return 'Connection timed out. Please check your internet.';
  }
  // ... more error mappings
}
```

### 10.4 Volume Control

Uses system volume for consistent UX:

```dart
Future<void> _initVolume() async {
  final initVol = await FlutterVolumeController.getVolume();
  if (mounted && initVol != null) {
    setState(() => _volume = initVol);
  }
  
  FlutterVolumeController.addListener((volume) {
    if (mounted) setState(() => _volume = volume);
  });
}
```

---

## 11. Caching Strategy

### 11.1 Cache Layers

| Layer | Technology | Duration | Purpose |
|-------|------------|----------|---------|
| Memory | Dart objects | Session | Instant access |
| Disk | Hive | 6 hours | Offline support |
| HTTP | Dio interceptors | - | Network savings |

### 11.2 Cache Invalidation

```dart
// Manual refresh
ref.invalidate(channelsProvider);

// Force refresh in repository
await repository.getChannels(forceRefresh: true);

// Clear cache
await repository.clearCache();
```

### 11.3 Image Caching

Channel logos are cached using `cached_network_image`:

```dart
CachedNetworkImage(
  imageUrl: channel.logo ?? '',
  fit: BoxFit.cover,
  placeholder: (context, url) => const ChannelLogoPlaceholder(),
  errorWidget: (context, url, error) => const ChannelLogoPlaceholder(),
)
```

---

## 12. Theming & Design System

### 12.1 Design Philosophy

- **Dark-First**: Optimized for TV/media viewing
- **Content-Forward**: Content is the hero, UI fades back
- **Large Touch Targets**: Minimum 48dp for accessibility
- **Smooth Animations**: 200-300ms transitions

### 12.2 Color Palette

| Role | Color | Usage |
|------|-------|-------|
| Primary | `#E50914` | Accent, CTAs, Live badge |
| Surface | `#0F0F14` | Main background |
| Elevated | `#1A1A24` | Cards, overlays |
| Text Primary | `#F8FAFC` | Headings, important text |
| Text Secondary | `#94A3B8` | Body text, descriptions |
| Error | `#EF4444` | Errors, NSFW, Live badge |

### 12.3 Animation Tokens

```dart
class AppMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  
  static const Curve defaultCurve = Curves.easeOutCubic;
}
```

---

## 13. Development Workflow

### 13.1 Code Generation

OpenTV uses multiple code generators:

```bash
# One-time build
dart run build_runner build -d

# Watch mode (recommended during development)
dart run build_runner watch -d
```

#### Generated Files

| Generator | Input | Output |
|-----------|-------|--------|
| Freezed | `channel.dart` | `channel.freezed.dart` |
| JSON Serializable | `channel.dart` | `channel.g.dart` |
| Riverpod Generator | `@riverpod` annotations | `*.g.dart` |

### 13.2 Adding a New Feature

1. Create folder: `lib/features/<feature_name>/`
2. Create screen: `<feature_name>_screen.dart`
3. Create providers: `providers/<provider_name>.dart`
4. Create widgets: `widgets/<widget_name>.dart`
5. Add navigation from existing screens

### 13.3 Adding a New Data Model

1. Create model in `lib/data/models/`
2. Annotate with `@freezed` and `@JsonSerializable`
3. Run `dart run build_runner build -d`
4. Create repository methods if needed

---

## 14. Testing

### 14.1 Test Structure

```
test/
├── data/
│   ├── api/
│   │   └── iptv_api_client_test.dart
│   └── repositories/
│       └── channel_repository_test.dart
├── features/
│   ├── home/
│   │   └── home_screen_test.dart
│   └── player/
│       └── player_screen_test.dart
└── widget_test.dart
```

### 14.2 Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/data/api/iptv_api_client_test.dart

# With coverage
flutter test --coverage
```

---

## 15. Build & Deployment

### 15.1 Debug Build

```bash
flutter run
```

### 15.2 Release Build

```bash
# APK (for direct distribution)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### 15.3 Build Optimization

The release build includes:
- **Code shrinking**: R8/ProGuard
- **Tree shaking**: Unused code removed
- **Icon tree shaking**: Unused icons removed (99.8% reduction)
- **Obfuscation**: Optional with `--obfuscate`

### 15.4 Signing

For release builds, configure signing in `android/app/build.gradle`:

```groovy
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 16. Troubleshooting

### 16.1 Build Errors

**"Cannot find symbol"** (Android)
```bash
flutter clean
flutter pub get
dart run build_runner build -d
flutter build apk --release
```

**"Undefined name 'SystemChrome'"**
Add missing import:
```dart
import 'package:flutter/services.dart';
```

### 16.2 Runtime Errors

**"Unable to play this channel"**
- Check internet connection
- Stream may be geo-blocked
- Stream URL may be dead

**"Connection timed out"**
- Increase timeout in Dio configuration
- Check network quality

### 16.3 Common Issues

| Issue | Solution |
|-------|----------|
| Channels not loading | Check internet, try pull-to-refresh |
| Video stuck on loading | Try another channel, check stream health |
| Orientation stuck in landscape | Force quit and reopen app |
| Favorites not saving | Check Hive initialization |

---

## Appendix A: Dependencies

```yaml
dependencies:
  # Core
  flutter: sdk
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Networking
  dio: ^5.4.0
  dio_cache_interceptor: ^3.5.0
  connectivity_plus: ^6.0.3

  # Video Player
  video_player: ^2.8.7
  chewie: ^1.8.1

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2

  # UI
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1

  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  collection: ^1.18.0
  intl: ^0.19.0
  flutter_volume_controller: ^1.3.4

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^6.0.0
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.10
```

---

## Appendix B: API Response Samples

### channels.json (sample)

```json
{
  "id": "ABCNews.au",
  "name": "ABC News",
  "alt_names": ["ABC News Australia"],
  "network": "ABC",
  "country": "AU",
  "categories": ["news"],
  "is_nsfw": false,
  "website": "https://www.abc.net.au/news/"
}
```

### streams.json (sample)

```json
{
  "channel": "ABCNews.au",
  "url": "https://abc-iview-mediapackagestreams.akamaized.net/out/v1/.../index.m3u8",
  "quality": "1080p"
}
```

### logos.json (sample)

```json
{
  "channel": "ABCNews.au",
  "url": "https://i.imgur.com/abcnews.png"
}
```

---

<p align="center">
  <strong>End of Documentation</strong>
</p>
