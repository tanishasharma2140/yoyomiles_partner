import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles_partner/controller/language_controller.dart';
import 'package:yoyomiles_partner/firebase_options.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/const_without_polyline_map.dart';
import 'package:yoyomiles_partner/res/notification_service.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/service/internet_checker_service.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
import 'package:yoyomiles_partner/utils/routes/routes.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view/controller/yoyomiles_partner_con.dart';
import 'package:yoyomiles_partner/view_model/active_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/assign_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/auth_view_model.dart';
import 'package:yoyomiles_partner/view_model/bank_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/bank_view_model.dart';
import 'package:yoyomiles_partner/view_model/body_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/call_back_view_model.dart';
import 'package:yoyomiles_partner/view_model/change_pay_mode_view_model.dart';
import 'package:yoyomiles_partner/view_model/cities_view_model.dart';
import 'package:yoyomiles_partner/view_model/contact_list_view_model.dart';
import 'package:yoyomiles_partner/view_model/daily_weekly_view_model.dart';
import 'package:yoyomiles_partner/view_model/delete_bank_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_ignored_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_vehicle_view_model.dart';
import 'package:yoyomiles_partner/view_model/fuel_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/help_topics_view_model.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/otp_count_view_model.dart';
import 'package:yoyomiles_partner/view_model/payment_view_model.dart';
import 'package:yoyomiles_partner/view_model/policy_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/transaction_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_body_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_name_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_type_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/video_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_view_model.dart';

// final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
// String? fcmToken;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const MethodChannel nativeChannel = MethodChannel(
  'yoyomiles_partner/native_callback',
);

@pragma('vm:entry-point')
Future<void> handleNativeCallback(MethodCall call) async {
  WidgetsFlutterBinding.ensureInitialized();

  switch (call.method) {
    case 'onRideEvent':
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        call.arguments,
      );

      debugPrint("🚖 Ride Event from Native: $data");

      await RideNotificationHelper.showIncomingRide(data);
      break;

    default:
      debugPrint("⚠️ Unknown native callback");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? '';

  // await initializeBackgroundService();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // 🔹 Get FCM Token
  //final fcmToken = await FirebaseMessaging.instance.getToken();
  // if (kDebugMode) {
  //   print("✅ FCM Token: $fcmToken");
  // }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  nativeChannel.setMethodCallHandler(handleNativeCallback);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //

  runApp( MyApp(
    locale: languageCode,
  ));
}

double topPadding = 0.0;
double bottomPadding = 0.0;

