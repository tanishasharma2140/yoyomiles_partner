import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view/auth/add_driver_detail.dart';
import 'package:yoyomiles_partner/view/auth/login.dart';
import 'package:yoyomiles_partner/view/auth/otp_page.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view/auth/owner_detail.dart';
import 'package:yoyomiles_partner/view/auth/vehicle_detail.dart';
import 'package:yoyomiles_partner/view/bank_detail.dart';
import 'package:yoyomiles_partner/view/bank_detail_view.dart';
import 'package:yoyomiles_partner/view/privacy_policy/privacy_policy.dart';
import 'package:yoyomiles_partner/view/privacy_policy/tds_declaration.dart';
import 'package:yoyomiles_partner/view/privacy_policy/terms_and_condition.dart';
import 'package:yoyomiles_partner/view/profile.dart';
import 'package:yoyomiles_partner/view/ride/ride_safety.dart';
import 'package:yoyomiles_partner/view/ride_history.dart';
import 'package:yoyomiles_partner/view/splash_screen.dart';
import 'package:yoyomiles_partner/view/trip_status.dart';
import 'package:yoyomiles_partner/view/wallet.dart';

class Routers {
  static WidgetBuilder generateRoute(String routeName) {
    switch (routeName) {
      case RoutesName.login:
        return (context) => const Login();
      case RoutesName.splash:
        return (context) => const SplashScreen();
      case RoutesName.otp:
        return (context) => const OtpPage();
      case RoutesName.owner:
        return (context) =>  OwnerDetail();
      case RoutesName.register:
        return (context) => const Register();
      case RoutesName.map:
        return (context) => const TripStatus();
      case RoutesName.editProfile:
        return (context) => const Profile();
      case RoutesName.rideHistory:
        return (context) => const RideHistory();
      case RoutesName.wallet:
        return (context) => const Wallet();
      // case RoutesName.reward:
      //   return (context) => const Reward();
      case RoutesName.bank:
        return (context) => const BankDetail();
      // case RoutesName.liveRide:
      //   return (context) => const LiveRideScreen();
      case RoutesName.bankDetail:
        return (context) => const BankDetailView();
      case RoutesName.vehicleDetail:
        return (context) => const VehicleDetail();
      case RoutesName.addDriverDetail:
        return (context) => const AddDriverDetail();
      case RoutesName.termsCondition:
        return (context) => const TermsAndCondition();
      case RoutesName.privacyPolicy:
        return (context) => const PrivacyPolicy();
      case RoutesName.tdsDeclaration:
        return (context) => const TdsDeclaration();
      case RoutesName.rideSafety:
        return (context) => const RideSafety();
      case RoutesName.tripStatus:
        return (context) => const TripStatus();
      default:
        return (context) => const Scaffold(
          body: Center(
            child: Text(
              'No Route Found!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        );
    }
  }
}