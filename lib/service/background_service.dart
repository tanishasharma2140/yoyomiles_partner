import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'socket_service.dart';
import 'ringtone_helper.dart';

/// 🔥 TOP-LEVEL FUNCTION (MANDATORY)
@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  // 🔥 VERY IMPORTANT
  await RideNotificationHelper.init();

  const int driverId = 1;

  SocketService().connect(
    baseUrl: "https://yoyo.codescarts.com",
    driverId: driverId,

    onSyncRides: (rides) {
      if (rides.isNotEmpty) {
        RingtoneHelper().start();

        // 🔥 Pass first ride data to notification
        RideNotificationHelper.showIncomingRide(rides.first);
      } else {
        RingtoneHelper().stop();
        RideNotificationHelper.clear();
      }
    },

    onNewRide: () {
      // 🔥 Simple callback without parameter
      RingtoneHelper().start();
      // Notification already shown in onSyncRides
    },

    onEmptyRide: () {
      RingtoneHelper().stop();
      RideNotificationHelper.clear();
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

      onStart: backgroundServiceOnStart,

      // 🔔 same channel as MainActivity.kt
      notificationChannelId: 'SERVICE_CHANNEL',
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