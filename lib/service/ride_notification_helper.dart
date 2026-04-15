import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  RideNotificationHelper.handleBackgroundAction(response);
}

class RideNotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const int _notificationId = 999;

  static const String _bookingChannelId = 'BOOKING_CHANNEL_HIGH';
  static const String _serviceChannelId = 'SERVICE_CHANNEL';

  static final _actionController = StreamController<NotificationAction>.broadcast();
  static Stream<NotificationAction> get actionStream => _actionController.stream;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    const AndroidNotificationChannel bookingChannel = AndroidNotificationChannel(
      _bookingChannelId,
      'Incoming Ride Alerts',
      description: 'Used for incoming ride requests',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
      _serviceChannelId,
      'Service Status',
      importance: Importance.low,
    );

    await androidPlugin?.createNotificationChannel(bookingChannel);
    await androidPlugin?.createNotificationChannel(serviceChannel);

    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onAction,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> showIncomingRide(Map<String, dynamic> bookingData) async {
    if (bookingData.isEmpty || bookingData['id'] == null) return;

    final String pickup = bookingData['pickup_address'] ?? "N/A";
    final String drop = bookingData['drop_address'] ?? "N/A";
    final String fare = "₹${bookingData['amount'] ?? '0'}";

    final bigTextStyle = BigTextStyleInformation(
      "<br>📍 <b>PICKUP:</b> $pickup<br><br>"
      "🏁 <b>DROP:</b> $drop<br><br>"
          "<center><b><big>💰 EARNING: $fare</big></b></center><br>",
      htmlFormatBigText: true,
      contentTitle: "<b>🚖 New Ride Request ($fare)</b>",
      htmlFormatContentTitle: true,
      summaryText: "New Ride Available",
    );

    final androidDetails = AndroidNotificationDetails(
      _bookingChannelId,
      'Booking Alerts',
      styleInformation: bigTextStyle,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      color: const Color(0xFFFFC107), // Rapido yellow
      colorized: true,
      actions: [
        const AndroidNotificationAction(
          'REJECT_RIDE',
          '    IGNORE RIDE    ',
          cancelNotification: true,
          showsUserInterface: true,
          titleColor: Color(0xFFF44336),
        ),
        const AndroidNotificationAction(
          'ACCEPT_RIDE',
          '    ACCEPT RIDE    ', // Extra spaces for wider look on some devices
          showsUserInterface: true,
          titleColor: PortColor.gold,
        ),
      ],
    );

    await _plugin.show(
      _notificationId,
      '🚖 New Ride Request ($fare)',
      '📍 $pickup\n🏁 $drop\n💰 Earning: $fare',
      NotificationDetails(android: androidDetails),
      payload: jsonEncode(bookingData),
    );
  }

  static Future<void> clear({bool fromBackground = false}) async {
    if (!fromBackground) {
      FlutterBackgroundService().invoke('STOP_RINGTONE');
    }
    await _plugin.cancel(_notificationId);
  }

  static void handleBackgroundAction(NotificationResponse response) {
    if (response.payload == null) return;
    final bookingData = jsonDecode(response.payload!);

    switch (response.actionId) {
      case 'ACCEPT_RIDE':
        _actionController.add(NotificationAction(type: ActionType.accept, bookingData: bookingData));
        break;
      case 'REJECT_RIDE':
        _actionController.add(NotificationAction(type: ActionType.reject, bookingData: bookingData));
        clear(fromBackground: true);
        break;
      default:
        _actionController.add(NotificationAction(type: ActionType.showPopup, bookingData: bookingData));
        break;
    }
  }

  static void _onAction(NotificationResponse response) {
    if (response.payload == null) return;
    final Map<String, dynamic> bookingData = jsonDecode(response.payload!);

    if (response.actionId == null) {
      _actionController.add(NotificationAction(type: ActionType.showPopup, bookingData: bookingData));
      return;
    }

    if (response.actionId == 'ACCEPT_RIDE') {
      _actionController.add(NotificationAction(type: ActionType.accept, bookingData: bookingData));
    } else if (response.actionId == 'REJECT_RIDE') {
      _actionController.add(NotificationAction(type: ActionType.reject, bookingData: bookingData));
      clear();
    }
  }
}

enum ActionType { accept, reject, openTripStatus, showPopup }

class NotificationAction {
  final ActionType type;
  final Map<String, dynamic> bookingData;
  NotificationAction({required this.type, required this.bookingData});
}
