import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigation after delay
    Timer(const Duration(seconds: 3), () {
      checkSession(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Image.asset(
              Assets.assetsYoyoPartnerLogo,
              width: 150,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> checkSession(context) async {
  //   try {
  //     UserViewModel userViewModel = UserViewModel();
  //     int? userId = await userViewModel.getUser();
  //
  //     if (userId != null ) {
  //       Navigator.pushReplacementNamed(context, RoutesName.register);
  //     } else {
  //       Navigator.pushReplacementNamed(context, RoutesName.login);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error fetching user ID: $e");
  //     }
  //   }
  // }
  Future<void> checkSession(BuildContext context) async {
    try {
      UserViewModel userViewModel = UserViewModel();
      int? userId = await userViewModel.getUser();

      if (userId == null) {
        Navigator.pushReplacementNamed(context, RoutesName.login);
      } else {
        final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

        await profileVm.profileApi();

        final profile = profileVm.profileModel?.data;

        if (profile == null) {
          Navigator.pushReplacementNamed(context, RoutesName.login);
          return;
        }

        final int verifyDocument = profile.verifyDocument ?? 0;
        final int ownerDocStatus = profile.ownerDocStatus ?? 0;
        final int vehicleDocStatus = profile.vehicleDocStatus ?? 0;
        final int driverDocStatus = profile.driverDocStatus ?? 0;
        if (verifyDocument == 3) {
          // Rejected → direct register page
          print("verifyDocument is 3, going to Register");
          Navigator.pushReplacementNamed(context, RoutesName.register);
        } else if (verifyDocument == 1) {
          // Pending/Verified → check each doc status
          if (ownerDocStatus == 0 || ownerDocStatus == 2) {
            Navigator.pushReplacementNamed(context, RoutesName.owner);
          } else if (vehicleDocStatus == 0 || vehicleDocStatus == 2) {
            Navigator.pushReplacementNamed(context, RoutesName.vehicleDetail);
          } else if (driverDocStatus == 0 || driverDocStatus == 2) {
            Navigator.pushReplacementNamed(context, RoutesName.addDriverDetail);
          } else if (ownerDocStatus == 1 &&
              vehicleDocStatus == 1 &&
              driverDocStatus == 1) {
            Navigator.pushReplacementNamed(context, RoutesName.register);
          } else {
            // Fallback
            Navigator.pushReplacementNamed(context, RoutesName.register);
          }
        } else {
          // Other cases → default
          Navigator.pushReplacementNamed(context, RoutesName.register);
        }

      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in checkSession: $e");
      }
    }
  }


}
