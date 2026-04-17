import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'ringtone_helper.dart';

@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Yoyomiles Driver Online",
      content: "Waiting for rides...",
    );
  }



  // await RideNotificationHelper.init();

  service.on('START_RINGTONE').listen((data) async {
    print("🔔 START_RINGTONE");

    if (!RingtoneHelper().isPlaying) {
      await RingtoneHelper().start();
    }
  });

  service.on('STOP_RINGTONE').listen((_) {
    print("🔕 STOP_RINGTONE");

    RingtoneHelper().stop();
    // RideNotificationHelper.clear();
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