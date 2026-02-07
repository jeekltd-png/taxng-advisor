# Flutter ProGuard Rules

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Hive classes
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.** { *; }

# Keep crypto classes
-keep class org.bouncycastle.** { *; }

# Don't warn about missing classes in optional dependencies
-dontwarn com.google.**
-dontwarn org.bouncycastle.**
-dontwarn kotlin.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
