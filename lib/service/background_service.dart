import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'socket_service.dart';
import 'ringtone_helper.dart';

@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  await RideNotificationHelper.init();
  print("jkhjjkhjkhjkhhjkjhjkh");
  service.on('STOP_RINGTONE').listen((_) {
    RingtoneHelper().stop();
  });

  service.on('START_RINGTONE').listen((_) {
    if (!RingtoneHelper().isPlaying) {
      RingtoneHelper().start();
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final int? driverId = prefs.getInt('token');

  if (driverId == null) {
    print('❌ Driver ID not found');
    return;
  }
  print("start connecting....");
  SocketService().connect(
    baseUrl: "https://admin.yoyomiles.com",
    driverId: driverId,

    onSyncRides: (rides) {
      if (rides.isNotEmpty) {
        RingtoneHelper().start();
        RideNotificationHelper.showIncomingRide(rides.first);
      } else {
        RingtoneHelper().stop();
        RideNotificationHelper.clear(fromBackground: true);
      }
    },

    onNewRide: () {
      if (!RingtoneHelper().isPlaying) {
        RingtoneHelper().start();
      }
    },

    onEmptyRide: () {
      RingtoneHelper().stop();
      RideNotificationHelper.clear(fromBackground: true);
    },
  );
}

Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();

  final isRunning = await service.isRunning();
  if (isRunning) {
    print("🛑 Stopping background service...");

    // 🔕 Stop ringtone
    RingtoneHelper().stop();

    // 🧹 Clear notifications
    RideNotificationHelper.clear(fromBackground: true);

    // 🔌 Disconnect socket
    SocketService().disconnect();

    // 🛑 Stop service
    service.invoke("stopService");
  }
}

/// 🔥 Service initializer
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  print('FlutterBackgroundService');
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
    await service.startService(); // ✅ only once
  }
}
