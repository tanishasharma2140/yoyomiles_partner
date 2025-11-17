import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles_partner/firebase_options.dart';
import 'package:yoyomiles_partner/res/notification_service.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
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
import 'package:yoyomiles_partner/view_model/cities_view_model.dart';
import 'package:yoyomiles_partner/view_model/daily_weekly_view_model.dart';
import 'package:yoyomiles_partner/view_model/delete_bank_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_vehicle_view_model.dart';
import 'package:yoyomiles_partner/view_model/fuel_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/help_topics_view_model.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/payment_view_model.dart';
import 'package:yoyomiles_partner/view_model/policy_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/transaction_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_body_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_name_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_type_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/withdraw_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_view_model.dart';

String? fcmToken;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // 🔹 Get FCM Token
  fcmToken = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print("✅ FCM Token: $fcmToken");
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //

  runApp(const MyApp());
}

double topPadding = 0.0;
double bottomPadding = 0.0;


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notificationService = NotificationService(navigatorKey: navigatorKey);

  @override
  void initState() {
    super.initState();
    notificationService.requestedNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMassage(context);
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
          ChangeNotifierProvider(create: (context)=>YoyomilesPartnerCon()),
          ChangeNotifierProvider(create: (context)=> AuthViewModel()),
          ChangeNotifierProvider(create: (context)=> VehicleTypeViewModel()),
          ChangeNotifierProvider(create: (context)=> VehicleNameViewModel()),
          ChangeNotifierProvider(create: (context)=> ProfileViewModel()),
          ChangeNotifierProvider(create: (context)=> OnlineStatusViewModel()),
          ChangeNotifierProvider(create: (context)=> BankDetailViewModel()),
          ChangeNotifierProvider(create: (context)=> UpdateRideStatusViewModel()),
          ChangeNotifierProvider(create: (context)=> AssignRideViewModel()),
          ChangeNotifierProvider(create: (context)=> LiveRideViewModel()),
          ChangeNotifierProvider(create: (context)=> RideHistoryViewModel()),
          ChangeNotifierProvider(create: (context)=> BankViewModel()),
          ChangeNotifierProvider(create: (context)=> CitiesViewModel()),
          ChangeNotifierProvider(create: (context)=> DriverVehicleViewModel()),
          ChangeNotifierProvider(create: (context)=> VehicleBodyDetailViewModel()),
          ChangeNotifierProvider(create: (context)=> BodyTypeViewModel()),
          ChangeNotifierProvider(create: (context)=> FuelTypeViewModel()),
          ChangeNotifierProvider(create: (context)=> PolicyViewModel()),
          ChangeNotifierProvider(create: (context)=> DeleteBankDetailViewModel()),
          ChangeNotifierProvider(create: (context)=> HelpTopicsViewModel()),
          ChangeNotifierProvider(create: (context)=> ActiveRideViewModel()),
          ChangeNotifierProvider(create: (context)=> TransactionViewModel()),
          ChangeNotifierProvider(create: (context)=> PaymentViewModel()),
          ChangeNotifierProvider(create: (context)=> CallBackViewModel()),
          ChangeNotifierProvider(create: (context)=> DailyWeeklyViewModel()),
          ChangeNotifierProvider(create: (context)=> WithdrawViewModel()),
          ChangeNotifierProvider(create: (context)=> WithdrawHistoryViewModel()),
          Provider<NotificationService>(
            create: (_) => NotificationService(navigatorKey: navigatorKey),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: RoutesName.splash,
          onGenerateRoute: (settings){
            if (settings.name !=null){
              return MaterialPageRoute(builder: Routers.generateRoute(settings.name!),
                settings: settings,
              );
            }
            return null;
          },
          title: 'Yoyomiles Partner',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        ),
      ),
    );
  }
}
