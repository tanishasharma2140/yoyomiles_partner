import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'ringtone_helper.dart';

@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  await RideNotificationHelper.init();
  print("✅ Background service started");



  service.on('START_RINGTONE').listen((_) {
    print("🔔 START_RINGTONE received in background");
    if (!RingtoneHelper().isPlaying) {
      RingtoneHelper().start();
      service.invoke('START_VIBRATION'); // ✅ UI isolate ko vibration signal
    }
  });

  service.on('STOP_RINGTONE').listen((_) {
    print("🔕 STOP_RINGTONE received in background");
    RingtoneHelper().stop();
    service.invoke('STOP_VIBRATION'); // ✅ UI isolate ko vibration stop signal
  });

  // ✅ Service stop
  service.on('stopService').listen((_) {
    print("🛑 Background service stopping...");
    RingtoneHelper().stop();
    service.stopSelf();
  });
}

Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();

  final isRunning = await service.isRunning();
  if (isRunning) {
    print("🛑 Stopping background service...");
    RingtoneHelper().stop();
    RideNotificationHelper.clear(fromBackground: true);
    service.invoke("stopService");
  }
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  print('FlutterBackgroundService init');

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

  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
    print("✅ Background service started");
  }
}