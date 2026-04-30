package com.foundercode.yoyomiles_partner

import android.annotation.SuppressLint
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Point
import android.graphics.Typeface
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
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class RapidoIncomingOrderOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private val tag = "RapidoIncomingOrder"

    private val mainHandler = Handler(Looper.getMainLooper())
    private var scheduledShow: Runnable? = null

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
        when (intent?.action) {
            ACTION_SCHEDULE_SHOW -> {
                pickup   = intent.getStringExtra("pickup")   ?: ""
                drop     = intent.getStringExtra("drop")     ?: ""
                // Priority to pickup_distance_km for overlay
                distance = intent.getStringExtra("pickup_distance_km") 
                           ?: intent.getStringExtra("distance") 
                           ?: ""
                id       = intent.getStringExtra("id")       ?: ""
                amount   = intent.getStringExtra("amount")   ?: ""
                scheduleShow(intent.getLongExtra(EXTRA_DELAY_MS, DEFAULT_DELAY_MS))
            }
            ACTION_SHOW_NOW -> showNow()
            ACTION_HIDE -> hideAndStop()
        }
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        hideAndStop()
    }

    override fun onDestroy() {
        cancelScheduledShow()
        removeOverlayIfPresent()
        super.onDestroy()
    }

    private fun scheduleShow(delayMs: Long) {
        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (!canDraw) { hideAndStop(); return }
        cancelScheduledShow()
        val runnable = Runnable { showNow() }
        scheduledShow = runnable
        mainHandler.postDelayed(runnable, delayMs.coerceAtLeast(0))
    }

    private fun cancelScheduledShow() {
        scheduledShow?.let { mainHandler.removeCallbacks(it) }
        scheduledShow = null
    }

    private fun showNow() {
        cancelScheduledShow()
        val canDraw = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (!canDraw || overlayView != null) return

        RapidoBubbleOverlayService.start(this, RapidoBubbleOverlayService.ACTION_HIDE)

        val root = FrameLayout(this).apply {
            isClickable = false
            isFocusable = false
        }

        val expandedCard = buildExpandedCardView(
            onAccept = {
                sendAcceptToFlutter(id)
                IncomingOrderFirebaseService.stopIncomingOrderAlert(this@RapidoIncomingOrderOverlayService)
            },
            onIgnore = {
                sendIgnoreToFlutter(id)
                IncomingOrderFirebaseService.stopIncomingOrderAlert(this@RapidoIncomingOrderOverlayService)
            }
        )

        root.addView(expandedCard)

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                   else @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE

        val (screenW, _) = getScreenSizePx()
        layoutParams = WindowManager.LayoutParams(
            screenW, WindowManager.LayoutParams.WRAP_CONTENT,
            type, WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = 0
            y = dp(20)
        }

        overlayView = root
        windowManager?.addView(overlayView, layoutParams)
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun buildExpandedCardView(onAccept: () -> Unit, onIgnore: () -> Unit): View {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT).apply {
                setMargins(dp(20), 0, dp(20), 0)
            }
            background = GradientDrawable().apply {
                cornerRadius = dp(28).toFloat()
                setColor(Color.WHITE)
            }
            elevation = dp(16).toFloat()
        }

        // Close Button (Top Right)
        val closeContainer = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(24))
        }
        val closeBtn = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_close_clear_cancel)
            setColorFilter(Color.GRAY)
            layoutParams = FrameLayout.LayoutParams(dp(24), dp(24)).apply { gravity = Gravity.END }
            setOnClickListener { onIgnore() }
        }
        closeContainer.addView(closeBtn)
        card.addView(closeContainer)

        // Amount Section
        val amountTv = TextView(this).apply {
            text = "₹$amount"
            textSize = 34f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#1A237E"))
            gravity = Gravity.CENTER
        }
        card.addView(amountTv)

        // Distance Badge (Pickup Distance)
        val distanceBadge = TextView(this).apply {
            text = "● Pickup $distance km away"
            textSize = 14f
            setTextColor(Color.parseColor("#2E7D32"))
            setPadding(dp(14), dp(6), dp(14), dp(6))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.CENTER
                topMargin = dp(8)
            }
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#F5F5F5"))
                cornerRadius = dp(20).toFloat()
            }
        }
        card.addView(distanceBadge)
        card.addView(spacer(dp(24)))

        // Timeline Address Section (Match Lock Screen Style)
        val addressRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val timeline = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(dp(30), LinearLayout.LayoutParams.WRAP_CONTENT)
        }
        val greenDot = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(dp(10), dp(10))
            background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(Color.parseColor("#4CAF50")) }
        }
        val line = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(dp(2), dp(40))
            setBackgroundColor(Color.LTGRAY)
        }
        val redDot = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(dp(10), dp(10))
            background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(Color.parseColor("#F44336")) }
        }
        timeline.addView(greenDot); timeline.addView(line); timeline.addView(redDot)

        val texts = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            setPadding(dp(8), 0, 0, 0)
        }
        texts.addView(TextView(this).apply { text = pickup; setTextColor(Color.BLACK); textSize = 15f; maxLines = 2 })
        texts.addView(spacer(dp(30)))
        texts.addView(TextView(this).apply { text = drop; setTextColor(Color.DKGRAY); textSize = 15f; maxLines = 2 })

        addressRow.addView(timeline); addressRow.addView(texts)
        card.addView(addressRow)
        card.addView(spacer(dp(24)))

        // SLIDER (YELLOW)
        val slideContainer = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(64))
            background = GradientDrawable().apply { 
                cornerRadius = dp(32).toFloat()
                setColor(Color.parseColor("#FFD600")) 
            }
        }

        val slideText = TextView(this).apply {
            text = "Slide to Accept"; gravity = Gravity.CENTER; textSize = 18f; setTypeface(null, Typeface.BOLD); setTextColor(Color.BLACK)
            layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        }
        
        val knob = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(dp(56), dp(56)).apply { gravity = Gravity.START or Gravity.CENTER_VERTICAL; leftMargin = dp(4) }
            background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(Color.WHITE) }
            elevation = dp(4).toFloat()
            addView(ImageView(this@RapidoIncomingOrderOverlayService).apply {
                setImageResource(android.R.drawable.ic_media_play); setColorFilter(Color.BLACK)
                layoutParams = FrameLayout.LayoutParams(dp(24), dp(24), Gravity.CENTER)
            })
        }

        slideContainer.addView(slideText); slideContainer.addView(knob)

        knob.setOnTouchListener(object : View.OnTouchListener {
            private var dX = 0f
            override fun onTouch(v: View, event: MotionEvent): Boolean {
                val maxSlide = slideContainer.width - v.width - dp(8)
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> { dX = v.x - event.rawX }
                    MotionEvent.ACTION_MOVE -> {
                        var newX = event.rawX + dX
                        if (newX < dp(4)) newX = dp(4).toFloat()
                        if (newX > maxSlide) newX = maxSlide.toFloat()
                        v.x = newX
                    }
                    MotionEvent.ACTION_UP -> {
                        if (v.x > maxSlide * 0.8) {
                            v.x = maxSlide.toFloat(); slideText.text = "Accepted!"; v.visibility = View.GONE
                            onAccept()
                        } else {
                            v.animate().x(dp(4).toFloat()).setDuration(200).start()
                        }
                    }
                }
                return true
            }
        })

        card.addView(slideContainer)
        return card
    }

    private fun spacer(h: Int) = View(this).apply { layoutParams = LinearLayout.LayoutParams(-1, h) }

    private fun sendAcceptToFlutter(id: String) {
        val i = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(EXTRA_NAV_ROUTE, ROUTE_ACCEPT_RIDE); putExtra(EXTRA_ORDER_ID, id)
            putExtra("pickup_address", pickup); putExtra("drop_address", drop)
            putExtra("distance", distance); putExtra("amount", amount)
        }
        startActivity(i)
        hideAndStop()
    }

    private fun sendIgnoreToFlutter(id: String) {
        val i = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(EXTRA_NAV_ROUTE, ROUTE_IGNORE_RIDE); putExtra(EXTRA_ORDER_ID, id)
        }
        startActivity(i)
        hideAndStop()
    }

    private fun hideAndStop() {
        removeOverlayIfPresent()
        stopSelf()
    }

    private fun removeOverlayIfPresent() {
        overlayView?.let { try { windowManager?.removeView(it) } catch (_: Throwable) {} }
        overlayView = null
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()
    private fun getStatusBarHeightPx(): Int {
        val id = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else 0
    }

    private fun getScreenSizePx(): Pair<Int, Int> {
        val wm = windowManager ?: return Pair(0,0)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val b = wm.currentWindowMetrics.bounds
            Pair(b.width(), b.height())
        } else {
            val p = Point()
            @Suppress("DEPRECATION") wm.defaultDisplay.getRealSize(p)
            Pair(p.x, p.y)
        }
    }

    companion object {
        const val ACTION_SCHEDULE_SHOW = "com.fc.rapido_style.action.SCHEDULE_INCOMING_ORDER_OVERLAY"
        const val ACTION_SHOW_NOW      = "com.fc.rapido_style.action.SHOW_INCOMING_ORDER_OVERLAY"
        const val ACTION_HIDE          = "com.fc.rapido_style.action.HIDE_INCOMING_ORDER_OVERLAY"
        const val EXTRA_NAV_ROUTE      = "com.fc.rapido_style.extra.NAV_ROUTE"
        const val EXTRA_DELAY_MS       = "com.fc.rapido_style.extra.DELAY_MS"
        const val EXTRA_ORDER_ID       = "com.fc.rapido_style.extra.ORDER_ID"
        const val ROUTE_ACCEPT_RIDE    = "accept_ride_action"
        const val ROUTE_IGNORE_RIDE    = "ignore_ride_action"
        const val ROUTE_LIVE_RIDE      = "live_ride_screen"
        const val DEFAULT_DELAY_MS     = 0L
        fun start(context: Context, action: String) {
            context.startService(Intent(context, RapidoIncomingOrderOverlayService::class.java).apply { this.action = action })
        }
    }
}
