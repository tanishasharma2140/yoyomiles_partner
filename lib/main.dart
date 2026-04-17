import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyomiles_partner/controller/language_controller.dart';
import 'package:yoyomiles_partner/firebase_options.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/const_without_polyline_map.dart';
import 'package:yoyomiles_partner/res/notification_service.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/service/background_service.dart';
import 'package:yoyomiles_partner/service/internet_checker_service.dart';
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
import 'package:yoyomiles_partner/view_model/driver_referral_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_transfer_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_vehicle_view_model.dart';
import 'package:yoyomiles_partner/view_model/fuel_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/help_topics_view_model.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/payment_view_model.dart';
import 'package:yoyomiles_partner/view_model/policy_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/transaction_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_stop_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_body_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_name_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_type_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/video_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const MethodChannel nativeChannel = MethodChannel(
  'yoyomiles_partner/native_callback',
);


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'SERVICE_CHANNEL',
    'Background Service',
    description: 'This channel is used for background service',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
Future<void> handleNativeCallback(MethodCall call) async {
  WidgetsFlutterBinding.ensureInitialized();
  switch (call.method) {
    case 'onRideEvent':
      final Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
      debugPrint("🚖 Ride Event from Native: $data");
      break;
    default:
      debugPrint("⚠️ Unknown native callback");
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createNotificationChannel();

  // 🔥 Step 1: Initialize Notifications FIRST (Creates Channels)
  // await RideNotificationHelper.init();

  await Firebase.initializeApp();
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? '';

  // 🔥 Step 2: Initialize Background Service AFTER Channels are ready
  await initializeBackgroundService();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  nativeChannel.setMethodCallHandler(handleNativeCallback);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(locale: languageCode));
}

double topPadding = 0.0;
double bottomPadding = 0.0;

class MyApp extends StatefulWidget {
  final String locale;
  const MyApp({super.key, required this.locale});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  final InternetCheckerService _internetCheckerService = InternetCheckerService();
  final notificationService = NotificationService(navigatorKey: navigatorKey);
  late final StreamSubscription rideActionSub;
  static const _channel = MethodChannel('rapido_background_button');


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final context = navigatorKey.currentContext;
    if (context != null) {

      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      print("ONLINE STATUS: ${profileViewModel.profileModel?.data?.onlineStatus}");
      // Checking if driver is online (onlineStatus == 1)
      final bool isOnline = profileViewModel.profileModel?.data?.onlineStatus.toString() == "1";

      if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
        if (isOnline) {
          _safeInvoke('showBackgroundButton');

          // Incoming order overlay: show after 1 minute in background.
          _safeInvokeIncomingOrderSchedule();
        } else {
          _safeInvoke('hideBackgroundButton');
          _safeInvoke('cancelIncomingOrderOverlay');
        }
      } else if (state == AppLifecycleState.resumed ||
          state == AppLifecycleState.inactive) {
        _safeInvoke('hideBackgroundButton');
        _safeInvoke('cancelIncomingOrderOverlay');
      }
    }
  }

  Future<void> _safeInvokeIncomingOrderSchedule() async {

  }

  Future<void> _safeInvoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } catch (_) {
      // Keep quiet in release; but don't crash debug either.
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // RideNotificationHelper.init() removed from here, moved to main()

    _channel.setMethodCallHandler((call) async {
      print("🔥 MethodChannel call received: ${call.method}");
      if (call.method == 'navigateTo') {
        final route = call.arguments as String?;
        if (route == null || route.isEmpty) return;
        navigatorKey.currentState?.pushNamed(route);
      }

      if (call.method == 'onOverlayAcceptRide') {
        final data = Map<String, dynamic>.from(call.arguments);

        print("📦 FULL DATA: $data");

        final String orderId = data['id']?.toString() ?? "";

        print("✅ FINAL ID: $orderId");

        if (orderId.isEmpty) return;

        final context = navigatorKey.currentContext;
        if (context == null) return;

        FlutterBackgroundService().invoke('STOP_RINGTONE');

        final assignVm = Provider.of<AssignRideViewModel>(context, listen: false);

        await assignVm.assignRideApi(context, 1, orderId, data);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryHandleLaunchRoute();
    });

    notificationService.requestedNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMassage(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _internetCheckerService.startMonitoring(navigatorKey.currentContext!);
    });
  }

  Future<void> _tryHandleLaunchRoute() async {
    try {
      final String? route =
      await _channel.invokeMethod<String>('getLaunchRoute');
      if (route != null && route.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(route);
      }
    } catch (_) {
      // Ignore if not supported on platform.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          ChangeNotifierProvider(create: (context) => UpdateRideStatusViewModel()),
          ChangeNotifierProvider(create: (context) => AssignRideViewModel()),
          ChangeNotifierProvider(create: (context) => LiveRideViewModel()),
          ChangeNotifierProvider(create: (context) => RideHistoryViewModel()),
          ChangeNotifierProvider(create: (context) => BankViewModel()),
          ChangeNotifierProvider(create: (context) => CitiesViewModel()),
          ChangeNotifierProvider(create: (context) => DriverVehicleViewModel()),
          ChangeNotifierProvider(create: (context) => VehicleBodyDetailViewModel()),
          ChangeNotifierProvider(create: (context) => BodyTypeViewModel()),
          ChangeNotifierProvider(create: (context) => FuelTypeViewModel()),
          ChangeNotifierProvider(create: (context) => PolicyViewModel()),
          ChangeNotifierProvider(create: (context) => DeleteBankDetailViewModel()),
          ChangeNotifierProvider(create: (context) => HelpTopicsViewModel()),
          ChangeNotifierProvider(create: (context) => ActiveRideViewModel()),
          ChangeNotifierProvider(create: (context) => TransactionViewModel()),
          ChangeNotifierProvider(create: (context) => PaymentViewModel()),
          ChangeNotifierProvider(create: (context) => CallBackViewModel()),
          ChangeNotifierProvider(create: (context) => DailyWeeklyViewModel()),
          ChangeNotifierProvider(create: (context) => WithdrawViewModel()),
          ChangeNotifierProvider(create: (context) => WithdrawHistoryViewModel()),
          ChangeNotifierProvider(create: (context) => DriverIgnoredRideViewModel()),
          ChangeNotifierProvider(create: (context) => RideViewModel()),
          ChangeNotifierProvider(create: (context) => ConstMapController()),
          ChangeNotifierProvider(create: (context) => ChangePayModeViewModel()),
          ChangeNotifierProvider(create: (context) => ContactListViewModel()),
          ChangeNotifierProvider(create: (context) => VideoViewModel()),
          ChangeNotifierProvider(create: (context) => LanguageController()),
          ChangeNotifierProvider(create: (context) => UpdateStopStatusViewModel()),
          ChangeNotifierProvider(create: (context) => DriverReferralHistoryViewModel()),
          ChangeNotifierProvider(create: (context) => DriverTransferViewModel()),
          Provider<NotificationService>(create: (_) => NotificationService(navigatorKey: navigatorKey)),
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
                supportedLocales: [Locale('en'), Locale('hi')],
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
              );
            }
        ),
      ),
    );
  }
}



