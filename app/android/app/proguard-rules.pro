# Keep Google ML Kit barcode scanning (used by mobile_scanner). Under R8 full mode
# the ComponentRegistrar no-arg constructors get stripped, causing
# NoSuchMethodException -> mobile_scanner NullPointerException on release builds.
# These rules let you safely re-enable shrinking for production.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-dontwarn com.google.mlkit.**

# mobile_scanner plugin
-keep class dev.steenbakker.mobile_scanner.** { *; }
