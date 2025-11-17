import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  NotificationService({required this.navigatorKey});

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ✅ Request Permission
  Future<void> requestedNotificationPermission() async {
    await Permission.notification.request();

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    debugPrint("🔔 Permission status: ${settings.authorizationStatus}");
  }

  // ✅ Get Device Token
  Future<String> getDeviceToken() async {
    await messaging.requestPermission();
    String? token = await messaging.getToken();
    debugPrint("✅ FCM Token: $token");
    return token ?? "";
  }

  // ✅ Local Notification Init
  void initLocalNotification(BuildContext context, RemoteMessage message) async {
    var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInit = const DarwinInitializationSettings();

    var settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        handleMassage(message);
      },
    );
  }

  // ✅ Firebase foreground listener
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print("🔔 Notification Received:");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");

      if (Platform.isAndroid) {
        initLocalNotification(context, message);

        /// ✅ Run Profile API safely
        _runProfileApiSafe();

        /// ✅ Show Notification
        showNotification(message);
      }
    });
  }

  // ✅ SAFE Profile API runner (context optional)
  void _runProfileApiSafe() {
    final ctx = navigatorKey.currentContext;

    if (ctx != null) {
      print("✅ Context available → Running Profile API");
      ProfileViewModel().profileApi(ctx);
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => Register()),
      );
    } else {
      print("⚠️ No context → Running Profile API without context");
      ProfileViewModel().profileApi(ctx); // ← Modify API to accept null
    }
  }

  // ✅ Show Push Notification
  Future<void> showNotification(RemoteMessage message) async {
    final androidData = message.notification?.android;

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      androidData?.channelId ?? "default_channel",
      androidData?.channelId ?? "Default Channel",
      importance: Importance.high,
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      fullScreenIntent: true,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    NotificationDetails settings = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      settings,
    );
  }

  // ✅ Background / Killed State Notifications
  Future<void> setupInteractMassage(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMassage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMassage(message);
      }
    });
  }

  // ✅ SAFEST Navigation
  Future<void> handleMassage(RemoteMessage message) async {
    BuildContext? ctx = navigatorKey.currentContext;

    if (ctx == null) {
      print("⏳ Waiting for context for navigation...");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newCtx = navigatorKey.currentContext;
        if (newCtx != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => Register()),
          );
        } else {
          print("❌ Still no context — navigation failed");
        }
      });

      return;
    }

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => Register()),
    );
  }
}
