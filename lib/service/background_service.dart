import 'package:flutter_background_service/flutter_background_service.dart';
import 'socket_service.dart';
import 'ringtone_helper.dart';

/// 🔥 TOP-LEVEL FUNCTION (MANDATORY)
@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) {
  // 🔹 yahan driverId hardcode ya shared pref se lo
  // Abhi test ke liye hardcode:
  const int driverId = 1;

  SocketService().connect(
    baseUrl: "https://yoyo.codescarts.com",
    driverId: driverId,
    onSyncRides: (rides) {
      if (rides.isNotEmpty) {
        RingtoneHelper().start();
      } else {
        RingtoneHelper().stop();
      }
    },
    onNewRide: () {
      RingtoneHelper().start();
    },
    onEmptyRide: () {
      RingtoneHelper().stop();
    },
  );
}

/// 🔥 Service initializer
void initializeBackgroundService() {
  final service = FlutterBackgroundService();

  service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      isForegroundMode: true,

      // 🚨 YAHAN closure NAHI
      onStart: backgroundServiceOnStart,

      // 🔔 same channel as MainActivity.kt
      notificationChannelId: 'BOOKING_CHANNEL',
      initialNotificationTitle: 'Yoyomiles Driver Online',
      initialNotificationContent: 'Waiting for rides',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: backgroundServiceOnStart,
    ),
  );

  service.startService();
}
