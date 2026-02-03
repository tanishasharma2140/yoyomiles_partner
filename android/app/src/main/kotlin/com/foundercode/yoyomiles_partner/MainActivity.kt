package com.foundercode.yoyomiles_partner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createServiceChannel()   // 🔹 Background service
            recreateBookingChannel() // 🔔 Incoming ride
        }
    }

    // 🔹 FOREGROUND SERVICE CHANNEL (LOW importance)
    private fun createServiceChannel() {
        val channel = NotificationChannel(
            "SERVICE_CHANNEL",
            "Background Service",
            NotificationManager.IMPORTANCE_LOW
        )

        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    // 🔔 RIDE / CALL CHANNEL (HIGH importance, sticky)
    private fun recreateBookingChannel() {
        val manager = getSystemService(NotificationManager::class.java)

        // 🔥 IMPORTANT: delete old channel so rules refresh
        manager.deleteNotificationChannel("BOOKING_CHANNEL")

        val soundUri = Uri.parse(
            "android.resource://$packageName/raw/booking_ring"
        )

        val channel = NotificationChannel(
            "BOOKING_CHANNEL",
            "Booking Alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Incoming ride requests"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(true)

            setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build()
            )
        }

        manager.createNotificationChannel(channel)
    }
}
