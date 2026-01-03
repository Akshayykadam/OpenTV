# 🎉 OpenTV v1.0.0 - Initial Release

<p align="center">
  <img src="assets/icons/opentv_icon.png" alt="OpenTV Logo" width="100" height="100">
</p>

<p align="center">
  <strong>🎬 Netflix-Quality IPTV Streaming for Android</strong>
</p>

---

We're excited to announce the first public release of **OpenTV** — a modern, beautifully designed IPTV streaming app built with Flutter. Watch 10,000+ live TV channels from around the world with a premium, Netflix-like experience.

---

## ✨ Highlights

### 🌍 10,000+ Channels at Your Fingertips
Access thousands of free, publicly available live TV channels from countries around the world. Browse by category, filter by country, or search for your favorites.

### 🎨 Premium Dark-First Design
A stunning dark theme optimized for comfortable viewing. Smooth animations, beautiful channel cards, and skeleton loading states for a polished experience.

### 📺 Advanced Video Player
Not just a basic player — OpenTV comes packed with professional-grade controls:

| Feature | How to Use |
|---------|------------|
| **Brightness Control** | Swipe ↕ on left side |
| **Volume Control** | Swipe ↕ on right side |
| **Zoom Toggle** | Pinch in/out |
| **Picture-in-Picture** | Tap PiP button |
| **Channel Switch** | Swipe ← → |
| **Auto-Retry** | Automatic on failure |

### � Smart Features
- **Continue Watching** — Pick up where you left off
- **Favorites** — Quick access to your loved channels
- **Watch History** — Automatic tracking of your viewing
- **Haptic Feedback** — Subtle vibrations for better UX
- **Screen Always On** — No interruptions while watching

---

## 📦 Download

| File | Architecture | Size |
|------|--------------|------|
| `OpenTV-v1.0.0-arm64.apk` | 64-bit ARM | 24 MB |

> 💡 **Tip**: This APK is optimized for modern 64-bit Android devices running Android 5.0 (Lollipop) or higher.

---

## 🛠️ Technical Details

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Video Player**: ExoPlayer (via video_player)
- **Local Storage**: Hive
- **Data Source**: [iptv-org](https://github.com/iptv-org/iptv)

### Optimizations
- R8 code shrinking enabled
- Resource optimization with shrinkResources
- Icon font tree-shaking (99.7% reduction)
- arm64-v8a only build for smallest size

---

## 📋 Full Feature List

### Core Features
- 🌍 10,000+ live TV channels
- 🔍 Real-time search with instant results
- 🌎 Country filtering with beautiful selector
- 📺 Category browsing (News, Sports, Entertainment, Movies, Music, Kids)
- ❤️ Favorites system
- 📜 Watch history tracking
- � Stream quality indicators (4K, 1080p, 720p, SD)

### Player Features
- 📺 Fullscreen immersive playback
- ☀️ Swipe brightness control (left side)
- 🔊 Swipe volume control (right side)
- 🤏 Pinch to zoom (fit/fill toggle)
- 📺 Picture-in-Picture mode (Android 8.0+)
- ⏭️ Channel quick-switch (swipe left/right)
- 🔄 Auto-retry with countdown (max 3 attempts)
- 🔴 Live indicator badge
- 💡 Screen wakelock

### UI/UX
- 📱 Dark mode first design
- ✨ Smooth micro-animations
- 🖼️ High-quality channel logos
- 🔄 Pull-to-refresh
- 🦴 Skeleton loading states
- 📳 Haptic feedback throughout

---

## 📲 Installation

1. Download `OpenTV-v1.0.0-arm64.apk`
2. Enable **"Install from unknown sources"** if prompted
3. Open the APK file and tap **Install**
4. Launch OpenTV and enjoy! 🎉

---

## ⚠️ Disclaimer

OpenTV does not host or provide any video content. It is a player for publicly available IPTV streams. All content is provided by third-party sources from the [iptv-org](https://github.com/iptv-org/iptv) open-source project.

---

## 🙏 Acknowledgments

- **[iptv-org](https://github.com/iptv-org/iptv)** — Open-source IPTV database
- **[Flutter](https://flutter.dev)** — Beautiful cross-platform framework
- **[Riverpod](https://riverpod.dev)** — Powerful state management

---

<p align="center">
  <strong>Made with ❤️ and Flutter</strong>
</p>

<p align="center">
  ⭐ Star us on GitHub if you find this useful!
</p>
