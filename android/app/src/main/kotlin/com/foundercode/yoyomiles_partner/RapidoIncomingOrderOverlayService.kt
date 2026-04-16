//package com.foundercode.yoyomiles_partner
//
//import android.app.Notification
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.app.Service
//import android.content.Context
//import android.content.Intent
//import android.content.pm.ServiceInfo
//import android.graphics.Point
//import android.graphics.PixelFormat
//import android.graphics.drawable.GradientDrawable
//import android.os.Build
//import android.os.Handler
//import android.os.IBinder
//import android.os.Looper
//import android.provider.Settings
//import android.util.Log
//import android.view.Gravity
//import android.view.MotionEvent
//import android.view.View
//import android.view.WindowManager
//import android.widget.Button
//import android.widget.FrameLayout
//import android.widget.ImageView
//import android.widget.LinearLayout
//import android.widget.TextView
//import androidx.core.app.NotificationCompat
//import androidx.core.content.ContextCompat
//
//class RapidoIncomingOrderOverlayService : Service() {
//    private var windowManager: WindowManager? = null
//    private var overlayView: View? = null
//    private var layoutParams: WindowManager.LayoutParams? = null
//    private val tag = "RapidoIncomingOrder"
//
//    private var isMinimized: Boolean = false
//    private val mainHandler = Handler(Looper.getMainLooper())
//    private var scheduledShow: Runnable? = null
//
//    override fun onBind(intent: Intent?): IBinder? = null
//
//    override fun onCreate() {
//        super.onCreate()
//        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//        Log.d(tag, "onStartCommand action=${intent?.action}")
//        when (intent?.action) {
//            ACTION_SCHEDULE_SHOW -> scheduleShow(intent.getLongExtra(EXTRA_DELAY_MS, DEFAULT_DELAY_MS))
//            ACTION_SHOW_NOW -> showNow()
//            ACTION_HIDE -> {
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                    try {
//                        startForegroundCompat()
//                    } catch (_: Throwable) {
//                    }
//                }
//                hideAndStop()
//            }
//            else -> {}
//        }
//        return START_NOT_STICKY
//    }
//
//    override fun onDestroy() {
//        cancelScheduledShow()
//        removeOverlayIfPresent()
//        super.onDestroy()
//    }
//
//    private fun scheduleShow(delayMs: Long) {
//        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
//        if (!canDraw) {
//            Log.d(tag, "scheduleShow: missing overlay permission")
//            hideAndStop()
//            return
//        }
//
//        startForegroundCompat()
//        cancelScheduledShow()
//
//        val runnable = Runnable {
//            showNow()
//        }
//        scheduledShow = runnable
//        mainHandler.postDelayed(runnable, delayMs.coerceAtLeast(0))
//        Log.d(tag, "scheduleShow: scheduled in ${delayMs}ms")
//    }
//
//    private fun cancelScheduledShow() {
//        val r = scheduledShow ?: return
//        mainHandler.removeCallbacks(r)
//        scheduledShow = null
//    }
//
//    private fun showNow() {
//        cancelScheduledShow()
//
//        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
//        if (!canDraw) {
//            Log.d(tag, "showNow: missing overlay permission")
//            hideAndStop()
//            return
//        }
//
//        if (overlayView != null) {
//            Log.d(tag, "showNow: overlay already visible")
//            return
//        }
//
//        // Ensure bubble overlay is not stacked under this card.
//        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_HIDE)
//
//        startForegroundCompat()
//
//        val root = FrameLayout(this).apply {
//            isClickable = false
//            isFocusable = false
//        }
//
//        val expandedCard = buildExpandedCardView(
//            onAccept = {
//                openAppWithRoute(ROUTE_LIVE_RIDE)
//                hideAndStop()
//            },
//            onMinimize = { setMinimized(true) }
//        )
//
//        val bubble = buildBubbleView(
//            onClick = {
//                openApp()
//                hideAndStop()
//            }
//        )
//
//        root.addView(expandedCard)
//        root.addView(bubble)
//
//        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
//        } else {
//            @Suppress("DEPRECATION")
//            WindowManager.LayoutParams.TYPE_PHONE
//        }
//
//        val (screenW, _) = getScreenSizePx()
//        val topInset = getStatusBarHeightPx()
//        layoutParams = WindowManager.LayoutParams(
//            screenW.coerceAtLeast(WindowManager.LayoutParams.WRAP_CONTENT),
//            WindowManager.LayoutParams.WRAP_CONTENT,
//            type,
//            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
//            PixelFormat.TRANSLUCENT
//        ).apply {
//            gravity = Gravity.TOP or Gravity.START
//            x = 0
//            y = topInset + dp(8)
//        }
//
//        overlayView = root
//        windowManager?.addView(overlayView, layoutParams)
//        Log.d(tag, "showNow: overlay added")
//
//        isMinimized = false
//        expandedCard.visibility = View.VISIBLE
//        bubble.visibility = View.GONE
//    }
//
//    private fun setMinimized(minimized: Boolean) {
//        val root = overlayView as? FrameLayout ?: return
//        if (isMinimized == minimized) return
//        isMinimized = minimized
//
//        val expandedCard = root.getChildAt(0)
//        val bubble = root.getChildAt(1)
//        expandedCard.visibility = if (minimized) View.GONE else View.VISIBLE
//        bubble.visibility = if (minimized) View.VISIBLE else View.GONE
//
//        val params = layoutParams ?: return
//        if (minimized) {
//            params.width = dp(70)
//            params.height = dp(70)
//            params.x = dp(12)
//        } else {
//            val (screenW, _) = getScreenSizePx()
//            params.width = screenW.coerceAtLeast(WindowManager.LayoutParams.WRAP_CONTENT)
//            params.height = WindowManager.LayoutParams.WRAP_CONTENT
//            params.x = 0
//        }
//        try {
//            windowManager?.updateViewLayout(overlayView, params)
//        } catch (_: Throwable) {
//        }
//    }
//
//    private fun buildExpandedCardView(
//        onAccept: () -> Unit,
//        onMinimize: () -> Unit
//    ): View {
//        val card = LinearLayout(this).apply {
//            orientation = LinearLayout.VERTICAL
//            // Do not open the app when user taps the card background.
//            isClickable = false
//            isFocusable = false
//
//            val marginH = dp(12)
//            setPadding(dp(12), dp(12), dp(12), dp(12))
//            layoutParams = FrameLayout.LayoutParams(
//                FrameLayout.LayoutParams.MATCH_PARENT,
//                FrameLayout.LayoutParams.WRAP_CONTENT
//            ).apply {
//                leftMargin = marginH
//                rightMargin = marginH
//            }
//
//            background = GradientDrawable().apply {
//                shape = GradientDrawable.RECTANGLE
//                cornerRadius = dp(16).toFloat()
//                setColor(0xFFFFFFFF.toInt())
//            }
//            elevation = dp(8).toFloat()
//        }
//
//        val header = LinearLayout(this).apply {
//            orientation = LinearLayout.HORIZONTAL
//            gravity = Gravity.CENTER_VERTICAL
//        }
//        val icon = ImageView(this).apply {
//            setImageResource(R.mipmap.ic_launcher)
//            layoutParams = LinearLayout.LayoutParams(dp(22), dp(22)).apply {
//                rightMargin = dp(8)
//            }
//        }
//        val title = TextView(this).apply {
//            text = "Bike"
//            setTextColor(0xFF111111.toInt())
//            textSize = 16f
//        }
//        header.addView(icon)
//        header.addView(title)
//        card.addView(header)
//
//        card.addView(spacer(dp(10)))
//        card.addView(buildTwoLineBlock("0.7 Km", "Pickup address"))
//        card.addView(spacer(dp(10)))
//        card.addView(buildTwoLineBlock("6.5 Km", "Drop address"))
//
//        card.addView(spacer(dp(14)))
//
//        val bottom = LinearLayout(this).apply {
//            orientation = LinearLayout.HORIZONTAL
//            gravity = Gravity.CENTER_VERTICAL
//        }
//
//        val minimize = Button(this).apply {
//            text = "-"
//            isAllCaps = false
//            setOnClickListener { onMinimize() }
//            layoutParams = LinearLayout.LayoutParams(dp(52), dp(52)).apply {
//                rightMargin = dp(12)
//            }
//            background = GradientDrawable().apply {
//                shape = GradientDrawable.OVAL
//                setColor(0xFFEDEFF2.toInt())
//            }
//        }
//
//        val accept = Button(this).apply {
//            text = "Accept"
//            isAllCaps = false
//            setTextColor(0xFF111111.toInt())
//            textSize = 18f
//            setOnClickListener { onAccept() }
//            layoutParams = LinearLayout.LayoutParams(0, dp(52), 1f)
//            background = GradientDrawable().apply {
//                shape = GradientDrawable.RECTANGLE
//                cornerRadius = dp(26).toFloat()
//                setColor(0xFFFFD54F.toInt())
//            }
//        }
//
//        bottom.addView(minimize)
//        bottom.addView(accept)
//        card.addView(bottom)
//
//        return card
//    }
//
//    private fun buildTwoLineBlock(distance: String, address: String): View {
//        val box = LinearLayout(this).apply {
//            orientation = LinearLayout.VERTICAL
//        }
//        val distanceTv = TextView(this).apply {
//            text = distance
//            setTextColor(0xFF111111.toInt())
//            textSize = 28f
//        }
//        val addressTv = TextView(this).apply {
//            text = address
//            setTextColor(0xFF111111.toInt())
//            textSize = 16f
//        }
//        box.addView(distanceTv)
//        box.addView(addressTv)
//        return box
//    }
//
//    private fun spacer(heightPx: Int): View {
//        return View(this).apply {
//            layoutParams = LinearLayout.LayoutParams(
//                LinearLayout.LayoutParams.MATCH_PARENT,
//                heightPx
//            )
//        }
//    }
//
//    private fun buildBubbleView(onClick: () -> Unit): View {
//        val bubble = FrameLayout(this).apply {
//            val size = dp(70)
//            layoutParams = FrameLayout.LayoutParams(size, size)
//            foregroundGravity = Gravity.CENTER
//            isClickable = true
//            isFocusable = false
//
//            background = GradientDrawable().apply {
//                shape = GradientDrawable.OVAL
//                setColor(0xFFFFFFFF.toInt())
//            }
//            elevation = dp(6).toFloat()
//        }
//
//        val icon = ImageView(this).apply {
//            setImageResource(R.mipmap.ic_launcher)
//            layoutParams = FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER)
//        }
//        bubble.addView(icon)
//
//        bubble.setOnTouchListener(DragToMoveTouchListener())
//        bubble.setOnClickListener { onClick() }
//        return bubble
//    }
//
//    private fun hideAndStop() {
//        cancelScheduledShow()
//        removeOverlayIfPresent()
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            stopForeground(STOP_FOREGROUND_REMOVE)
//        } else {
//            @Suppress("DEPRECATION")
//            stopForeground(true)
//        }
//        stopSelf()
//    }
//
//    private fun removeOverlayIfPresent() {
//        val view = overlayView ?: return
//        try {
//            windowManager?.removeView(view)
//        } catch (_: Throwable) {
//        }
//        overlayView = null
//        layoutParams = null
//    }
//
//    private fun openApp() {
//        val intent = Intent(this, MainActivity::class.java).apply {
//            addFlags(
//                Intent.FLAG_ACTIVITY_NEW_TASK or
//                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
//                        Intent.FLAG_ACTIVITY_SINGLE_TOP
//            )
//        }
//        startActivity(intent)
//    }
//
//    private fun openAppWithRoute(routeName: String) {
//        val intent = Intent(this, MainActivity::class.java).apply {
//            addFlags(
//                Intent.FLAG_ACTIVITY_NEW_TASK or
//                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
//                        Intent.FLAG_ACTIVITY_SINGLE_TOP
//            )
//            putExtra(EXTRA_NAV_ROUTE, routeName)
//        }
//        startActivity(intent)
//    }
//
//    private fun buildNotification(): Notification {
//        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                NOTIFICATION_CHANNEL_ID,
//                "Incoming order overlay",
//                NotificationManager.IMPORTANCE_MIN
//            )
//            manager.createNotificationChannel(channel)
//        }
//
//        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setContentTitle("Rapido")
//            .setContentText("Incoming order overlay active")
//            .setPriority(NotificationCompat.PRIORITY_MIN)
//            .setOngoing(true)
//            .setCategory(NotificationCompat.CATEGORY_SERVICE)
//            .build()
//    }
//
//    private fun startForegroundCompat() {
//        val notification = buildNotification()
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            startForeground(
//                NOTIFICATION_ID,
//                notification,
//                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
//            )
//        } else {
//            @Suppress("DEPRECATION")
//            startForeground(NOTIFICATION_ID, notification)
//        }
//    }
//
//    private fun dp(value: Int): Int {
//        return (value * resources.displayMetrics.density).toInt()
//    }
//
//    private fun getStatusBarHeightPx(): Int {
//        val resId = resources.getIdentifier("status_bar_height", "dimen", "android")
//        return if (resId > 0) resources.getDimensionPixelSize(resId) else 0
//    }
//
//    private fun getScreenSizePx(): Pair<Int, Int> {
//        val wm = windowManager ?: return Pair(0, 0)
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//            val bounds = wm.currentWindowMetrics.bounds
//            Pair(bounds.width(), bounds.height())
//        } else {
//            @Suppress("DEPRECATION")
//            val display = wm.defaultDisplay
//            val point = Point()
//            @Suppress("DEPRECATION")
//            display.getRealSize(point)
//            Pair(point.x, point.y)
//        }
//    }
//
//    private inner class DragToMoveTouchListener : View.OnTouchListener {
//        private var initialX = 0
//        private var initialY = 0
//        private var initialTouchX = 0f
//        private var initialTouchY = 0f
//        private var isDragging = false
//
//        override fun onTouch(v: View, event: MotionEvent): Boolean {
//            val params = layoutParams ?: return false
//            if (!isMinimized) return false
//
//            when (event.action) {
//                MotionEvent.ACTION_DOWN -> {
//                    initialX = params.x
//                    initialY = params.y
//                    initialTouchX = event.rawX
//                    initialTouchY = event.rawY
//                    isDragging = false
//                    return true
//                }
//
//                MotionEvent.ACTION_MOVE -> {
//                    val dx = (event.rawX - initialTouchX).toInt()
//                    val dy = (event.rawY - initialTouchY).toInt()
//                    if (kotlin.math.abs(dx) > dp(3) || kotlin.math.abs(dy) > dp(3)) {
//                        isDragging = true
//                    }
//
//                    val (screenW, screenH) = getScreenSizePx()
//                    val viewW = params.width
//                    val viewH = params.height
//                    val margin = dp(4)
//
//                    val minX = margin
//                    val minY = margin
//                    val maxX = (screenW - viewW - margin).coerceAtLeast(minX)
//                    val maxY = (screenH - viewH - margin).coerceAtLeast(minY)
//
//                    params.x = (initialX + dx).coerceIn(minX, maxX)
//                    params.y = (initialY + dy).coerceIn(minY, maxY)
//                    windowManager?.updateViewLayout(overlayView, params)
//                    return true
//                }
//
//                MotionEvent.ACTION_UP -> {
//                    if (!isDragging) v.performClick()
//                    return true
//                }
//            }
//
//            return false
//        }
//    }
//
//    companion object {
//        const val ACTION_SCHEDULE_SHOW = "com.fc.rapido_style.action.SCHEDULE_INCOMING_ORDER_OVERLAY"
//        const val ACTION_SHOW_NOW = "com.fc.rapido_style.action.SHOW_INCOMING_ORDER_OVERLAY"
//        const val ACTION_HIDE = "com.fc.rapido_style.action.HIDE_INCOMING_ORDER_OVERLAY"
//
//        const val EXTRA_NAV_ROUTE = "com.fc.rapido_style.extra.NAV_ROUTE"
//        const val EXTRA_DELAY_MS = "com.fc.rapido_style.extra.DELAY_MS"
//
//        const val ROUTE_LIVE_RIDE = "live_ride_screen"
//        const val DEFAULT_DELAY_MS = 60_000L
//
//        private const val NOTIFICATION_CHANNEL_ID = "rapido_incoming_order_overlay"
//        private const val NOTIFICATION_ID = 9201
//
//        fun schedule(context: Context, delayMs: Long = DEFAULT_DELAY_MS) {
//            val intent = Intent(context, RapidoIncomingOrderOverlayService::class.java).apply {
//                action = ACTION_SCHEDULE_SHOW
//                putExtra(EXTRA_DELAY_MS, delayMs)
//            }
//
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                ContextCompat.startForegroundService(context, intent)
//            } else {
//                context.startService(intent)
//            }
//        }
//
//        fun start(context: Context, action: String) {
//            val intent = Intent(context, RapidoIncomingOrderOverlayService::class.java).apply {
//                this.action = action
//            }
//
//            if ((action == ACTION_SCHEDULE_SHOW || action == ACTION_SHOW_NOW) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                ContextCompat.startForegroundService(context, intent)
//            } else {
//                context.startService(intent)
//            }
//        }
//    }
//}

package com.foundercode.yoyomiles_partner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Point
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.content.getSystemService


class RapidoIncomingOrderOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private val tag = "RapidoIncomingOrder"

    private var isMinimized: Boolean = false
    private val mainHandler = Handler(Looper.getMainLooper())
    private var scheduledShow: Runnable? = null

    // ✅ Dynamic ride data — intent extras se aayega
    private var pickup: String = ""
    private var drop: String = ""
    private var distance: String = ""
    private var id: String = ""
    private var amount: String = ""

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Android 8+ ke liye har haal mein startForeground call karna zaroori hai
        // agar startForegroundService() se start kiya gaya hai
        startForegroundCompat()

        when (intent?.action) {
            ACTION_SCHEDULE_SHOW -> {
                // ✅ Pehle data extract karo, phir schedule karo
                pickup   = intent.getStringExtra("pickup")   ?: ""
                drop     = intent.getStringExtra("drop")     ?: ""
                distance = intent.getStringExtra("distance") ?: ""
                id  = intent.getStringExtra("id")  ?: ""
                amount   = intent.getStringExtra("amount")   ?: ""
                Log.d(tag, "Data received — pickup=$pickup drop=$drop distance=$distance id=$id amount=$amount")
                scheduleShow(intent.getLongExtra(EXTRA_DELAY_MS, DEFAULT_DELAY_MS))
            }
            ACTION_SHOW_NOW -> showNow()
            ACTION_HIDE -> hideAndStop()
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        cancelScheduledShow()
        removeOverlayIfPresent()
        super.onDestroy()
    }

    private fun scheduleShow(delayMs: Long) {
        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (!canDraw) {
            Log.d(tag, "scheduleShow: missing overlay permission")
            hideAndStop()
            return
        }

        startForegroundCompat()
        cancelScheduledShow()

        val runnable = Runnable { showNow() }
        scheduledShow = runnable
        mainHandler.postDelayed(runnable, delayMs.coerceAtLeast(0))
        Log.d(tag, "scheduleShow: scheduled in ${delayMs}ms")
    }

    private fun cancelScheduledShow() {
        val r = scheduledShow ?: return
        mainHandler.removeCallbacks(r)
        scheduledShow = null
    }

    private fun showNow() {
        cancelScheduledShow()

        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (!canDraw) {
            Log.d(tag, "showNow: missing overlay permission")
            hideAndStop()
            return
        }

        if (overlayView != null) {
            Log.d(tag, "showNow: overlay already visible")
            return
        }

        // Bubble overlay ko pehle hide karo taaki dono stack na ho
        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_HIDE)

        startForegroundCompat()

        val root = FrameLayout(this).apply {
            isClickable = false
            isFocusable = false
        }

        val expandedCard = buildExpandedCardView(
            onAccept = {
                // ✅ Accept: Flutter ko orderId bhejo, normal route nahi
                sendAcceptToFlutter(id)
                hideAndStop()
            },
            onMinimize = { setMinimized(true) }
        )

        val bubble = buildBubbleView(
            onClick = {
                openApp()
                hideAndStop()
            }
        )

        root.addView(expandedCard)
        root.addView(bubble)

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val (screenW, _) = getScreenSizePx()
        val topInset = getStatusBarHeightPx()
        layoutParams = WindowManager.LayoutParams(
            screenW.coerceAtLeast(WindowManager.LayoutParams.WRAP_CONTENT),
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = topInset + dp(8)
        }

        overlayView = root
        windowManager?.addView(overlayView, layoutParams)
        Log.d(tag, "showNow: overlay added")

        isMinimized = false
        expandedCard.visibility = View.VISIBLE
        bubble.visibility = View.GONE
    }

    private fun setMinimized(minimized: Boolean) {
        val root = overlayView as? FrameLayout ?: return
        if (isMinimized == minimized) return
        isMinimized = minimized

        val expandedCard = root.getChildAt(0)
        val bubble = root.getChildAt(1)
        expandedCard.visibility = if (minimized) View.GONE else View.VISIBLE
        bubble.visibility = if (minimized) View.VISIBLE else View.GONE

        val params = layoutParams ?: return
        if (minimized) {
            params.width = dp(70)
            params.height = dp(70)
            params.x = dp(12)
        } else {
            val (screenW, _) = getScreenSizePx()
            params.width = screenW.coerceAtLeast(WindowManager.LayoutParams.WRAP_CONTENT)
            params.height = WindowManager.LayoutParams.WRAP_CONTENT
            params.x = 0
        }
        try {
            windowManager?.updateViewLayout(overlayView, params)
        } catch (_: Throwable) {
        }
    }

    private fun buildExpandedCardView(
        onAccept: () -> Unit,
        onMinimize: () -> Unit
    ): View {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            isClickable = false
            isFocusable = false

            val marginH = dp(12)
            setPadding(dp(12), dp(12), dp(12), dp(12))
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                leftMargin = marginH
                rightMargin = marginH
            }

            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(16).toFloat()
                setColor(0xFFFFFFFF.toInt())
            }
            elevation = dp(8).toFloat()
        }

        // Header: icon + title (amount bhi dikhao)
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        val icon = ImageView(this).apply {
            setImageResource(R.mipmap.ic_launcher)
            layoutParams = LinearLayout.LayoutParams(dp(22), dp(22)).apply {
                rightMargin = dp(8)
            }
        }
        val title = TextView(this).apply {
            text = if (amount.isNotBlank()) "Bike  •  ₹$amount" else "Bike"
            setTextColor(0xFF111111.toInt())
            textSize = 16f
        }

        header.addView(icon)
        header.addView(title)
        card.addView(header)

        card.addView(spacer(dp(10)))

        // ✅ Pickup block: distance + pickup address
        card.addView(buildTwoLineBlock(
            if (distance.isNotBlank()) "${distance} Km" else "– Km",
            if (pickup.isNotBlank()) pickup else "Pickup"
        ))
        card.addView(spacer(dp(10)))
        card.addView(buildTwoLineBlock(
            "Drop",
            if (drop.isNotBlank()) drop else "Drop address"
        ))

        card.addView(spacer(dp(14)))

        val bottom = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val minimize = Button(this).apply {
            text = "-"
            isAllCaps = false
            setOnClickListener { onMinimize() }
            layoutParams = LinearLayout.LayoutParams(dp(52), dp(52)).apply {
                rightMargin = dp(12)
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xFFEDEFF2.toInt())
            }
        }

        val accept = Button(this).apply {
            text = "Accept"
            isAllCaps = false
            setTextColor(0xFF111111.toInt())
            textSize = 18f
            setOnClickListener { onAccept() }
            layoutParams = LinearLayout.LayoutParams(0, dp(52), 1f)
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(26).toFloat()
                setColor(0xFFFFD54F.toInt())
            }
        }

        bottom.addView(minimize)
        bottom.addView(accept)
        card.addView(bottom)

        return card
    }

    // ✅ topText = distance/label, bottomText = address (wrapping ke liye maxLines)
    private fun buildTwoLineBlock(topText: String, bottomText: String): View {
        val box = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }
        val topTv = TextView(this).apply {
            text = topText
            setTextColor(0xFF111111.toInt())
            textSize = 22f
        }
        val bottomTv = TextView(this).apply {
            text = bottomText
            setTextColor(0xFF555555.toInt())
            textSize = 14f
            maxLines = 2
            ellipsize = android.text.TextUtils.TruncateAt.END
        }
        box.addView(topTv)
        box.addView(bottomTv)
        return box
    }

    private fun spacer(heightPx: Int): View {
        return View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                heightPx
            )
        }
    }

    private fun buildBubbleView(onClick: () -> Unit): View {
        val bubble = FrameLayout(this).apply {
            val size = dp(70)
            layoutParams = FrameLayout.LayoutParams(size, size)
            foregroundGravity = Gravity.CENTER
            isClickable = true
            isFocusable = false

            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xFFFFFFFF.toInt())
            }
            elevation = dp(6).toFloat()
        }

        val icon = ImageView(this).apply {
            setImageResource(R.mipmap.ic_launcher)
            layoutParams = FrameLayout.LayoutParams(dp(36), dp(36), Gravity.CENTER)
        }
        bubble.addView(icon)

        bubble.setOnTouchListener(DragToMoveTouchListener())
        bubble.setOnClickListener { onClick() }
        return bubble
    }

    // ✅ Accept: app ko foreground mein laao aur Flutter ko orderId bhejo
    private fun sendAcceptToFlutter(id: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            putExtra(EXTRA_NAV_ROUTE, ROUTE_ACCEPT_RIDE)
            putExtra(EXTRA_ORDER_ID, id)
        }
        startActivity(intent)
    }

    private fun hideAndStop() {
        cancelScheduledShow()
        removeOverlayIfPresent()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun removeOverlayIfPresent() {
        val view = overlayView ?: return
        try {
            windowManager?.removeView(view)
        } catch (_: Throwable) {
        }
        overlayView = null
        layoutParams = null
    }

    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        }
        startActivity(intent)
    }

    private fun openAppWithRoute(routeName: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
            putExtra(EXTRA_NAV_ROUTE, routeName)
        }
        startActivity(intent)
    }

    // RapidoIncomingOrderOverlayService.kt ke andar buildNotification function mein
    private fun buildNotification(): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Incoming order overlay",
                NotificationManager.IMPORTANCE_LOW // MIN ki jagah LOW try karein
            )
            manager.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Rapido")
            .setContentText("Incoming order overlay active")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun startForegroundCompat() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            @Suppress("DEPRECATION")
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    private fun getStatusBarHeightPx(): Int {
        val resId = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (resId > 0) resources.getDimensionPixelSize(resId) else 0
    }

    private fun getScreenSizePx(): Pair<Int, Int> {
        val wm = windowManager ?: return Pair(0, 0)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = wm.currentWindowMetrics.bounds
            Pair(bounds.width(), bounds.height())
        } else {
            @Suppress("DEPRECATION")
            val display = wm.defaultDisplay
            val point = Point()
            @Suppress("DEPRECATION")
            display.getRealSize(point)
            Pair(point.x, point.y)
        }
    }

    private inner class DragToMoveTouchListener : View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var initialTouchX = 0f
        private var initialTouchY = 0f
        private var isDragging = false

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val params = layoutParams ?: return false
            if (!isMinimized) return false

            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isDragging = false
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()
                    if (kotlin.math.abs(dx) > dp(3) || kotlin.math.abs(dy) > dp(3)) {
                        isDragging = true
                    }

                    val (screenW, screenH) = getScreenSizePx()
                    val viewW = params.width
                    val viewH = params.height
                    val margin = dp(4)

                    val minX = margin
                    val minY = margin
                    val maxX = (screenW - viewW - margin).coerceAtLeast(minX)
                    val maxY = (screenH - viewH - margin).coerceAtLeast(minY)

                    params.x = (initialX + dx).coerceIn(minX, maxX)
                    params.y = (initialY + dy).coerceIn(minY, maxY)
                    windowManager?.updateViewLayout(overlayView, params)
                    return true
                }

                MotionEvent.ACTION_UP -> {
                    if (!isDragging) v.performClick()
                    return true
                }
            }

            return false
        }
    }

    companion object {
        const val ACTION_SCHEDULE_SHOW = "com.fc.rapido_style.action.SCHEDULE_INCOMING_ORDER_OVERLAY"
        const val ACTION_SHOW_NOW      = "com.fc.rapido_style.action.SHOW_INCOMING_ORDER_OVERLAY"
        const val ACTION_HIDE          = "com.fc.rapido_style.action.HIDE_INCOMING_ORDER_OVERLAY"

        const val EXTRA_NAV_ROUTE  = "com.fc.rapido_style.extra.NAV_ROUTE"
        const val EXTRA_DELAY_MS   = "com.fc.rapido_style.extra.DELAY_MS"
        // ✅ New extras
        const val EXTRA_ORDER_ID   = "com.fc.rapido_style.extra.ORDER_ID"

        // ✅ New route constant for accept action
        const val ROUTE_ACCEPT_RIDE = "accept_ride_action"
        const val ROUTE_LIVE_RIDE   = "live_ride_screen"

        const val DEFAULT_DELAY_MS = 0L   // ✅ Ab 0 — socket se turant aayega

        private const val NOTIFICATION_CHANNEL_ID = "rapido_incoming_order_overlay"
        private const val NOTIFICATION_ID = 9201

        fun schedule(context: Context, delayMs: Long = DEFAULT_DELAY_MS) {
            val intent = Intent(context, RapidoIncomingOrderOverlayService::class.java).apply {
                action = ACTION_SCHEDULE_SHOW
                putExtra(EXTRA_DELAY_MS, delayMs)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ContextCompat.startForegroundService(context, intent)
            } else {
                context.startService(intent)
            }
        }

        fun start(context: Context, action: String) {
            val intent = Intent(context, RapidoIncomingOrderOverlayService::class.java).apply {
                this.action = action
            }
            if ((action == ACTION_SCHEDULE_SHOW || action == ACTION_SHOW_NOW) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ContextCompat.startForegroundService(context, intent)
            } else {
                context.startService(intent)
            }
        }
    }
}