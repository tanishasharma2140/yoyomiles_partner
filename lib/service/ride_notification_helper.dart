import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;

class RideNotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  
  static final _actionController = StreamController<NotificationAction>.broadcast();
  static Stream<NotificationAction> get actionStream => _actionController.stream;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
  }

  static Future<void> showIncomingRide(Map<String, dynamic> bookingData) async {
    if (bookingData.isEmpty) return;

    try {
      bool isActive = await overlay.FlutterOverlayWindow.isActive();
      if (isActive) {
        await overlay.FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 300)); // 200 se badhaao
      }

      bool hasPermission = await overlay.FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        debugPrint("⚠️ No overlay permission");
        return;
      }

      await overlay.FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        overlayTitle: "New Ride Request",
        overlayContent: "You have a new ride request",
        flag: overlay.OverlayFlag.defaultFlag,
        alignment: overlay.OverlayAlignment.center,
        visibility: overlay.NotificationVisibility.visibilityPublic,
        positionGravity: overlay.PositionGravity.auto,
        height: overlay.WindowSize.matchParent,
        width: overlay.WindowSize.matchParent,
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      await overlay.FlutterOverlayWindow.shareData(bookingData);
      print("✅ Overlay shown and data shared");

    } catch (e) {
      print("❌ Overlay Error: $e");
    }
  }

  static Future<void> clear() async {
    try {
      await overlay.FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      print("Error closing overlay: $e");
    }
    FlutterBackgroundService().invoke('STOP_RINGTONE');
  }

  static void triggerAction(ActionType type, Map<String, dynamic> bookingData) {
    _actionController.add(NotificationAction(type: type, bookingData: bookingData));
    if (type == ActionType.reject) clear();
  }

  static void dispose() {
    _actionController.close();
  }
}

enum ActionType { accept, reject, openTripStatus }

class NotificationAction {
  final ActionType type;
  final Map<String, dynamic> bookingData;
  NotificationAction({required this.type, required this.bookingData});
}
