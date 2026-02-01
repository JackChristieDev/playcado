# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Sentry classes
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Support for common libraries
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses

# Dio / OkHttp rules (if used by plugins)
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Jellyfin / API related models if any are in Java/Kotlin
-keep class com.playcado.app.models.** { *; }
