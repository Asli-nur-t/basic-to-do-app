-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

# Hive için
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class * extends com.google.gson.TypeAdapter { *; }

# GetX için
-keep class * extends com.google.gson.TypeAdapter { *; } 