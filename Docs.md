# OpenTV Technical Documentation

## 1. Project Overview

OpenTV is a high-performance IPTV streaming application built with Flutter. It aims to provide a Netflix-quality user experience for consuming IPTV content. The app is architected for scalability, maintainability, and performance, leveraging modern Flutter best practices.

## 2. Architecture

The project follows a **Feature-First** architecture combined with a **Repository Pattern**. This ensures that code related to a specific feature (like the player or home screen) is grouped together, while data access logic is decoupled from the UI.

### Folder Structure

```
lib/
├── core/               # Core utilities, constants, theme, and shared widgets
│   ├── theme/          # App theming (colors, typography)
│   └── ...
├── data/               # Data layer (API, local storage, repositories)
│   ├── api/            # API clients (Dio setup)
│   ├── models/         # Data models (DTOs, JSON serialization)
│   ├── repositories/   # Repository implementations
│   └── services/       # External services (e.g., AudioService)
├── features/           # Feature-based modules
│   ├── home/           # Home screen logic and widgets
│   ├── player/         # Video player logic and widgets
│   ├── search/         # Search functionality
│   ├── settings/       # App settings
│   └── browse/         # Content browsing
└── main.dart           # Application entry point
```

## 3. Key Technologies & Libraries

### State Management: **Riverpod**
We use `flutter_riverpod` and `riverpod_annotation` for robust and compile-time safe state management.
-   **Providers**: defined using `@riverpod` annotations where possible for code generation.
-   **Usage**: Widgets extend `ConsumerWidget` or use `Consumer` to listen to state changes.

### Networking: **Dio**
`dio` is used for handling HTTP requests.
-   Interceptors are configured for logging and caching.
-   `dio_cache_interceptor` is used to cache responses and improve performance.

### Local Storage: **Hive**
`hive` and `hive_flutter` are used for fast, key-value local storage.
-   Used for persisting user preferences, favorites, and watch history.
-   Custom adapters are generated using `hive_generator`.

### Video Playback: **Video Player & Chewie**
-   `video_player`: The low-level plugin for video playback.
-   `chewie`: Provides a highly customizable and polished UI wrapper around the video player.

### JSON Serialization: **Freezed & JSON Serializable**
-   `freezed`: Used for creating immutable data classes and unions.
-   `json_serializable`: Handles JSON serialization/deserialization code generation.

## 4. Development Workflow

### Code Generation
This project relies heavily on code generation (for Riverpod, Freezed, Hive, JSON Serializable).
To run the build runner:
```bash
# Watch mode (recommended during development)
dart run build_runner watch -d

# One-time build
dart run build_runner build -d
```

### Adding a New Feature
1.  Create a new folder in `lib/features/<feature_name>`.
2.  Define the UI widgets.
3.  Create a Repository in `lib/data/repositories` if data access is needed.
4.  Create Providers to manage the state and connect the UI to the Repository.

## 5. Theming & UI
The app uses a custom `AppTheme` defined in `lib/core/theme/app_theme.dart`.
-   **Design System**: We follow a dark-themed, cinematic design language.
-   **Typography**: Google Fonts are used for consistent and modern typography.
-   **Animations**: `flutter_animate` is used for adding smooth entry and interaction animations.

## 6. Testing
-   **Unit Tests**: Located in `test/`. Use `flutter test` to run.
-   **Integration Tests**: (If applicable)

## 7. Build & Release
To build the APK for Android:
```bash
flutter build apk --release
```
For App Bundle (Play Store):
```bash
flutter build appbundle --release
```
