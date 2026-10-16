# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLite3 / Drift Native Interop
-keep class org.sqlite.** { *; }
-keep class com.simolus3.sqlite3_flutter_libs.** { *; }
-dontwarn org.sqlite.**

# Google Mobile Ads
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
   public *;
}

# Workmanager
-keep class androidx.work.** { *; }
-keep class dev.fluttercommunity.workmanager.** { *; }

# Supabase / HTTP / Serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Play Core / Deferred Components
-dontwarn com.google.android.play.core.**

