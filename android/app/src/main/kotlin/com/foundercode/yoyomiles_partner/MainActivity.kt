package com.foundercode.yoyomiles_partner

import android.content.Context
import android.content.pm.PackageManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.annotation.UiThread
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "rapido_background_button"
    private val tag = "RapidoOverlay"
    private var channel: MethodChannel? = null
    private var isOnlineFromFlutter: Boolean = false
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null
    private val REQUEST_CODE_POST_NOTIFICATIONS = 1001

    private val prefsName = "rapido_online_prefs"
    private val prefsKeyIsOnline = "is_online"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel = methodChannel
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setOnline" -> {
                    val online = (call.argument<Boolean>("online") ?: false)
                    setOnlineState(online)
                    result.success(null)
                }

                "scheduleIncomingOrderOverlay" -> {

                    val delayMs = call.argument<Number>("delayMs")?.toLong()
                        ?: RapidoIncomingOrderOverlayService.DEFAULT_DELAY_MS

                    // ✅ Overlay sirf screen ON mein schedule ho.
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val screenOn = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                        pm.isInteractive
                    } else {
                        @Suppress("DEPRECATION")
                        pm.isScreenOn
                    }
                    if (!screenOn) {
                        Log.d(tag, "scheduleIncomingOrderOverlay: screen is OFF → ignoring overlay schedule")
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    val pickup = call.argument<String>("pickup") ?: ""
                    val drop = call.argument<String>("drop") ?: ""
                    // Check for both keys
                    val distance = call.argument<String>("pickup_distance_km") 
                                   ?: call.argument<String>("distance") 
                                   ?: ""
                    val id = call.argument<String>("id")
                        ?: call.argument<String>("orderId")
                        ?: ""
                    val amount = call.argument<String>("amount") ?: ""

                    val intent = Intent(this, RapidoIncomingOrderOverlayService::class.java).apply {
                        action = RapidoIncomingOrderOverlayService.ACTION_SCHEDULE_SHOW
                        putExtra("pickup", pickup)
                        putExtra("drop", drop)
                        putExtra("pickup_distance_km", distance)
                        putExtra("distance", distance)
                        putExtra("id", id)
                        putExtra("amount", amount)
                        putExtra(RapidoIncomingOrderOverlayService.EXTRA_DELAY_MS, delayMs)
                    }

                    startService(intent)
                    result.success(true)
                }

                "cancelIncomingOrderOverlay" -> {
                    RapidoIncomingOrderOverlayService.start(this, RapidoIncomingOrderOverlayService.ACTION_HIDE)
                    result.success(null)
                }

                "stopIncomingOrderAlert" -> {
                    IncomingOrderFirebaseService.stopIncomingOrderAlert(this)
                    result.success(null)
                }

                "hasOverlayPermission" -> {
                    val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(has)
                }

                "getLaunchRoute" -> {
                    val route = consumeRouteFromIntent(intent)
                    result.success(route)
                }

                "getFirebaseToken" -> {
                    val token = getSharedPreferences("rapido_fcm_prefs", Context.MODE_PRIVATE)
                        .getString("fcm_token", null)
                    result.success(token)
                }

                "requestPermissions" -> {
                    // Android overlay permission cannot be granted via runtime popup.
                    // We can only navigate user to the system settings page.
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                    }
                    result.success(null)
                }

                "hasNotificationPermission" -> {
                    val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    } else {
                        true
                    }
                    result.success(hasPermission)
                }

                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        result.success(true)
                        return@setMethodCallHandler
                    }

                    val hasPermission = checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    if (hasPermission) {
                        result.success(true)
                        return@setMethodCallHandler
                    }

                    if (pendingNotificationPermissionResult != null) {
                        result.error("pending_request", "Notification permission request already in progress", null)
                        return@setMethodCallHandler
                    }

                    pendingNotificationPermissionResult = result
                    requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), REQUEST_CODE_POST_NOTIFICATIONS)
                }

                "showBackgroundButton" -> {
                    val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    if (has) {
                        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_SHOW)
                    }
                    result.success(has)
                }

                "hideBackgroundButton" -> {
                    RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_HIDE)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setOnlineState(online: Boolean) {
        isOnlineFromFlutter = online
        getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(prefsKeyIsOnline, online)
            .apply()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val route = consumeRouteFromIntent(intent) ?: return
        try {
            // ✅ Accept/Ignore tap from lock-screen / overlay must hit APIs.
            if (route == RapidoIncomingOrderOverlayService.ROUTE_ACCEPT_RIDE ||
                route == RapidoIncomingOrderOverlayService.ROUTE_IGNORE_RIDE
            ) {
                val orderId = intent.getStringExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID) ?: ""
                if (orderId.isBlank()) return

                if (route == RapidoIncomingOrderOverlayService.ROUTE_ACCEPT_RIDE) {
                    val pickup = intent.getStringExtra("pickup_address") ?: ""
                    val drop = intent.getStringExtra("drop_address") ?: ""
                    val distance = intent.getStringExtra("distance") ?: ""
                    val amount = intent.getStringExtra("amount") ?: ""

                    val data = mapOf<String, String>(
                        "id" to orderId,
                        "pickup_address" to pickup,
                        "drop_address" to drop,
                        "distance" to distance,
                        "amount" to amount,
                    )
                    channel?.invokeMethod("onOverlayAcceptRide", data)
                } else {
                    val data = mapOf<String, String>("id" to orderId)
                    channel?.invokeMethod("onOverlayIgnoreRide", data)
                }
                return
            }

            channel?.invokeMethod("navigateTo", route)
        } catch (t: Throwable) {
            Log.w(tag, "Failed to invoke navigateTo($route)", t)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_POST_NOTIFICATIONS) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingNotificationPermissionResult?.success(granted)
            pendingNotificationPermissionResult = null
        }
    }

    private fun consumeRouteFromIntent(intent: Intent?): String? {
        if (intent == null) return null
        val route = intent.getStringExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE)
        if (route.isNullOrBlank()) return null
        // Avoid re-navigation on config changes.
        intent.removeExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE)
        return route
    }

    override fun onPause() {
        super.onPause()

        Log.d(tag, "onPause: canDrawOverlays=${Settings.canDrawOverlays(this)}")

        // If overlay permission is missing, do nothing here.
        // Permission request should be user-driven (via in-app dialog -> requestPermissions).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) return

        // Respect Flutter ONLINE/OFFLINE.
        if (!isOnlineFromFlutter) return

        // App is going to background: show the bubble.
        Log.d(tag, "Starting overlay service: SHOW")
        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_SHOW)
    }

    override fun onResume() {
        super.onResume()
        // App is in foreground: hide bubble.
        Log.d(tag, "onResume: Starting overlay service: HIDE")
        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_HIDE)
        RapidoIncomingOrderOverlayService.start(this, RapidoIncomingOrderOverlayService.ACTION_HIDE)
        IncomingOrderNotification.cancel(this)
    }
}
