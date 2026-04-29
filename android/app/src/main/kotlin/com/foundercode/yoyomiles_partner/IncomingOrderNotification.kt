package com.foundercode.yoyomiles_partner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object IncomingOrderNotification {
    private const val tag = "IncomingOrderNotification"
    private const val CHANNEL_ID = "incoming_order_urgent"
    private const val CHANNEL_NAME = "Incoming order alerts"
    private const val NOTIFICATION_ID = 9301

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existingChannel = manager.getNotificationChannel(CHANNEL_ID)
        if (existingChannel != null) {
            val needsRecreate = existingChannel.importance < NotificationManager.IMPORTANCE_HIGH ||
                    existingChannel.sound != null ||
                    existingChannel.vibrationPattern != null ||
                    existingChannel.lockscreenVisibility != Notification.VISIBILITY_PUBLIC
            if (needsRecreate) {
                manager.deleteNotificationChannel(CHANNEL_ID)
            }
        }

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            enableVibration(false)
            vibrationPattern = null
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)
        Log.d(tag, "ensureChannel: created channel id=$CHANNEL_ID importance=${channel.importance}")
    }

    fun show(
        context: Context,
        orderId: String,
        pickupAddress: String,
        dropAddress: String,
        distance: String = "",
        amount: String = "",
        routeName: String = RapidoIncomingOrderOverlayService.ROUTE_LIVE_RIDE
    ) {
        ensureChannel(context)

        val fullScreenIntent = Intent(context, IncomingOrderLockScreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE, routeName)
            putExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID, orderId)
            putExtra("pickup_address", pickupAddress)
            putExtra("drop_address", dropAddress)
            putExtra("distance", distance)
            putExtra("amount", amount)
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            2001,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
//            .setContentTitle("Incoming order")
//            .setContentText("You have a new order")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOnlyAlertOnce(true)
            .setOngoing(false)
            .setAutoCancel(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .build()

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        try {
            Log.d(tag, "notify notification id=$NOTIFICATION_ID channel=$CHANNEL_ID route=$routeName")
            manager.notify(NOTIFICATION_ID, notification)
        } catch (error: Throwable) {
            Log.e(tag, "Failed to notify incoming order", error)
        }
    }

    fun cancel(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }
}
