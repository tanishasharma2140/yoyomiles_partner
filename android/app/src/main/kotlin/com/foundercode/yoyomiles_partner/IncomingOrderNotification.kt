package com.foundercode.yoyomiles_partner

import android.app.NotificationManager
import android.content.Context
import android.util.Log

object IncomingOrderNotification {
    private const val tag = "IncomingOrderNotification"
    private const val NOTIFICATION_ID = 9301

    fun ensureChannel(context: Context) {
        // No longer needed
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
        // Disabled status bar notification as per user request ("nh show karana hai")
        Log.d(tag, "show: Status bar notification is disabled.")
    }

    fun cancel(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }
}
