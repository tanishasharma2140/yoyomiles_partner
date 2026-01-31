//package com.foundercode.yoyomiles_partner
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()
//
package com.foundercode.yoyomiles_partner

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
            createBookingChannel()
        }
    }

    private fun createBookingChannel() {
        val soundUri = Uri.parse(
            "android.resource://$packageName/raw/booking_ring"
        )

        val channel = NotificationChannel(
            "BOOKING_CHANNEL",
            "Booking Alerts",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build()
            )
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
}

