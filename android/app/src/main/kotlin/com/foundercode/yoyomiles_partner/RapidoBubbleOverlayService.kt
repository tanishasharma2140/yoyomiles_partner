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
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class RapidoBubbleOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private val tag = "RapidoBubbleOverlay"

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(tag, "onStartCommand action=${intent?.action}")
        when (intent?.action) {
            ACTION_SHOW -> show()
            ACTION_HIDE -> {
                hideAndStop()
            }
            else -> {}
        }
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        Log.d(tag, "onTaskRemoved: App killed from recents → removing bubble")
        hideAndStop()
    }

    override fun onDestroy() {
        removeOverlayIfPresent()
        super.onDestroy()
    }

    private fun show() {
        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (!canDraw) {
            Log.d(tag, "show: missing overlay permission")
            hideAndStop()
            return
        }

        if (overlayView != null) return

        val root = FrameLayout(this).apply {
            val size = dp(70)
            layoutParams = FrameLayout.LayoutParams(size, size)
            foregroundGravity = Gravity.CENTER
            isClickable = true
            isFocusable = false

            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xfffeca1f.toInt())
            }
            elevation = dp(6).toFloat()
        }

        val icon = ImageView(this).apply {
            setImageResource(R.mipmap.ic_launcher)
            layoutParams = FrameLayout.LayoutParams(dp(50), dp(50), Gravity.CENTER)
        }
        root.addView(icon)

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        layoutParams = WindowManager.LayoutParams(
            dp(70),
            dp(70),
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = dp(12)
            y = getStatusBarHeightPx() + dp(120)
        }

        root.setOnTouchListener(DragToMoveTouchListener())
        root.setOnClickListener { openApp() }

        overlayView = root
        windowManager?.addView(overlayView, layoutParams)
        Log.d(tag, "show: overlay added")
    }

    private fun hideAndStop() {
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
        const val ACTION_SHOW = "com.fc.rapido_style.action.SHOW_BUBBLE_OVERLAY"
        const val ACTION_HIDE = "com.fc.rapido_style.action.HIDE_BUBBLE_OVERLAY"

        fun start(context: Context, action: String) {
            val intent = Intent(context, RapidoBubbleOverlayService::class.java).apply {
                this.action = action
            }

            if (action == ACTION_SHOW && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
}
