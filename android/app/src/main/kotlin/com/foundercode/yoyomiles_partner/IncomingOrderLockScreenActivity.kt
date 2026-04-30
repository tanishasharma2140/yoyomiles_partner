package com.foundercode.yoyomiles_partner

import android.annotation.SuppressLint
import android.app.Activity
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class IncomingOrderLockScreenActivity : Activity() {

    private var removeReceiver: BroadcastReceiver? = null

    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Standard Lock Screen Flags
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }

        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager?.requestDismissKeyguard(this, null)
        }

        // Close UI if remove_ride broadcast received
        removeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                finish()
            }
        }
        val filter = IntentFilter(IncomingOrderFirebaseService.ACTION_REMOVE_INCOMING_ORDER_UI)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(removeReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(removeReceiver, filter)
        }

        IncomingOrderNotification.cancel(this)

        val orderId = intent.getStringExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID) ?: ""
        val pickupAddress = intent.getStringExtra("pickup_address") ?: "N/A"
        val dropAddress = intent.getStringExtra("drop_address") ?: "N/A"
        val pickupDistanceKm = intent.getStringExtra("pickup_distance_km") 
                                ?: intent.getStringExtra("distance") 
                                ?: "N/A"
        val amount = intent.getStringExtra("amount") ?: ""

        // Root View with Dimmed Background
        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#99000000")) // Semi-transparent black
        }

        // Centered Card Container
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(20), dp(20), dp(20))
            val lp = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
                setMargins(dp(24), 0, dp(24), 0)
            }
            layoutParams = lp
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = dp(28).toFloat()
            }
            elevation = dp(16).toFloat()
        }

        // Earnings
        val earningsTv = TextView(this).apply {
            text = "₹$amount"
            textSize = 34f
            setTypeface(null, Typeface.BOLD)
            setTextColor(Color.parseColor("#1A237E"))
            gravity = Gravity.CENTER
        }
        card.addView(earningsTv)

        // Distance Pill
        val distanceBadge = TextView(this).apply {
            text = "● Pickup $pickupDistanceKm km away"
            textSize = 14f
            setTextColor(Color.parseColor("#2E7D32"))
            setPadding(dp(14), dp(6), dp(14), dp(6))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
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

        // Timeline Address Section
        val addressRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        // Timeline indicators (line and dots)
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
        texts.addView(TextView(this).apply { text = pickupAddress; setTextColor(Color.BLACK); textSize = 15f; maxLines = 2 })
        texts.addView(spacer(dp(30)))
        texts.addView(TextView(this).apply { text = dropAddress; setTextColor(Color.DKGRAY); textSize = 15f; maxLines = 2 })

        addressRow.addView(timeline); addressRow.addView(texts)
        card.addView(addressRow)
        card.addView(spacer(dp(30)))

        // --- YELLOW SLIDE TO ACCEPT ---
        val slideContainer = FrameLayout(this).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(64))
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFD600"))
                cornerRadius = dp(32).toFloat()
            }
        }

        val slideText = TextView(this).apply {
            text = "Slide to Accept"
            gravity = Gravity.CENTER
            setTextColor(Color.BLACK)
            textSize = 18f
            setTypeface(null, Typeface.BOLD)
            layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
        }

        val knob = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(dp(56), dp(56)).apply {
                gravity = Gravity.START or Gravity.CENTER_VERTICAL
                leftMargin = dp(4)
            }
            background = GradientDrawable().apply { setColor(Color.WHITE); shape = GradientDrawable.OVAL }
            elevation = dp(4).toFloat()
            addView(ImageView(this@IncomingOrderLockScreenActivity).apply {
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
                            IncomingOrderFirebaseService.stopIncomingOrderAlert(this@IncomingOrderLockScreenActivity)
                            val mainIntent = Intent(this@IncomingOrderLockScreenActivity, MainActivity::class.java).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                                putExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE, RapidoIncomingOrderOverlayService.ROUTE_ACCEPT_RIDE)
                                putExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID, orderId)
                                putExtra("pickup_address", pickupAddress)
                                putExtra("drop_address", dropAddress)
                                putExtra("distance", pickupDistanceKm)
                                putExtra("amount", amount)
                            }
                            startActivity(mainIntent); finish()
                        } else {
                            v.animate().x(dp(4).toFloat()).setDuration(200).start()
                        }
                    }
                }
                return true
            }
        })
        card.addView(slideContainer)

        // Dismiss text outside card
        val dismiss = TextView(this).apply {
            text = "Ignore Order"
            setTextColor(Color.WHITE)
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(0, dp(40), 0, 0)
            layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
                bottomMargin = dp(60)
            }
            setOnClickListener {
                IncomingOrderFirebaseService.stopIncomingOrderAlert(this@IncomingOrderLockScreenActivity)
                val ignoreIntent = Intent(this@IncomingOrderLockScreenActivity, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra(RapidoIncomingOrderOverlayService.EXTRA_NAV_ROUTE, RapidoIncomingOrderOverlayService.ROUTE_IGNORE_RIDE)
                    putExtra(RapidoIncomingOrderOverlayService.EXTRA_ORDER_ID, orderId)
                }
                startActivity(ignoreIntent)
                finish()
            }
        }

        root.addView(card)
        root.addView(dismiss)
        setContentView(root)
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()
    private fun spacer(h: Int) = View(this).apply { layoutParams = LinearLayout.LayoutParams(-1, h) }

    override fun onDestroy() {
        try { removeReceiver?.let { unregisterReceiver(it) } } catch (_: Throwable) {}
        super.onDestroy()
    }
}
