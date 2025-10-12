# Flutter Temel Koruma
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.ads.**

# Firebase Core
-keep class com.google.firebase.** { *; }
-keep class com.google.** { *; }
-dontwarn com.google.firebase.**

# Firebase Messaging
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# HTTP ve Network İşlemleri
-keep class io.flutter.plugins.http.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Shared Preferences
-keep class android.content.SharedPreferences { *; }
-keep class com.tencent.mmkv.** { *; }
-dontwarn com.tencent.mmkv.**

# URL Launcher
-keep class androidx.browser.customtabs.** { *; }

# WebView
-keepclassmembers class * extends android.webkit.WebViewClient {
   public void onReceivedSslError(...);
}

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# PDF ve Excel İşlemleri
-keep class org.apache.poi.** { *; }
-keep class com.itextpdf.** { *; }
-dontwarn org.apache.**
-dontwarn com.itextpdf.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Mobile Scanner (ML Kit)
-keep class com.google.mlkit.vision.barcode.** { *; }
-dontwarn com.google.mlkit.**

# Cached Network Image
-keep class com.github.omniloader.** { *; }
-dontwarn com.github.omniloader.**

# In App Review
-keep class dev.britannio.in_app_review.** { *; }
-dontwarn dev.britannio.in_app_review.**

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# Html Paketi
-keep class org.jsoup.** { *; }
-dontwarn org.jsoup.**

# Encrypt Paketi
-keep class com.example.encrypt.** { *; }
-dontwarn com.example.encrypt.**

# Mrx Charts
-keep class com.mrx.charts.** { *; }
-dontwarn com.mrx.charts.**

# Intl Paketi
-keep class com.example.intl.** { *; }
-dontwarn com.example.intl.**

# Genel Kurallar
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Desugar Desteği
-dontwarn j$.**
-dontwarn java.lang.invoke.**

# Hata Ayıklama için Gereksiz Uyarıları Bastırma
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn sun.misc.**
-dontwarn android.util.**

# Flutter Test ve Geliştirme Araçları
-keep class dev.flutter.plugins.integration_test.** { *; }
-keep class androidx.test.** { *; }

# Play Core Split Install için özel kurallar
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Otomatik oluşturulan dontwarn kuralları
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task