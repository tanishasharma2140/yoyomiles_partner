import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RideNotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const int _notificationId = 999;

  // 🔥 Stream controller for notification actions
  static final _actionController = StreamController<NotificationAction>.broadcast();
  static Stream<NotificationAction> get actionStream => _actionController.stream;

  // 🔥 Store booking data for later use
  static Map<String, dynamic>? _currentBookingData;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onAction,
    );
  }

  static Future<void> showIncomingRide(Map<String, dynamic> bookingData) async {
    // 🔥 Store booking data
    _currentBookingData = bookingData;

    const androidDetails = AndroidNotificationDetails(
      'BOOKING_CHANNEL',
      'Booking Alerts',
      channelDescription: 'Incoming ride requests',

      importance: Importance.max,
      priority: Priority.high,

      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,

      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      timeoutAfter: null,

      color: Color(0xFF2196F3),
      colorized: true,

      actions: [
        // 🔥 Simple actions without icons (NO contextual)
        AndroidNotificationAction(
          'REJECT_RIDE',
          '❌ Ignore',  // emoji adds visual distinction
          cancelNotification: false,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'ACCEPT_RIDE',
          '✅ Accept',  // emoji adds visual distinction
          cancelNotification: false,
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      _notificationId,
      '🚖 New Ride Request',
      'Pickup: ${bookingData['pickup_address'] ?? "N/A"}',
      NotificationDetails(
        android: androidDetails,
      ),
      payload: jsonEncode(bookingData), // 🔥 IMPORTANT
    );
  }

  static Future<void> clear({bool fromBackground = false}) async {
    _currentBookingData = null;

    if (!fromBackground) {
      // ✅ ONLY UI isolate should invoke background
      FlutterBackgroundService().invoke('STOP_RINGTONE');
    }

    await _plugin.cancel(_notificationId);
  }




  static void _onAction(NotificationResponse response) {
    if (response.payload == null) {
      print("❌ Payload is NULL");
      return;
    }

    final Map<String, dynamic> bookingData =
    jsonDecode(response.payload!);

    print("🔥 NOTIFICATION ACTION TAPPED");
    print("👉 ACTION ID: ${response.actionId}");
    print("📦 DATA: $bookingData");

    switch (response.actionId) {
      case 'ACCEPT_RIDE':
        print("✅ ACCEPT CLICK WORKING");
        _actionController.add(
          NotificationAction(
            type: ActionType.accept,
            bookingData: bookingData,
          ),
        );
        // clear();
        break;

      case 'REJECT_RIDE':
        print("❌ REJECT CLICK WORKING");
        _actionController.add(
          NotificationAction(
            type: ActionType.reject,
            bookingData: bookingData,
          ),
        );
        clear();
        break;
    }
  }

  static void dispose() {
    _actionController.close();
  }
}

// 🔥 Action types
enum ActionType { accept, reject }

// 🔥 Action model
class NotificationAction {
  final ActionType type;
  final Map<String, dynamic> bookingData;

  NotificationAction({
    required this.type,
    required this.bookingData,
  });
}