class MyApp extends StatefulWidget {
  final String locale;
  const MyApp({super.key ,required this.locale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final InternetCheckerService _internetCheckerService =
      InternetCheckerService();
  bool hasActiveRide = false;

  final notificationService = NotificationService(navigatorKey: navigatorKey);
  late final StreamSubscription rideActionSub;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    RideNotificationHelper.init();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 Foreground message received");

      if (message.data.isNotEmpty) {
        await RideNotificationHelper.showIncomingRide(message.data);
      }
    });
    rideActionSub = RideNotificationHelper.actionStream.listen((action) async {
      if (action.type == ActionType.openTripStatus) {
        final context = navigatorKey.currentContext;
        if (context == null) return;

        Navigator.pushNamed(
          context,
          RoutesName.tripStatus,
          arguments: action.bookingData,
        );
      }

      if (action.type == ActionType.accept) {
        print("🚕 ACCEPT tapped");
        print("📦 Booking data: ${action.bookingData}");

        final bookingData = action.bookingData;

        final context = navigatorKey.currentContext;
        if (context == null) {
          print("❌ Context not available");
          return;
        }

        final assignVm = Provider.of<AssignRideViewModel>(
          context,
          listen: false,
        );

        // 🔥 SAFE extraction
        final String orderId = action.bookingData['order_id']?.toString() ?? "";

        await assignVm.assignRideApi(
          context,
          1, // ACCEPT
          orderId,
          bookingData,
        );
      }

      if (action.type == ActionType.reject) {
        print("❌ REJECT tapped");
        print("📦 Booking data: ${action.bookingData}");

        final String orderId = action.bookingData['order_id']?.toString() ?? "";

        if (orderId.isEmpty) {
          print("❌ Order ID missing");
          return;
        }

        final context = navigatorKey.currentContext;
        if (context == null) {
          print("❌ Context not available");
          return;
        }

        final ignoreVm = Provider.of<DriverIgnoredRideViewModel>(
          context,
          listen: false,
        );

        await ignoreVm.driverIgnoredRideApi(
          context: context,
          orderId: orderId, // ✅ STRING
        );

        print("✅ IGNORE API CALLED FOR ORDER: $orderId");
      }
    });
    notificationService.requestedNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMassage(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _internetCheckerService.startMonitoring(navigatorKey.currentContext!);
    });
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   print("lkoklokl");
  //
  //   if (state == AppLifecycleState.detached) {
  //     final context = navigatorKey.currentContext;
  //     // if (context == null) return;
  //     print("lklklklk");
  //     final onlineStatusVm = Provider.of<OnlineStatusViewModel>(
  //       context!,
  //       listen: false,
  //     );
  //
  //     await onlineStatusVm.onlineStatusApi(context, 0);
  //     SocketService().disconnect();
  //     await stopBackgroundService();
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    topPadding = MediaQuery.of(context).padding.top;
    bottomPadding = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => YoyomilesPartnerCon()),
          ChangeNotifierProvider(create: (context) => AuthViewModel()),
          ChangeNotifierProvider(create: (context) => VehicleTypeViewModel()),
          ChangeNotifierProvider(create: (context) => VehicleNameViewModel()),
          ChangeNotifierProvider(create: (context) => ProfileViewModel()),
          ChangeNotifierProvider(create: (context) => OnlineStatusViewModel()),
          ChangeNotifierProvider(create: (context) => BankDetailViewModel()),
          ChangeNotifierProvider(
            create: (context) => UpdateRideStatusViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => AssignRideViewModel()),
          ChangeNotifierProvider(create: (context) => LiveRideViewModel()),
          ChangeNotifierProvider(create: (context) => RideHistoryViewModel()),
          ChangeNotifierProvider(create: (context) => BankViewModel()),
          ChangeNotifierProvider(create: (context) => CitiesViewModel()),
          ChangeNotifierProvider(create: (context) => DriverVehicleViewModel()),
          ChangeNotifierProvider(
            create: (context) => VehicleBodyDetailViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => BodyTypeViewModel()),
          ChangeNotifierProvider(create: (context) => FuelTypeViewModel()),
          ChangeNotifierProvider(create: (context) => PolicyViewModel()),
          ChangeNotifierProvider(
            create: (context) => DeleteBankDetailViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => HelpTopicsViewModel()),
          ChangeNotifierProvider(create: (context) => ActiveRideViewModel()),
          ChangeNotifierProvider(create: (context) => TransactionViewModel()),
          ChangeNotifierProvider(create: (context) => PaymentViewModel()),
          ChangeNotifierProvider(create: (context) => CallBackViewModel()),
          ChangeNotifierProvider(create: (context) => DailyWeeklyViewModel()),
          ChangeNotifierProvider(create: (context) => WithdrawViewModel()),
          ChangeNotifierProvider(
            create: (context) => WithdrawHistoryViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => OtpCountViewModel()),
          ChangeNotifierProvider(
            create: (context) => DriverIgnoredRideViewModel(),
          ),
          ChangeNotifierProvider(create: (context) => RideViewModel()),
          ChangeNotifierProvider(create: (context) => ConstMapController()),
          ChangeNotifierProvider(create: (context) => ChangePayModeViewModel()),
          ChangeNotifierProvider(create: (context) => ContactListViewModel()),
          ChangeNotifierProvider(create: (context) => VideoViewModel()),
          ChangeNotifierProvider(create: (context)=> LanguageController()),

          Provider<NotificationService>(
            create: (_) => NotificationService(navigatorKey: navigatorKey),
          ),
        ],
        child: Consumer<LanguageController>(
          builder: (context, provider, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              initialRoute: RoutesName.splash,
              onGenerateRoute: (settings) {
                if (settings.name != null) {
                  return CupertinoPageRoute(
                    builder: Routers.generateRoute(settings.name!),
                    settings: settings,
                  );
                }
                return null;
              },
              title: 'Yoyomiles Partner',
              locale: provider.appLocale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: [
                Locale('en'),
                Locale('hi'),
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
            );
          }
        ),
      ),
    );
  }
}
