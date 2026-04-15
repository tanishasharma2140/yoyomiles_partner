//package com.foundercode.yoyomiles_partner
//
//import android.content.Intent
//import android.net.Uri
//import android.os.Build
//import android.provider.Settings
//import android.util.Log
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//    private val channelName = "rapido_background_button"
//    private val tag = "RapidoOverlay"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//                    "hasOverlayPermission" -> {
//                        val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                            Settings.canDrawOverlays(this)
//                        } else {
//                            true
//                        }
//                        result.success(has)
//                    }
//
//                    "requestPermissions" -> {
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
//                            val intent = Intent(
//                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
//                                Uri.parse("package:$packageName")
//                            )
//                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                            startActivity(intent)
//                        }
//                        result.success(null)
//                    }
//
//                    "showBackgroundButton" -> {
//                        val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                            Settings.canDrawOverlays(this)
//                        } else {
//                            true
//                        }
//                        if (has) {
//                            RapidoOverlayService.start(this, RapidoOverlayService.ACTION_SHOW)
//                        }
//                        result.success(has)
//                    }
//
//                    "hideBackgroundButton" -> {
//                        RapidoOverlayService.start(this, RapidoOverlayService.ACTION_HIDE)
//                        result.success(null)
//                    }
//
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    override fun onPause() {
//        super.onPause()
//
//        Log.d(tag, "onPause: canDrawOverlays=${Settings.canDrawOverlays(this)}")
//
//        // Do NOT auto-open Settings here (client-friendly UX).
//        // Permission request should be user-driven from Flutter dialog -> requestPermissions.
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) return
//
//        Log.d(tag, "Starting overlay service: SHOW")
//        RapidoOverlayService.start(this, RapidoOverlayService.ACTION_SHOW)
//    }
//
//    override fun onResume() {
//        super.onResume()
//        Log.d(tag, "onResume: Starting overlay service: HIDE")
//        RapidoOverlayService.start(this, RapidoOverlayService.ACTION_HIDE)
//    }
//}

package com.foundercode.yoyomiles_partner

import android.content.Intent
import android.net.Uri
import android.os.Build
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel = methodChannel
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setOnline" -> {
                    val online = (call.argument<Boolean>("online") ?: false)
                    isOnlineFromFlutter = online
                    result.success(null)
                }

                "scheduleIncomingOrderOverlay" -> {

                    val delayMs = call.argument<Number>("delayMs")?.toLong()
                        ?: RapidoIncomingOrderOverlayService.DEFAULT_DELAY_MS

                    val pickup = call.argument<String>("pickup") ?: ""
                    val drop = call.argument<String>("drop") ?: ""
                    val distance = call.argument<String>("distance") ?: ""

                    val intent = Intent(this, RapidoIncomingOrderOverlayService::class.java).apply {
                        action = RapidoIncomingOrderOverlayService.ACTION_SCHEDULE_SHOW
                        putExtra("pickup", pickup)
                        putExtra("drop", drop)
                        putExtra("distance", distance)
                        putExtra(RapidoIncomingOrderOverlayService.EXTRA_DELAY_MS, delayMs)
                    }

                    startService(intent)
                    result.success(true)
                }

                "cancelIncomingOrderOverlay" -> {
                    RapidoIncomingOrderOverlayService.start(this, RapidoIncomingOrderOverlayService.ACTION_HIDE)
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

    @UiThread
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val route = intent.getStringExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE)
        if (route.isNullOrBlank()) return

        // Accept ride special case
        if (route == RapidoIncomingOrderOverlayService.ROUTE_ACCEPT_RIDE) {
            val orderId = intent.getStringExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID) ?: ""
            intent.removeExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE)
            intent.removeExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID)
            try {
                channel?.invokeMethod("onOverlayAcceptRide", mapOf("orderId" to orderId))
            } catch (t: Throwable) {
                Log.w(tag, "Failed to invoke onOverlayAcceptRide", t)
            }
            return
        }

        // Normal navigation
        intent.removeExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE)
        try {
            channel?.invokeMethod("navigateTo", route)
        } catch (t: Throwable) {
            Log.w(tag, "Failed to invoke navigateTo($route)", t)
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
    }
}