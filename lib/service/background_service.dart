import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'socket_service.dart';
import 'ringtone_helper.dart';

/// 🔥 TOP-LEVEL FUNCTION (MANDATORY)
@pragma('vm:entry-point')
void backgroundServiceOnStart(ServiceInstance service) async {
  /// VERY IMPORTANT
  await RideNotificationHelper.init();

  /// 🔥 Listen commands from main isolate
  service.on('STOP_RINGTONE').listen((event) {
    RingtoneHelper().stop();
  });

  service.on('START_RINGTONE').listen((event) {
    if (!RingtoneHelper().isPlaying) {
      RingtoneHelper().start();
    }
  });

  /// 🔥 Fetch driverId dynamically
  final prefs = await SharedPreferences.getInstance();
  final int? driverId = prefs.getInt('token');

  if (driverId == null) {
    print('❌ Driver ID not found, stopping service');
    return;
  }

  /// 🔥 Socket connection
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

/// 🔥 Service initializer
void initializeBackgroundService() {
  final service = FlutterBackgroundService();

  service.configure(
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      isForegroundMode: true,
      onStart: backgroundServiceOnStart,

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
