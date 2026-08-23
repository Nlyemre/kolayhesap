package com.kolayhesap.app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.content.pm.PackageManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import android.Manifest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "notification_settings"
    private val NOTIFICATION_CHANNEL_ID = "task_reminders"
    private val SOUND_CHANNEL = "com.kolayhesap.app/sound"
    private lateinit var soundManager: SoundManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        soundManager = SoundManager()
    }

    override fun onDestroy() {
        soundManager.stopSound()
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "checkPermission" -> {
                        result.success(checkNotificationPermission())
                    }
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    "checkAlarmPermission" -> {
                        result.success(checkAlarmPermission())
                    }
                    "openAlarmPermissionSettings" -> {
                        openAlarmPermissionSettings()
                        result.success(null)
                    }
                    "scheduleTaskNotification" -> {
                        val taskId = call.argument<String>("taskId") ?: ""
                        val title = call.argument<String>("title") ?: ""
                        val body = call.argument<String>("body") ?: ""
                        val timestamp = call.argument<Long>("timestamp") ?: 0L
                        scheduleNotification(taskId, title, body, timestamp)
                        result.success(null)
                    }
                    "cancelTaskNotification" -> {
                        val taskId = call.argument<String>("taskId") ?: ""
                        cancelNotification(taskId)
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOUND_CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "playSound" -> {
                        val frequency = call.argument<Int>("frequency") ?: 440
                        val volume = call.argument<Double>("volume") ?: 0.5
                        soundManager.playSound(frequency, volume.toFloat())
                        result.success(null)
                    }
                    "stopSound" -> {
                        soundManager.stopSound()
                        result.success(null)
                    }
                    "updateFrequency" -> {
                        val frequency = call.argument<Int>("frequency") ?: 440
                        soundManager.updateFrequency(frequency)
                        result.success(null)
                    }
                    "updateVolume" -> {
                        val volume = call.argument<Double>("volume") ?: 0.5
                        soundManager.updateVolume(volume.toFloat())
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("SOUND_ERROR", e.message, null)
            }
        }
    }

    private fun checkAlarmPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        } else {
            true
        }
    }

   private fun openAlarmPermissionSettings() {
    try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ için modern yol
            val alarmIntent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(alarmIntent)
        } else {
            // Android 11 ve altı için genel ayarlar
            openGenericAppSettings()
        }
    } catch (e: Exception) {
        // Herhangi bir hata durumunda fallback
        openGenericAppSettings()
    }
}

private fun openGenericAppSettings() {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
        data = Uri.parse("package:$packageName")
    }
    startActivity(intent)
}

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Task Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for task reminders"
            }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }
    }

    private fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        }
        startActivity(intent)
    }

    private fun checkNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun scheduleNotification(taskId: String, title: String, body: String, timestamp: Long) {
        val intent = Intent(this, NotificationBroadcastReceiver::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("title", title)
            putExtra("body", body)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            taskId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        (getSystemService(Context.ALARM_SERVICE) as AlarmManager).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
            } else {
                setExact(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
            }
        }
    }

    private fun cancelNotification(taskId: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(taskId.hashCode())

        val intent = Intent(this, NotificationBroadcastReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            taskId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
    }
}
