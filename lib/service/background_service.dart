import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'ringtone_helper.dart';

@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  // Initialize notification helper in background isolate
  await RideNotificationHelper.init();
  print("✅ Background service started");

  service.on('START_RINGTONE').listen((data) {
    print("🔔 START_RINGTONE received");

    if (!RingtoneHelper().isPlaying) {
      RingtoneHelper().start();
    }

    // ✅ FIXED: Background isolate mein overlay directly nahi dikhta
    // Main UI isolate ko signal bhejo
    if (data != null) {
      service.invoke('UI_SHOW_OVERLAY', data); // <-- Yeh add karo
    }
    // ❌ HATA DO: RideNotificationHelper.showIncomingRide(data) yahan se
  });

  FlutterBackgroundService().on('UI_SHOW_OVERLAY').listen((data) async {
    if (data != null) {
      print("📺 UI_SHOW_OVERLAY received in main isolate");
      await RideNotificationHelper.showIncomingRide(
        Map<String, dynamic>.from(data),
      );
    }
  });

  service.on('STOP_RINGTONE').listen((_) {
    print("🔕 STOP_RINGTONE received in background");
    RingtoneHelper().stop();
    RideNotificationHelper.clear();
  });

  service.on('ACCEPT_RIDE_FROM_OVERLAY').listen((data) {
    RingtoneHelper().stop();
    service.invoke('UI_ACCEPT_RIDE', data);
  });

  service.on('REJECT_RIDE_FROM_OVERLAY').listen((data) {
    RingtoneHelper().stop();
    service.invoke('UI_REJECT_RIDE', data);
  });

  service.on('stopService').listen((_) {
    RingtoneHelper().stop();
    service.stopSelf();
  });
}

Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) {
    RingtoneHelper().stop();
    service.invoke("stopService");
  }
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
