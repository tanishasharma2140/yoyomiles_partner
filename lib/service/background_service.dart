import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'ringtone_helper.dart';

@pragma('vm:entry-point')

void backgroundServiceOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized(); // ✅ ADD THIS

  /// ✅ Foreground notification (MANDATORY)
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Yoyomiles Driver Online",
      content: "Waiting for rides...",
    );
  }

  await RideNotificationHelper.init();
  print("✅ Background service started");

  service.on('START_RINGTONE').listen((data) async {
    print("🔔 START_RINGTONE received");

    if (!RingtoneHelper().isPlaying) {
      RingtoneHelper().start();
    }

    if (data != null) {
      final rideData = Map<String, dynamic>.from(data);

      // ✅ MethodChannel hata diya — background isolate mein kaam nahi karta
      // ✅ Seedha main UI ko signal bhejo, woh overlay dikhayega
      service.invoke('UI_SHOW_OVERLAY', rideData);
    }
  });  service.on('STOP_RINGTONE').listen((_) {
    print("🔕 STOP_RINGTONE");
    RingtoneHelper().stop();
    RideNotificationHelper.clear();
  });

  service.on('ACCEPT_RIDE_FROM_OVERLAY').listen((data) async {
    print("✅ ACCEPT FROM OVERLAY (BACKGROUND)");

    RingtoneHelper().stop();

    /// send to main UI
    service.invoke('UI_ACCEPT_RIDE', data);
  });

  service.on('REJECT_RIDE_FROM_OVERLAY').listen((data) async {
    print("❌ REJECT FROM OVERLAY (BACKGROUND)");

    RingtoneHelper().stop();

    /// send to main UI
    service.invoke('UI_REJECT_RIDE', data);
  });

  service.on('stopService').listen((_) {
    RingtoneHelper().stop();
    service.stopSelf();
  });
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      isForegroundMode: true,
      onStart: backgroundServiceOnStart,
      notificationChannelId: 'SERVICE_CHANNEL',
      initialNotificationTitle: 'Yoyomiles Driver Online',
      initialNotificationContent: 'Waiting for rides...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: backgroundServiceOnStart,
    ),
  );

  if (!(await service.isRunning())) {
    await service.startService();
  }
}

Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    RingtoneHelper().stop();
    service.invoke("stopService");
  }
}