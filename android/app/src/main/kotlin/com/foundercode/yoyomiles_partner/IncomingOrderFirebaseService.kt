package com.foundercode.yoyomiles_partner

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.WindowManager
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.util.Locale

class IncomingOrderFirebaseService : FirebaseMessagingService() {
    private val tag = "IncomingOrderFCM"

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        val data = remoteMessage.data
        Log.d(tag, "onMessageReceived data=$data")

        val rawType = data["type"]?.toString()
        val type = rawType?.trim()?.lowercase(Locale.US)
        
        val orderId = data["ride_id"]?.toString()
            ?: data["rideId"]?.toString()
            ?: data["order_id"]?.toString()
            ?: ""

        // ✅ remove_ride → Turant sab kuch band karo
        if (type == "remove_ride") {
            Log.d(tag, "remove_ride received for orderId=$orderId → Stopping all alerts and UI")
            stopIncomingOrderAlert(this)
            return
        }

        val incomingOrder = type == "incoming_order" || data["incoming_order"] == "1"
        if (!incomingOrder) return

        startIncomingOrderAlert(this)

        val pickup = data["pickup_address"]?.toString().orEmpty()
        val drop = data["drop_address"]?.toString().orEmpty()
        val distance = data["pickup_distance_km"]?.toString() 
                       ?: data["distance"]?.toString() 
                       ?: ""
        val amount = data["amount"]?.toString().orEmpty()

        val isScreenOn = isScreenOn(this)

        if (!isScreenOn) {
            // Screen is OFF: Wake up and show Lock Screen Activity
            wakeScreenBriefly()
            val lockIntent = Intent(this, IncomingOrderLockScreenActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID, orderId)
                putExtra("pickup_address", pickup)
                putExtra("drop_address", drop)
                putExtra("pickup_distance_km", distance)
                putExtra("amount", amount)
            }
            startActivity(lockIntent)
        } else {
            // Screen is ON: Show Overlay
            val overlayIntent = Intent(this, RapidoIncomingOrderOverlayService::class.java).apply {
                action = RapidoIncomingOrderOverlayService.ACTION_SCHEDULE_SHOW
                putExtra("pickup", pickup)
                putExtra("drop", drop)
                putExtra("pickup_distance_km", distance)
                putExtra("distance", distance)
                putExtra("id", orderId)
                putExtra("amount", amount)
            }
            startService(overlayIntent)
        }

        // We are NOT calling IncomingOrderNotification.show() anymore 
        // because the user wants NO status bar notification.
    }

    private fun isScreenOn(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT_WATCH) {
            pm.isInteractive
        } else {
            @Suppress("DEPRECATION")
            pm.isScreenOn
        }
    }

    private fun wakeScreenBriefly() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        @Suppress("DEPRECATION")
        val wakeLock = pm.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "yoyo:incoming_order"
        )
        wakeLock.acquire(10_000L)
    }

    companion object {
        const val ACTION_REMOVE_INCOMING_ORDER_UI =
            "com.foundercode.yoyomiles_partner.ACTION_REMOVE_INCOMING_ORDER_UI"

        private var mediaPlayer: MediaPlayer? = null
        private var vibrator: Vibrator? = null

        @Synchronized
        fun startIncomingOrderAlert(context: Context) {
            try {
                val appCtx = context.applicationContext
                if (mediaPlayer?.isPlaying == true) return

                vibrator = appCtx.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()

                val pattern = longArrayOf(0, 800, 400, 800)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0), audioAttributes)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator?.vibrate(pattern, 0)
                }

                mediaPlayer?.release()
                val resId = appCtx.resources.getIdentifier("driver_ringtone", "raw", appCtx.packageName)
                if (resId != 0) {
                    mediaPlayer = MediaPlayer.create(appCtx, resId)
                } else {
                    val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                        ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                    mediaPlayer = MediaPlayer().apply { setDataSource(appCtx, alarmUri!!) }
                }

                mediaPlayer?.apply {
                    setAudioAttributes(audioAttributes)
                    isLooping = true
                    if (resId == 0) prepare()
                    start()
                }
            } catch (t: Throwable) {
                Log.e("IncomingOrderFCM", "startAlert error", t)
            }
        }

        @Synchronized
        fun stopIncomingOrderAlert(context: Context) {
            try {
                val appCtx = context.applicationContext
                
                // 1. Stop Sound
                mediaPlayer?.let { if (it.isPlaying) it.stop() }
                mediaPlayer?.release()
                mediaPlayer = null
                
                // 2. Stop Vibration
                vibrator?.cancel()
                vibrator = null
                
                // 3. Remove Notification
                IncomingOrderNotification.cancel(appCtx)
                
                // 4. Remove Overlay Card
                RapidoIncomingOrderOverlayService.start(appCtx, RapidoIncomingOrderOverlayService.ACTION_HIDE)
                
                // 5. Close Lock Screen Activity (via Broadcast)
                val removeIntent = Intent(ACTION_REMOVE_INCOMING_ORDER_UI).apply {
                    setPackage(appCtx.packageName)
                }
                appCtx.sendBroadcast(removeIntent)
                
                Log.d("IncomingOrderFCM", "All alerts and UI components stopped.")
            } catch (t: Throwable) {
                Log.e("IncomingOrderFCM", "stopAlert error", t)
            }
        }
    }
}
