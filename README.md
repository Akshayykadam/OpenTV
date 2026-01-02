# OpenTV 📺

**Netflix-Quality IPTV Streaming for Android & implementation.**

OpenTV is a modern, high-performance IPTV player built with Flutter. It mimics the premium look and feel of top-tier streaming services, offering a smooth, ad-free, and immersive viewing experience for your M3U playlists.

## ✨ Features

-   **Premium UI/UX**: Dark mode, cinematic animations, and a clean, focus-driven interface.
-   **Smart Player**: Native video player based on Chewie with support for various stream formats.
-   **M3U Playlist Support**: Easily parse and organize channels from M3U playlists.
-   **Live Search**: Instantly find channels or shows.
-   **Favorites**: Pin your most-watched content for quick access.
-   **Background Play**: (Planned) Audio-only mode or Picture-in-Picture support.
-   **Cross-Platform**: Built for Android, adaptable for iOS and Web.

## 🛠️ Tech Stack

-   **Framework**: Flutter
-   **Language**: Dart
-   **State Management**: Riverpod
-   **Networking**: Dio
-   **Local Database**: Hive
-   **Video Player**: Chewie + Video Player

## 🚀 Getting Started

### Prerequisites
-   Flutter SDK (3.10.x or later)
-   Dart SDK
-   Android Studio / VS Code with Flutter extensions

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Akshayykadam/OpenTV.git
    cd OpenTV
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run Code Generation:**
    This project uses code generation for state management and data models.
    ```bash
    dart run build_runner build -d
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

## 🏗️ Building for Production

To generate a release APK for Android:

```bash
flutter build apk --release
```

The output will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## 📄 Documentation

For detailed technical documentation, architecture overview, and development guides, please refer to [Docs.md](Docs.md).

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
