# Keep Flutter and video player classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep Hive adapters
-keep class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite { *; }

# Ignore missing Play Core classes (not used in this app)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Flutter deferred components (required even if not used)
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
