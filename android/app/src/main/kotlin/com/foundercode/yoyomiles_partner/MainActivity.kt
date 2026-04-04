package com.foundercode.yoyomiles_partner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.os.Build
import android.app.KeyguardManager
import android.content.Context
import android.app.NotificationChannel
import android.app.NotificationManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "yoyomiles_partner/app_retain"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 🔥 Notification Channels create kar rahe hain taaki crash na ho
        createNotificationChannels()

        // 🔥 Screen wake up flags for locked screen (Rapido Style)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val serviceChannel = NotificationChannel(
                "SERVICE_CHANNEL",
                "Service Status",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(serviceChannel)

            val bookingChannel = NotificationChannel(
                "BOOKING_CHANNEL_HIGH",
                "Incoming Ride Alerts",
                NotificationManager.IMPORTANCE_HIGH
            )
            bookingChannel.description = "Used for incoming ride requests"
            manager.createNotificationChannel(bookingChannel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openApp") {
                try {
                    val intent = Intent(this, MainActivity::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                                 Intent.FLAG_ACTIVITY_SINGLE_TOP or
                                 Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)

                    // 🔥 Background se samne late waqt screen ON karna
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                        setShowWhenLocked(true)
                        setTurnScreenOn(true)
                    }

                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("OPEN_APP_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
