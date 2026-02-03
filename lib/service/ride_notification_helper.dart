import 'dart:async';
import 'package:flutter/material.dart';
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
          '❌ Reject',  // emoji adds visual distinction
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
      '🚖 New Ride Request #${bookingData['id']}',
      'Pickup: ${bookingData['pickup_address'] ?? "N/A"}',
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> clear() async {
    _currentBookingData = null;
    await _plugin.cancel(_notificationId);
  }

  static void _onAction(NotificationResponse response) {
    if (_currentBookingData == null) {
      print("⚠️ No booking data available");
      return;
    }

    switch (response.actionId) {
      case 'ACCEPT_RIDE':
        print("✅ Ride Accepted from notification");
        _actionController.add(
          NotificationAction(
            type: ActionType.accept,
            bookingData: _currentBookingData!,
          ),
        );
        clear();
        break;

      case 'REJECT_RIDE':
        print("❌ Ride Rejected from notification");
        _actionController.add(
          NotificationAction(
            type: ActionType.reject,
            bookingData: _currentBookingData!,
          ),
        );
        clear();
        break;

      default:
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