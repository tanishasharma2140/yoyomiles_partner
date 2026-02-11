import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/service/background_service.dart';
import 'package:yoyomiles_partner/service/socket_service.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view/auth/login.dart';
import 'package:yoyomiles_partner/view/auth/owner_detail.dart';
import 'package:yoyomiles_partner/view/auth/vehicle_detail.dart';
import 'package:yoyomiles_partner/view/controller/yoyomiles_partner_con.dart';
import 'package:yoyomiles_partner/view/earning/wallet_settlement.dart';
import 'package:yoyomiles_partner/view/live_ride_screen.dart';
import 'package:yoyomiles_partner/view_model/active_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            title: const Text(
              "Exit App",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PortColor.blue,
              ),
            ),
            content: const Text(
              "Are you sure you want to exit this app?",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Cancel button
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final onlineStatusVm = Provider.of<OnlineStatusViewModel>(
                    context,
                    listen: false,
                  );

                  await onlineStatusVm.onlineStatusApi(context, 0);

                  // SocketService().disconnect();

                  await stopBackgroundService();

                  SystemNavigator.pop(); // Exit app
                },
                child: const Text(
                  "Exit",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _onRefresh() async {
    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    await profileViewModel.profileApi(context);
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = UserViewModel();
      final driverId = await userViewModel.getUser();

      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );

      final activeRideVm = Provider.of<ActiveRideViewModel>(
        context,
        listen: false,
      );

      // 🔥 1️⃣ LOAD PROFILE
      await profileViewModel.profileApi(context);

      final profileModel = profileViewModel.profileModel;

      if (profileModel == null || profileModel.data == null) return;

      final profile = profileModel.data!;

      // 🔥 2️⃣ DUE STATUS CHECK (FIRST PRIORITY)
      if (profileViewModel.profileModel!.duesStatus == 1) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            showDueDialog(
              context,
              profileViewModel.profileModel!.duesMessage ??
                  "Pending dues found.",
            );
          });
        }
        return; // ⛔ STOP EVERYTHING
      }

      // 🔥 3️⃣ ACCOUNT DEACTIVATED CHECK
      if (profile.status == 0) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            showAccountDeactivatedDialog(context);
          });
        }
        return;
      }

      // 🔥 4️⃣ LOAD ACTIVE RIDE
      await activeRideVm.activeRideApi(driverId.toString());

      final activeModel = activeRideVm.activeRideModel;

      bool hasRide =
          activeModel != null &&
          activeModel.data != null &&
          activeModel.data!.toJson().isNotEmpty;

      if (hasRide) {
        final ride = Provider.of<RideViewModel>(context, listen: false);

        ride.handleRideUpdate("", context);

        if (mounted) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>
                  LiveRideScreen(booking: activeModel!.data!.toJson()),
            ),
          );
        }
      } else {
        if (profileViewModel.profileModel!.duesStatus != 1 &&
            profile.onlineStatus == 1 &&
            profile.verifyDocument != 1 &&
            profile.verifyDocument != 3) {
          if (mounted) {
            Navigator.pushNamed(context, RoutesName.tripStatus);
          }
        }
      }
    });
  }

  void showAccountDeactivatedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: PortColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, color: Colors.redAccent, size: 38),

                const SizedBox(height: 16),

                TextConst(
                  title: "Account Deactivated",
                  size: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),

                const SizedBox(height: 8),

                TextConst(
                  title:
                      "Your account has been deactivated.\nPlease contact the admin for assistance.",
                  textAlign: TextAlign.center,
                  size: 14,
                  color: Colors.black54,
                ),

                const SizedBox(height: 22),

                // OK button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: PortColor.grey,
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            header: const WaterDropHeader(
              waterDropColor: PortColor.partner,
              complete: Icon(Icons.check, color: Colors.green),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Sizes.screenHeight * 0.055,
                  horizontal: Sizes.screenWidth * 0.03,
                ),
                child: profileViewModel.profileModel == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Container(
                            height: Sizes.screenHeight * 0.11,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFF176),
                                  Color(0xFFFFD54F),
                                  Color(0xFFFFA726),
                                ],
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                Assets.assetsYoyoPartnerLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Sizes.screenHeight * 0.02,
                            ),
                            height: Sizes.screenHeight * 0.09,
                            color: PortColor.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const TextConst(
                                      title: "Hii  ",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    TextConst(
                                      title:
                                          profileViewModel
                                              .profileModel
                                              ?.data
                                              ?.driverName ??
                                          "",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(width: Sizes.screenWidth * 0.01),
                                    const TextConst(
                                      title: "welcome to yoyomiles",
                                    ),
                                  ],
                                ),
                                TextConst(
                                  title:
                                      "You are now a few steps away from getting your first trip",
                                  size: 12,
                                  color: PortColor.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Sizes.screenHeight * 0.004),
                          if (profileViewModel
                                  .profileModel
                                  ?.data
                                  ?.verifyDocument ==
                              1)
                            pendingContainer()
                          else if (profileViewModel
                                  .profileModel
                                  ?.data
                                  ?.verifyDocument ==
                              2)
                            verifiedContainer()
                          else if (profileViewModel
                                  .profileModel
                                  ?.data
                                  ?.verifyDocument ==
                              3)
                            rejectedContainer(),
                          SizedBox(height: Sizes.screenHeight * 0.008),
                          GestureDetector(
                            onTap: () {
                              _onRefresh();
                            },
                            child: SizedBox(
                              height: Sizes.screenHeight * 0.05,
                              width: Sizes.screenWidth * 0.3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          // bottomSheet:
        ),
      ),
    );
  }

  Widget pendingContainer() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.screenWidth * 0.02,
            vertical: Sizes.screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: PortColor.scaffoldBgGrey,
            border: Border.all(color: PortColor.grey),
          ),
          child: Column(
            children: [
              Image.asset(Assets.assetsPending),
              const TextConst(
                textAlign: TextAlign.center,
                title:
                    "Your document has been successfully uploaded and is pending approval. Please wait while the review process is completed.",
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showLocationPermissionDialog(
    BuildContext context, {
    required VoidCallback onAccept,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextConst(
                    title: 'Foreground Location Access Permissions Required',
                    size: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 12),
                  const TextConst(
                    title:
                        'This app collects your location even when the app is closed or not in use to enable ride matching, show nearby ride requests, and keep you available while you are online as a driver.',
                    size: 14,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 20),

                  /// Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          // 🔥 YAHI WO "WHILE USING THE APP" WALA ALERT HAI
                          final status = await AppSettings
                              .Permission
                              .locationWhenInUse
                              .request();

                          if (status.isGranted) {
                            onAccept(); // aage jao
                          } else if (status.isDenied) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Location permission is required',
                                ),
                              ),
                            );
                          } else if (status.isPermanentlyDenied) {
                            AppSettings.openAppSettings();
                          }
                        },
                        child: const Text(
                          'ACCEPT',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _startSocket() async {
    final userViewModel = UserViewModel();

    int? driverId = await userViewModel.getUser();

    if (driverId == null || driverId == 0) {
      debugPrint("❌ Driver ID not found, socket not started");
      return;
    }

    debugPrint("✅ Starting socket with driverId: $driverId");

    // Background service start
    initializeBackgroundService();
  }

  Widget verifiedContainer() {
    final onlineStatusViewModel = Provider.of<OnlineStatusViewModel>(context);

    return Consumer<YoyomilesPartnerCon>(
      builder: (context, ppc, child) {
        return Container(
          height: Sizes.screenHeight * 0.7,
          color: PortColor.scaffoldBgGrey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.03),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.screenWidth * 0.01,
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.only(top: Sizes.screenHeight * 0.02),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                    shrinkWrap: true,
                    itemCount: ppc.dashBoardGridList.length,
                    itemBuilder: (BuildContext context, index) {
                      final res = ppc.dashBoardGridList[index];
                      return GestureDetector(
                        onTap: () {
                          if (res.route != '') {
                            Navigator.pushNamed(context, res.route);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: PortColor.grey),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: Sizes.screenHeight * 0.08,
                                width: Sizes.screenWidth * 0.18,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(res.img),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: Sizes.screenHeight * 0.012),
                              TextConst(
                                title: res.title,
                                size: Sizes.fontSizeSix,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: Sizes.screenHeight * 0.01),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          Container(width: 2, height: 80, color: Colors.green),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  PortColor.yellow, // orange
                                  Color(0xFFFF7043), // coral red
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              border: Border.all(
                                color: PortColor.yellow,
                                width: 2.0,
                              ),
                            ),
                            child: const Center(
                              child: TextConst(
                                title: '2',
                                color: PortColor.blackLight, // Text color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Sizes.screenWidth * 0.035),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: Sizes.screenWidth * 0.75,
                          height: Sizes.screenHeight * 0.09,
                          decoration: BoxDecoration(
                            color: PortColor.white,
                            border: Border.all(color: PortColor.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextConst(
                                  title: 'Upload documents',
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(height: 4),
                                TextConst(
                                  title: 'Driving licence, Aadhaar card, etc.',
                                  color: PortColor.black.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.009),
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            TextConst(title: 'Verified', color: Colors.green),
                          ],
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.02),
                        Container(
                          width: Sizes.screenWidth * 0.75,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFF176),
                                Color(0xFFFFD54F),
                                Color(0xFFFFA726),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Sizes.screenWidth * 0.04,
                              vertical: Sizes.screenHeight * 0.01,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title: 'Get your trip..!!',
                                  color: PortColor.blackLight,
                                  fontWeight: FontWeight.bold,
                                  size: Sizes.fontSizeSeven,
                                ),
                                const SizedBox(height: 8),
                                TextConst(
                                  title: 'Voila! You are ready to do your trip',
                                  color: PortColor.black,
                                  size: Sizes.fontSizeFour,
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: () {
                                    showLocationPermissionDialog(
                                      context,
                                      onAccept: () async {
                                        final success =
                                            await onlineStatusViewModel
                                                .onlineStatusApi(context, 1);

                                        if (success) {
                                          await _startSocket();
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Sizes.screenWidth * 0.015,
                                    ),
                                    height: Sizes.screenHeight * 0.05,
                                    width: Sizes.screenWidth * 0.7,
                                    color: PortColor.white,
                                    child: onlineStatusViewModel.loading
                                        ? CupertinoActivityIndicator(
                                            color: PortColor.black,
                                            radius: 18,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const TextConst(
                                                title: 'Go Online',
                                                color: PortColor.black,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: PortColor.blue,
                                                size:
                                                    Sizes.screenHeight * 0.025,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget rejectedContainer() {
    final profileVm = Provider.of<ProfileViewModel>(context);
    final profile = profileVm.profileModel?.data;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.screenWidth * 0.04,
            vertical: Sizes.screenHeight * 0.03,
          ),
          decoration: BoxDecoration(
            color: PortColor.scaffoldBgGrey,
            border: Border.all(color: PortColor.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Image.asset(Assets.assetsRejected),
              SizedBox(height: Sizes.screenHeight * 0.02),
              TextConst(
                textAlign: TextAlign.center,
                title: profile?.docRejResion ?? "",
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,

                // fo
                size: 14,
              ),
              SizedBox(height: Sizes.screenHeight * 0.03),

              // Upload Again Button
              GestureDetector(
                onTap: () {
                  print("Tapped!");
                  print(
                    "Owner: ${profile?.ownerDocStatus}, Vehicle: ${profile?.vehicleDocStatus}, Driver: ${profile?.driverDocStatus}",
                  );
                  if (profile == null) return;
                  if (profile.ownerDocStatus == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OwnerDetail(),
                      ),
                    );
                  } else if (profile.vehicleDocStatus == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VehicleDetail(),
                      ),
                    );
                  } else if (profile.driverDocStatus == 0) {
                    Navigator.pushNamed(
                      context,
                      RoutesName.addDriverDetail,
                      arguments: ["user_id"],
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: PortColor.subBtn,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const TextConst(title: "Upload Again"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
