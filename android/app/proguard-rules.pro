# Helper rules
-ignorewarnings
-dontwarn **

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Just Audio Background
-keep class com.ryanheise.just_audio_background.** { *; }
-keep class com.ryanheise.audioservice.** { *; }

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# Dio
-keep class dio.** { *; }
-keep class com.example.** { *; } # Keep your own model classes if they are reflected

# Media Support
-keep class androidx.media.** { *; }
-keep class android.support.v4.media.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Generic Cache Manager Protection (Safe measure)
-keep class com.baseflow.** { *; }
