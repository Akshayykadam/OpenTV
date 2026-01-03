<p align="center">
  <img src="assets/icons/opentv_icon.png" alt="OpenTV Logo" width="120" height="120">
</p>

<h1 align="center">OpenTV</h1>

<p align="center">
  <strong>🎬 Netflix-Quality IPTV Streaming for Android</strong>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-screenshots">Screenshots</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

---

## 📖 About

**OpenTV** is a modern, high-performance IPTV streaming application built with Flutter. It delivers a premium, Netflix-like user experience for watching live TV channels from around the world. The app fetches channel data from the open-source [iptv-org](https://github.com/iptv-org/iptv) database, providing access to thousands of free, publicly available streams.

> **Disclaimer**: OpenTV does not host or provide any video content. It is a player for publicly available IPTV streams. All content is provided by third-party sources.

---

## ✨ Features

### 🎯 Core Features
- **🌍 10,000+ Channels**: Access thousands of live TV channels from around the globe
- **🔍 Smart Search**: Instantly find your favorite channels with real-time search
- **🌎 Country Filtering**: Filter channels by country with a beautiful country selector
- **📺 Categories**: Browse by News, Sports, Entertainment, Movies, Music, Kids & more
- **❤️ Favorites**: Save and quickly access your most-watched channels
- **📜 Watch History**: Automatic tracking of your viewing history with "Continue Watching"
- **📊 Stream Quality Indicators**: See 4K, 1080p, 720p, SD badges on channels

### 🎨 Premium UI/UX
- **📱 Dark Mode First**: Beautiful dark theme optimized for TV viewing
- **✨ Smooth Animations**: Polished micro-animations throughout the app
- **🖼️ Channel Logos**: High-quality logos fetched from the IPTV database
- **🔄 Pull to Refresh**: Refresh channel data with a simple pull gesture
- **🦴 Skeleton Loading**: Beautiful loading states while content loads
- **📳 Haptic Feedback**: Subtle vibrations on all interactive elements

### 🎬 Video Player
- **📺 Fullscreen Immersive**: Automatic landscape mode with hidden system UI
- **🔊 Swipe Volume Control**: Swipe up/down on right side to adjust volume
- **☀️ Swipe Brightness Control**: Swipe up/down on left side to adjust brightness
- **🤏 Pinch to Zoom**: Pinch to toggle between fit-to-screen and fill-screen modes
- **📺 Picture-in-Picture**: Continue watching in a floating window (Android 8.0+)
- **⏭️ Channel Quick-Switch**: Swipe left/right or use prev/next buttons to switch channels
- **🔄 Auto-Retry**: Automatic reconnection with countdown on stream failure
- **🔴 Live Indicator**: Clear "LIVE" badge during playback
- **📡 Stream Quality Badge**: See the current stream quality
- **❤️ Quick Favorite**: Add channels to favorites directly from the player
- **💡 Screen Always On**: Screen stays on while watching

### ⚡ Performance
- **💾 Smart Caching**: 6-hour channel data cache with automatic refresh
- **🚀 Parallel Loading**: Channels, streams, and logos loaded simultaneously
- **📦 Offline Fallback**: Cached data available when offline
- **🔄 Background Refresh**: Data updates without interrupting your viewing

---

## 📸 Screenshots

> *Coming soon*

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10+ |
| **Language** | Dart 3.0+ |
| **State Management** | Riverpod |
| **Networking** | Dio |
| **Local Storage** | Hive |
| **Video Player** | video_player + Chewie |
| **Code Generation** | Freezed, json_serializable |
| **Architecture** | Feature-First + Repository Pattern |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.x or later
- Dart SDK 3.0.x or later
- Android Studio / VS Code with Flutter extensions
- An Android device or emulator (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AkshayKadam/OpenTV.git
   cd OpenTV
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (required for Freezed models and Riverpod)
   ```bash
   dart run build_runner build -d
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏗️ Architecture

OpenTV follows a **Feature-First** architecture combined with the **Repository Pattern** for clean separation of concerns.

```
lib/
├── core/                    # Core utilities & shared code
│   ├── theme/               # App theming (colors, typography, spacing)
│   ├── config/              # App configuration
│   ├── constants/           # App-wide constants
│   └── utils/               # Utility functions
│
├── data/                    # Data layer
│   ├── api/                 # API clients (Dio setup)
│   │   └── iptv_api_client.dart
│   ├── models/              # Data models (Freezed)
│   │   └── channel.dart
│   ├── repositories/        # Repository implementations
│   │   ├── channel_repository.dart
│   │   └── favorites_repository.dart
│   └── services/            # External services
│
├── features/                # Feature modules
│   ├── home/                # Home screen & discovery
│   │   ├── home_screen.dart
│   │   ├── providers/       # Feature-specific state
│   │   └── widgets/         # Feature-specific widgets
│   ├── player/              # Video player
│   ├── search/              # Search functionality
│   ├── browse/              # Category browsing
│   └── settings/            # App settings
│
└── main.dart                # Application entry point
```

---

## 📚 Documentation

For detailed technical documentation, architecture deep-dives, and development guides, see **[Docs.md](Docs.md)**.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow the existing code style and architecture patterns
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **[iptv-org](https://github.com/iptv-org/iptv)** - For the amazing open-source IPTV database
- **[Flutter](https://flutter.dev)** - For the beautiful cross-platform framework
- **[Riverpod](https://riverpod.dev)** - For the powerful state management solution

---

<p align="center">Made with ❤️ and Flutter</p>
