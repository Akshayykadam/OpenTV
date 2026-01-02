# Release Notes - OpenTV v1.1.0

## 🚀 What's New

### 🎬 Advanced Player Gestures
- **Swipe Volume Control** - Swipe up/down on the **right side** of the screen to adjust volume
- **Swipe Brightness Control** - Swipe up/down on the **left side** of the screen to adjust brightness
- **Pinch to Zoom** - Pinch in/out to toggle between fit-to-screen and fill-screen modes
- **Visual Indicators** - See real-time percentage feedback while adjusting

### 📺 Picture-in-Picture Mode
- Continue watching in a floating window while using other apps
- Tap the PiP button in the player controls
- Requires Android 8.0 (Oreo) or higher

### ⏭️ Channel Quick-Switch
- **Swipe left/right** to quickly switch between channels
- **Prev/Next buttons** appear in player controls when viewing from a category
- Shows channel position indicator (e.g., "3 of 20")

### 🔄 Smart Auto-Retry
- Automatically retries failed streams with a 5-second countdown
- Up to 3 automatic retry attempts
- Cancel button to stop auto-retry and manually retry later

### 📳 Haptic Feedback
- Subtle vibrations throughout the app for better tactile experience
- Play/pause, favorite, volume, channel switch, and more

### 💡 Screen Always On
- Screen stays on while watching - no more screen timeout interruptions

---

## 📦 Download

| Variant | Architecture | Size |
|---------|--------------|------|
| **APK** | arm64-v8a | 24 MB |

> **Note**: This release targets 64-bit ARM devices only for smallest file size.

---

## 🛠️ Technical Improvements
- Unified gesture handling for conflict-free touch controls
- R8 code shrinking and resource optimization enabled
- ProGuard rules optimized for Flutter and video playback

---

## 📋 Full Changelog

### Added
- Swipe up/down gestures for brightness (left) and volume (right)
- Picture-in-Picture support for Android 8.0+
- Horizontal swipe for channel switching
- Auto-retry with countdown on stream failure (max 3 attempts)
- Haptic feedback on all interactive elements
- Screen wakelock during video playback

### Changed
- Improved gesture handling to avoid conflicts
- Optimized APK size with R8 shrinking

### Fixed
- GestureDetector conflict error when using multiple gestures

---

## 📲 Installation

1. Download `OpenTV-v1.1.0-arm64.apk`
2. Enable "Install from unknown sources" if prompted
3. Open the APK and tap Install

---

**Made with ❤️ and Flutter**
