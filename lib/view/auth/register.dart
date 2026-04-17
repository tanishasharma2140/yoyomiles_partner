import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/service/background_service.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/login.dart';
import 'package:yoyomiles_partner/view/auth/owner_detail.dart';
import 'package:yoyomiles_partner/view/auth/vehicle_detail.dart';
import 'package:yoyomiles_partner/view/controller/yoyomiles_partner_con.dart';
import 'package:yoyomiles_partner/view/live_ride_screen.dart';
import 'package:yoyomiles_partner/view/refer/refer_and_earn.dart';
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

  static const _channel = MethodChannel('rapido_background_button');
  bool _askedOverlayPermissionThisSession = false;

  Future<bool> _onWillPop(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

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
            title:  Text(
              loc.exit_app,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PortColor.blue,
              ),
            ),
            content:  Text(
              loc.are_you_sure_you_want,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), // Cancel button
                child:  Text(
                  loc.cancel,
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
                child:  Text(
                  loc.exit,
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
          final loc = AppLocalizations.of(context)!;
          Future.delayed(const Duration(milliseconds: 200), () {
            showDueDialog(
              context,
              profileViewModel.profileModel!.duesMessage ??
                  loc.pending_dues_found,
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
      print("📦 ACTIVE RIDE API RESPONSE: ${activeModel?.data}");
      print("📦 ACTIVE RIDE JSON: ${activeModel?.data?.toJson()}");
      print("📦 RIDE STATUS: ${activeModel?.data?.rideStatus}");

      bool hasRide =
          activeModel != null &&
          activeModel.data != null &&
          activeModel.data!.toJson().isNotEmpty;

      if (hasRide) {
        print("🚀 NAVIGATING TO LIVE RIDE SCREEN");
        final ride = Provider.of<RideViewModel>(context, listen: false);
        print("🧠 hasRide: $hasRide");
        print("🧠 rideStatus: ${activeModel.data?.rideStatus}");

        ride.handleRideUpdate("", context);

        if (mounted) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>
                  LiveRideScreen(booking: activeModel.data!.toJson()),
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
    final loc = AppLocalizations.of(context)!;

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
                  title: loc.account_deactivate,
                  size: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),

                const SizedBox(height: 8),

                TextConst(
                  title:
                     loc.account_deactivated,
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
                      loc.ok,
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
    final loc = AppLocalizations.of(context)!;
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
                                     TextConst(
                                      title: loc.hi,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(width: Sizes.screenWidth*0.01,),
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
                                     TextConst(
                                      title: loc.welcome_to_yoyomiles,
                                    ),
                                  ],
                                ),
                                TextConst(
                                  title:
                                      loc.few_steps_away,
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
    final loc = AppLocalizations.of(context)!;
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
               TextConst(
                textAlign: TextAlign.center,
                title:
                    loc.document_pending_approval,
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
    final loc = AppLocalizations.of(context)!;
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
                   TextConst(
                    title: loc.foreground_location_permission_required,
                    size: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 12),
                   TextConst(
                    title: loc.location_permission_description,
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
                        child:  Text(
                         loc.cancel,
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
                               SnackBar(
                                content: Text(
                                  loc.location_permission_required,
                                ),
                              ),
                            );
                          } else if (status.isPermanentlyDenied) {
                            AppSettings.openAppSettings();
                          }
                        },
                        child:  Text(
                          loc.accept,
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

  Future<bool> _maybeAskOverlayPermission() async {
    bool hasPermission = true;

    try {
      final bool? platformValue =
      await _channel.invokeMethod<bool>('hasOverlayPermission');
      hasPermission = platformValue ?? true;
    } catch (_) {
      hasPermission = true;
    }

    if (hasPermission) return true;

    if (!mounted) return false;

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PortColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title:  TextConst(
          title:
          'Overlay Permission',
            fontWeight: FontWeight.w600
        ),
        content: TextConst(title:
          'Enable "Display over other apps" to continue.',
            size: 13
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  TextConst(title: 'Later',color: PortColor.black,),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:  TextConst(title: 'Allow',color: PortColor.black,),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await _channel.invokeMethod('requestPermissions');
    }

    // 🔁 Recheck
    final bool? updated =
    await _channel.invokeMethod<bool>('hasOverlayPermission');

    return updated ?? false;
  }

  Widget verifiedContainer() {
    final onlineStatusViewModel = Provider.of<OnlineStatusViewModel>(context);
    final loc = AppLocalizations.of(context)!;

    return Consumer<YoyomilesPartnerCon>(
      builder: (context, ppc, child) {
        return Container(
          color: PortColor.scaffoldBgGrey,
          child: Column(
            children: [
              // ── 1. Dashboard Grid ──────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.03,
                ),
                child: GridView.builder(
                  padding: EdgeInsets.only(top: Sizes.screenHeight * 0.02),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: ppc.dashBoardGridList.length,
                  itemBuilder: (context, index) {
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: Sizes.screenHeight * 0.07,
                              width: Sizes.screenWidth * 0.16,
                              child: Image.asset(res.img, fit: BoxFit.contain),
                            ),
                            SizedBox(height: Sizes.screenHeight * 0.01),
                            TextConst(
                              title: res.titleKey == 'profile'
                                  ? loc.profile
                                  : res.titleKey == 'ride_history'
                                  ? loc.ride_history
                                  : res.titleKey == 'wallet_and_settlement'
                                  ? loc.wallet_and_settlement
                                  : loc.earning_report,
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

              SizedBox(height: Sizes.screenHeight * 0.012),

              // ── 2. Refer & Earn Box ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.03,
                ),
                child: _referAndEarnSection(context),
              ),

              SizedBox(height: Sizes.screenHeight * 0.012),

              // ── 3. Go Online Section ───────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.03,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PortColor.white,
                    border: Border.all(color: PortColor.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Documents Verified Row
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextConst(
                                    title: loc.upload_documents,
                                    fontWeight: FontWeight.w600,
                                    size: 14,
                                  ),
                                  const SizedBox(height: 3),
                                  TextConst(
                                    title: loc.upload_documents_description,
                                    size: 12,
                                    color: PortColor.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 13),
                                  const SizedBox(width: 4),
                                  TextConst(
                                    title: loc.verified,
                                    size: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, color: PortColor.grey),

                      // Get Your Trip Banner
                      Container(
                        width: double.infinity,
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
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.screenWidth * 0.04,
                          vertical: Sizes.screenHeight * 0.018,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextConst(
                              title: loc.get_your_trip,
                              color: PortColor.blackLight,
                              fontWeight: FontWeight.bold,
                              size: Sizes.fontSizeSeven,
                            ),
                            const SizedBox(height: 6),
                            TextConst(
                              title: loc.voila_ready_for_trip,
                              color: PortColor.black,
                              size: Sizes.fontSizeFour,
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                showLocationPermissionDialog(
                                  context,
                                  onAccept: () async {
                                    bool overlayGranted =
                                    await _maybeAskOverlayPermission();
                                    if (!overlayGranted) {
                                      Utils.showErrorMessage(context,
                                          "Overlay permission required to go online");
                                      return;
                                    }
                                    final success = await onlineStatusViewModel
                                        .onlineStatusApi(context, 1);
                                    if (success) await _startSocket();
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: Sizes.screenHeight * 0.055,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: PortColor.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Sizes.screenWidth * 0.04),
                                child: onlineStatusViewModel.loading
                                    ? const Center(
                                  child: CupertinoActivityIndicator(
                                    color: PortColor.black,
                                    radius: 14,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextConst(
                                      title: loc.go_online,
                                      color: PortColor.black,
                                      fontWeight: FontWeight.w600,
                                      size: 15,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: PortColor.blue,
                                      size: Sizes.screenHeight * 0.022,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Sizes.screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }

  Widget _referAndEarnSection(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => ReferAndEarn()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        decoration: BoxDecoration(
          color: PortColor.lightG,
          border: Border.all(color: PortColor.face),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: PortColor.face,
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.people_alt_rounded,
                color: PortColor.brown,
                size: 18,
              ),
            ),
            const SizedBox(width: 7),

             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConst(
                    title: loc.refer_n_earn,
                    fontWeight: FontWeight.w600,
                    size: 13,
                    color: PortColor.brown,
                  ),
                  SizedBox(height: 2),
                  TextConst(
                    title: loc.invite_your_friend,
                    size: 11,
                    color: PortColor.lightBrown,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: PortColor.lightBrown,
                borderRadius: BorderRadius.circular(16),
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextConst(
                    title: loc.refer,
                    size: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget rejectedContainer() {
    final profileVm = Provider.of<ProfileViewModel>(context);
    final profile = profileVm.profileModel?.data;
    final loc = AppLocalizations.of(context)!;

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
                  child:  TextConst(title: loc.upload_again),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
