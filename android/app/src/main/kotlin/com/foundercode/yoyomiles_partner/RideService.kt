package com.foundercode.yoyomiles_partner

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.foundercode.yoyomiles_partner.R

class RideService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        val channelId = "ride_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Ride Channel",
                NotificationManager.IMPORTANCE_HIGH
            )

            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Incoming Ride")
            .setContentText("Opening ride request...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .build()

        startForeground(1, notification)

        val i = Intent(this, MainActivity::class.java)
        i.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        )

        i.putExtra("ride_data", intent?.getStringExtra("ride_data"))

        startActivity(i)

        stopSelf()

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}