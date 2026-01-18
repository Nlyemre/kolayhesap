####################################
# FLUTTER (ZORUNLU)
####################################
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

####################################
# FIREBASE (CORE + ANALYTICS + MESSAGING)
####################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Messaging (bildirimler için şart)
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }

####################################
# GOOGLE MOBILE ADS (ADMOB)
####################################
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

####################################
# ML KIT / MOBILE SCANNER (BARKOD – QR)
####################################
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

####################################
# ANDROIDX / CORE
####################################
-dontwarn androidx.**

####################################
# PLAY CORE (SPLIT / INSTALL / REVIEW)
####################################
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

####################################
# URL LAUNCHER (CUSTOM TABS)
####################################
-keep class androidx.browser.customtabs.** { *; }

####################################
# PERMISSION HANDLER
####################################
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

####################################
# FILE PICKER
####################################
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

####################################
# FLUTTER LOCAL NOTIFICATIONS
####################################
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

####################################
# DESUGARING (JAVA 17)
####################################
-dontwarn j$.**
-dontwarn java.lang.invoke.**

####################################
# GENEL GEREKLİ ATTRIBUTELAR
####################################
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

####################################
# GEREKSİZ UYARILARI BASTIR
####################################
-dontwarn javax.annotation.**
-dontwarn sun.misc.**
-dontwarn android.util.**
