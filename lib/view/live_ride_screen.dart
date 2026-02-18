import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/const_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_appbar.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/slide_to_button.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view_model/change_pay_mode_view_model.dart';
import 'package:yoyomiles_partner/view_model/contact_list_view_model.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';

class LiveRideScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  const LiveRideScreen({super.key, required this.booking});

  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  double pickupLat = 0.0;
  double pickupLng = 0.0;

  double dropLat = 0.0;
  double dropLng = 0.0;
  bool isOtpVerified = false;

  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveRideViewModel = Provider.of<LiveRideViewModel>(
        context,
        listen: false,
      );

      liveRideViewModel.liveRideApi().then((_) {
        if (liveRideViewModel.liveOrderModel?.data != null) {
          final data = liveRideViewModel.liveOrderModel!.data!;

          pickupLat = double.tryParse(data.pickupLatitute.toString()) ?? 0.0;
          pickupLng = double.tryParse(data.pickLongitude.toString()) ?? 0.0;

          dropLat = double.tryParse(data.dropLatitute.toString()) ?? 0.0;
          dropLng = double.tryParse(data.dropLogitute.toString()) ?? 0.0;

          print("📍 Pickup LatLng = $pickupLat , $pickupLng");
          print("📍 Drop LatLng   = $dropLat , $dropLng");
        }

        if (liveRideViewModel.liveOrderModel?.data?.id != null) {
          // _startRideStatusListener(
          //   liveRideViewModel.liveOrderModel!.data!.id.toString(),
          // );
        }
      });
    });
  }

  bool isSwitched = true;
  String? _currentAddress;

  // 🔥 FLAGS - NOT NEEDED ANYMORE FOR SCREENS
  bool _showPaymentSuccessDialog = false;
  bool _showRideCompletedDialog = false;
  bool _mapPopupShown = false;

  StreamSubscription<DocumentSnapshot>? _paymentSubscription;
  StreamSubscription<DocumentSnapshot>? _rideStatusSubscription;

  void _openGoogleMapsDirections() {
    final url =
        "https://www.google.com/maps/dir/?api=1&origin=$pickupLat,$pickupLng&destination=$dropLat,$dropLng&travelmode=driving";

    LauncherI.launchURL(url);
  }

  // 🔥 NAVIGATE TO WAITING PAYMENT SCREEN
  void _navigateToWaitingPaymentScreen() {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(
      context,
      listen: false,
    );
    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();

    print("🪟 Navigating to WAITING payment screen for order: $orderId");

    // _startPaymentListener(orderId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectPaymentScreen(orderId: orderId),
      ),
    );
  }

  void _showPaymentSuccessDialogMethod() {
    if (_showPaymentSuccessDialog) {
      print("⚠️ Payment success dialog already showing");
      return;
    }

    print("🎉 Showing PAYMENT SUCCESS dialog");

    setState(() {
      _showPaymentSuccessDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildPaymentSuccessDialog();
      },
    ).then((_) {
      print("🔒 Payment success dialog closed");
      setState(() {
        _showPaymentSuccessDialog = false;
      });
    });
  }

  // 🔥 RIDE COMPLETED DIALOG FOR CASH PAYMENT
  void _showRideCompletedDialogMethod() {
    if (_showRideCompletedDialog) {
      print("⚠️ Ride completed dialog already showing");
      return;
    }

    print("✅ Showing RIDE COMPLETED dialog for cash payment");

    setState(() {
      _showRideCompletedDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildRideCompletedDialog();
      },
    ).then((_) {
      print("🔒 Ride completed dialog closed");
      setState(() {
        _showRideCompletedDialog = false;
      });
    });
  }

  // 🔥 NEW: RIDE CANCELLED DIALOG

  Widget _buildPaymentSuccessDialog() {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 15),
              Text(
                loc.payment_successful,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.payment_received_thank_you,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print("🏠 OK pressed from success - Navigating to Register");
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RoutesName.tripStatus,
                        (route) => route.settings.name == RoutesName.register,
                  );
                },
                child:  Text(
                  loc.ok,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Ride Completed Dialog for Cash Payment
  Widget _buildRideCompletedDialog() {
    final loc = AppLocalizations.of(context)!;
    final liveRideVm = Provider.of<LiveRideViewModel>(context);
    final ride = Provider.of<RideViewModel>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 15),
              Text(
               loc.ride_completed_celebration,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.ride_completed_successfully_thank_you,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortColor.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print(
                    "🏠 OK pressed from ride completed - Navigating to Register",
                  );
                  Navigator.pop(context);
                  Provider.of<UpdateRideStatusViewModel>(
                    context,
                    listen: false,
                  ).updateRideApi(
                    context,
                    liveRideVm.liveOrderModel!.data!.id.toString(),
                    "6",
                  );
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(builder: (context) => Register()),
                  //   (route) => false,
                  // );
                  ride.setActiveRideData(null);
                  ride.disable78();
                },
                child:  Text(
                  loc.ok,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Ride Cancelled Dialog
  Widget _buildRideCancelledDialog(String userName) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(
                loc.ride_cancelled,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${loc.ride_cancelled_by} $userName",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print(
                    "🏠 OK pressed from cancelled - Navigating to Register",
                  );
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                    (route) => false,
                  );
                },
                child:  Text(
                  loc.ok,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReachedButtonClick() async {
    final rideStatus = Provider.of<RideViewModel>(context, listen: false);
    final liveRideViewModel = Provider.of<LiveRideViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;

    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();

    try {
      final payMode = rideStatus.activeRideData?['payMode'] ?? 1;

      print("💰 Reached tapped | payMode = $payMode");

      /// 🔥 WALLET PAYMENT (paymode == 3)
      if (payMode == 3) {
        print("👛 Wallet payment detected → completing ride directly");

        rideStatus.updateRideStatus(6);

        // liveRideViewModel.liveOrderModel!.data!.rideStatus = 6;

        Utils.showSuccessMessage(
          context,
          loc.ride_completed_wallet,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          _showRideCompletedDialogMethod();
        });

        return;
      }

      /// 💵 CASH PAYMENT
      if (payMode == 1) {
        print("💵 Cash payment → move to collect payment");

        await FirebaseFirestore.instance
            .collection('order')
            .doc(orderId)
            .update({'ride_status': 5});

        // liveRideViewModel.liveOrderModel!.data!.rideStatus = 5;

        Utils.showSuccessMessage(context, loc.reached_destination);

        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CollectPaymentScreen(orderId: orderId),
            ),
          );
        });

        return;
      }

      /// 💳 ONLINE PAYMENT
      if (payMode == 2) {
        print("💳 Online payment → waiting for payment");

        await FirebaseFirestore.instance
            .collection('order')
            .doc(orderId)
            .update({'ride_status': 5});

        // liveRideViewModel.liveOrderModel!.data!.rideStatus = 5;

        Utils.showSuccessMessage(
          context,
          loc.ride_status_reached_destination,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          _navigateToWaitingPaymentScreen();
        });

        return;
      }
    } catch (e) {
      Utils.showErrorMessage(context, "${loc.failed_update_ride_status} $e");
    }
  }

  void _showGoToMapDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              const SizedBox(height: 12),

               TextConst(
                title: loc.otp_verified,
                size: 16,
                fontWeight: FontWeight.w700,
              ),

              const SizedBox(height: 8),

              TextConst(
                title: loc.open_google_maps_navigation,
                textAlign: TextAlign.center,
                size: 13,
                color: Colors.black54,
              ),

              const SizedBox(height: 18),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _openGoogleMapsDirections();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: PortColor.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Center(
                    child: Text(
                      loc.go_to_map,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("🗑️ Disposing LiveRideScreen - Cancelling listeners");
    _paymentSubscription?.cancel();
    _rideStatusSubscription?.cancel();
    super.dispose();
  }

  void _showGoToMapPopupFromCurrentLocation() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map, color: PortColor.gold, size: 40),
              const SizedBox(height: 12),

               Text(
                loc.go_to_pickup_location,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

               Text(
                loc.open_google_maps_pickup,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 18),

              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await _openGoogleMapsFromCurrentLocation();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: PortColor.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Center(
                    child: Text(
                      loc.go_to_map,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMapsFromCurrentLocation() async {
    final loc = AppLocalizations.of(context)!;
    final pickupLatLng = "$pickupLat,$pickupLng";

    final url =
        "https://www.google.com/maps/dir/?api=1"
        "&destination=$pickupLatLng"
        "&travelmode=driving";

    print("🗺️ Opening Google Maps: $url");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Utils.showErrorMessage(context, loc.could_not_open_google_maps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: CustomAppBar(
          name: profileViewModel.profileModel!.data!.driverName!,
          imageUrl: profileViewModel.profileModel!.data!.ownerSelfie ?? "",
        ),
        body: Consumer<RideViewModel>(
          builder: (context, rideVm, child) {
            final activeRideData = rideVm.activeRideData;
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ConstMap(
                    data: [widget.booking],
                    rideStatus:
                        liveRideViewModel.liveOrderModel?.data?.rideStatus,
                    onAddressFetched: (address) {
                      setState(() {
                        _currentAddress = address;
                      });
                    },
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.75,
                  minChildSize: 0.45,
                  maxChildSize: 0.77,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: PortColor.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: _buildSheetContent(
                        scrollController,
                        activeRideData,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getButtonColor(int? rideStatus) {
    switch (rideStatus) {
      case 1:
        return PortColor.gold;
      case 2:
        return PortColor.buttonBlue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.green;
      case 5:
        return Colors.teal;
      default:
        return PortColor.gold;
    }
  }

  String _getButtonText(int? status) {
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case 1:
        return loc.start_for_pickup;
      case 2:
        return loc.arrived_at_pickup_point;
      case 3:
        return loc.start_ride;
      case 4:
        return loc.reached;
      case 5:
        return loc.ride_completed;
      default:
        return loc.start_for_pickup;
    }
  }

  void _showOtpDialog(String orderId) {
    final TextEditingController _otpController = TextEditingController();
    final liveRideViewModel = Provider.of<LiveRideViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;

    final rideStatus = Provider.of<RideViewModel>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: PortColor.gold,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  loc.trip_otp_verification,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.kanitReg,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: loc.enter_otp,
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child:  Text(
                          loc.cancel,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PortColor.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final enteredOtp = _otpController.text.trim();
                          if (enteredOtp.isEmpty) {
                            Utils.showErrorMessage(context, loc.please_enter_otp);
                            return;
                          }
                          try {
                            final firestoreOtp =
                                rideStatus.activeRideData?['otp'];
                            print("otpdfdd$firestoreOtp");
                            print(enteredOtp);


                            if (firestoreOtp.toString() ==
                                enteredOtp.toString()) {
                              rideStatus.updateRideStatus(4);

                              Navigator.of(context).pop();
                              Utils.showSuccessMessage(
                                context,
                                loc.otp_verified_ride_started,
                              );
                              setState(() {
                                isOtpVerified = true;
                              });
                              _showGoToMapDialog();
                            } else {
                              Utils.showErrorMessage(
                                context,
                                loc.invalid_otp_try_again,
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child:  Text(
                          loc.verify,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Sizes.screenHeight * 0.005),
      child: TextConst(
        title: title,
        size: Sizes.fontSizeSix,
        fontWeight: FontWeight.bold,
        color: PortColor.gold,
      ),
    );
  }

  Widget _buildEmergencySection() {
    final contactListVm =
    Provider.of<ContactListViewModel>(context, listen: false);

    final String supportNumber =
        contactListVm.contactListModel?.sosNumber ?? "6306513131";
    final String sosMessage =
        contactListVm.contactListModel?.sosMessage ?? "Hello";
    final loc = AppLocalizations.of(context)!;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT INFO
          Expanded(
            child: Row(
              children:  [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 22,
                ),
                SizedBox(width: 6),
                TextConst(
                  title: loc.emergency,
                  size: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          /// 🔴 SOS BUTTON
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: sosMessage,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child:  TextConst(
                title: loc.sos,
                color: Colors.white,
                size: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// 🟡 CHAT SUPPORT
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _openWhatsApp(
                phone: supportNumber,
                message: loc.support_help_message,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: PortColor.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDetailRow({
    IconData? icon, // ← optional
    required String title,
    required String content,
    bool isAddress = false,
    bool isHeader = false,
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.screenHeight * 0.01),
      child: Row(
        crossAxisAlignment: isAddress
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          /// ONLY SHOW ICON IF NOT NULL
          if (icon != null) ...[
            Icon(icon, color: PortColor.gold, size: 16),
            SizedBox(width: Sizes.screenWidth * 0.02),
          ],

          Container(
            width: Sizes.screenWidth * (isHeader ? 0.25 : 0.15),
            child: TextConst(
              title: "$title:",
              size: Sizes.fontSizeFive,
              fontWeight: FontWeight.w500,
              color: PortColor.blackLight,
            ),
          ),

          SizedBox(width: Sizes.screenWidth * 0.02),

          Expanded(
            child: TextConst(
              title: content,
              size: Sizes.fontSizeFour,
              color: PortColor.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.w400,
              maxLines: isAddress ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int? rideStatus) {
    final loc = AppLocalizations.of(context)!;
    print("kjkjkjk");
    print(rideStatus);
    switch (rideStatus) {
      case 1:
        return loc.accepted_by_driver;
      case 2:
        return loc.out_for_pickup;
      case 3:
        return loc.at_pickup_point;
      case 4:
        return loc.ride_started;
      case 5:
        return loc.reached_destination;
      case 6:
        return loc.payment_completed;
      case 7:
        return loc.ride_cancelled_status;
      default:
        return loc.unknown_status;
    }
  }

  Widget _buildSheetContent(
    ScrollController scrollController,
    Map<String, dynamic>? activeRideData,
  ) {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    final updateRideStatus = Provider.of<UpdateRideStatusViewModel>(context);
    final loc = AppLocalizations.of(context)!;


    if (liveRideViewModel.liveOrderModel == null || liveRideViewModel.loading) {
      return Center(child: CircularProgressIndicator(color: PortColor.gold));
    }

    if (liveRideViewModel.liveOrderModel!.data == null) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: Sizes.screenHeight * 0.01),
            width: Sizes.screenWidth * 0.15,
            height: Sizes.screenHeight * 0.005,
            decoration: BoxDecoration(
              color: PortColor.gray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.assetsNoData,
                    height: Sizes.screenHeight * 0.15,
                  ),
                  SizedBox(height: Sizes.screenHeight * 0.02),
                  TextConst(
                    title: loc.no_active_ride,
                    color: PortColor.gold,
                    fontWeight: FontWeight.bold,
                    size: Sizes.fontSizeSix,
                  ),
                  SizedBox(height: Sizes.screenHeight * 0.01),
                  TextConst(
                    title: loc.no_active_ride_message,
                    color: PortColor.gray,
                    size: Sizes.fontSizeFour,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    print('lololo');
    print(activeRideData);
    final rideStatus = Provider.of<RideViewModel>(context);
    final rs = activeRideData?['rideStatus'];

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: Sizes.screenHeight * 0.01),
          width: Sizes.screenWidth * 0.15,
          height: Sizes.screenHeight * 0.005,
          decoration: BoxDecoration(
            color: PortColor.gray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          title: loc.booking_id,
                          content: liveRideViewModel.liveOrderModel!.data!.id
                              .toString(),
                          isHeader: true,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.008),
                        _buildDetailRow(
                          title: loc.vehicle_type,
                          content:
                              liveRideViewModel
                                  .liveOrderModel!
                                  .data!
                                  .vehicleName ??
                              "N/A",
                          isHeader: true,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.screenWidth * 0.025,
                          vertical: Sizes.screenHeight * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              color: Colors.green,
                              size: 14,
                            ),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title:
                                  '${liveRideViewModel.liveOrderModel!.data!.amount ?? '0'}',
                              size: Sizes.fontSizeFour - 1,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Sizes.screenHeight * 0.005),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.screenWidth * 0.025,
                          vertical: Sizes.screenHeight * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.space_dashboard,
                              color: Colors.blue,
                              size: 14,
                            ),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title:
                                  '${liveRideViewModel.liveOrderModel!.data!.distance ?? '0'} km',
                              size: Sizes.fontSizeFour - 1,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: Sizes.screenWidth * 0.02),
                  GestureDetector(
                    onTap: () => Launcher.launchDialPad(
                      context,
                      liveRideViewModel.liveOrderModel!.data!.senderPhone
                              ?.toString() ??
                          '9876543210',
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.008,
                        horizontal: Sizes.screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call, color: Colors.black, size: 16),
                          SizedBox(width: Sizes.screenWidth * 0.01),
                          TextConst(
                            title: loc.call,
                            color: Colors.black,
                            size: Sizes.fontSizeFour,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: Sizes.screenHeight * 0.015),
        Divider(height: 1),

        Expanded(
          child: Container(
            margin: EdgeInsets.all(Sizes.screenWidth * 0.04),
            padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildSectionHeader(loc.sender_details),
                  SizedBox(height: Sizes.screenHeight * 0.01),

                  if (liveRideViewModel.liveOrderModel!.data!.orderType
                          .toString() ==
                      "2") ...[
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content:
                          liveRideViewModel
                              .liveOrderModel!
                              .data!
                              .pickupAddress ??
                          "N/A",
                      isAddress: true,
                      bold: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      title: loc.name,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.senderName ??
                          "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: loc.phone,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.senderPhone
                              ?.toString() ??
                          "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content:
                          liveRideViewModel
                              .liveOrderModel!
                              .data!
                              .pickupAddress ??
                          "N/A",
                      isAddress: true,
                    ),
                  ],

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  Divider(height: 1),

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildSectionHeader(loc.receiver_details),
                  SizedBox(height: Sizes.screenHeight * 0.01),

                  if (liveRideViewModel.liveOrderModel!.data!.orderType
                          .toString() ==
                      "2") ...[
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.dropAddress ??
                          "N/A",
                      isAddress: true,
                      bold: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      title: loc.name,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.reciverName ??
                          "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: loc.phone,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.reciverPhone
                              ?.toString() ??
                          "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content:
                          liveRideViewModel.liveOrderModel!.data!.dropAddress ??
                          "N/A",
                      isAddress: true,
                    ),
                  ],

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  Divider(height: 1),
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildEmergencySection(),
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Sizes.screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: PortColor.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: PortColor.gold, size: 18),
                        SizedBox(width: Sizes.screenWidth * 0.02),
                        Expanded(
                          child: TextConst(
                            title:
                                "${loc.current_status} ${_getStatusText(activeRideData?['rideStatus'])}",
                            size: Sizes.fontSizeFive,
                            fontWeight: FontWeight.w600,
                            color: PortColor.gold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final liveRideViewModel =
                                Provider.of<LiveRideViewModel>(
                                  context,
                                  listen: false,
                                );
                            final orderId =
                                liveRideViewModel.liveOrderModel!.data!.id;
                            int currentStatus =
                                activeRideData?['rideStatus'] ?? 1;

                            try {
                              if (currentStatus == 1) {
                                rideStatus.updateRideStatus(2);
                                _showGoToMapPopupFromCurrentLocation();
                                Utils.showSuccessMessage(
                                  context,
                                  loc.ride_status_start_pickup,
                                );
                              } else if (currentStatus == 2) {
                                rideStatus.updateRideStatus(3);
                                Utils.showSuccessMessage(
                                  context,
                                  loc.ride_status_arrived_pickup,
                                );
                              } else if (currentStatus == 3) {
                                _showOtpDialog(orderId.toString());
                                return;
                              } else if (currentStatus == 4) {
                                _handleReachedButtonClick();
                                return;
                              }
                              setState(() {});
                            } catch (e) {
                              Utils.showErrorMessage(
                                context,
                                "${loc.failed_update_ride_status} $e",
                              );
                            }
                          },

                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Sizes.screenHeight * 0.014,
                            ),
                            decoration: BoxDecoration(
                              color: _getButtonColor(
                                activeRideData?['rideStatus'],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextConst(
                                title: _getButtonText(
                                  activeRideData?['rideStatus'],
                                ),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                size: Sizes.fontSizeFive,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (rs != null && rs < 4) ...[
                        SizedBox(width: Sizes.screenWidth * 0.03),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              updateRideStatus.updateRideApi(
                                context,
                                liveRideViewModel.liveOrderModel!.data!.id
                                    .toString(),
                                "8",
                              );
                              // rideStatus.setActiveRideData(null);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Sizes.screenHeight * 0.012,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: PortColor.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cancel,
                                      color: PortColor.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: Sizes.screenWidth * 0.02),
                                    TextConst(
                                      title: loc.reject,
                                      color: PortColor.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CollectPaymentScreen extends StatelessWidget {
  final String orderId;
  const CollectPaymentScreen({super.key, required this.orderId});

  void _handlePaymentComplete(BuildContext context) async {
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final rideStatus = Provider.of<RideViewModel>(context, listen: false);
    final updateRideVM = Provider.of<UpdateRideStatusViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;


    try {
      print("💵 Payment completed → Updating ride to status 6");

      // 🔹 Backend API update first
      await updateRideVM.updateRideApi(
        context,
        liveRideVm.liveOrderModel!.data!.id.toString(),
        "6",
      );

      // 🔹 Update Firestore too (if required)
      // await FirebaseFirestore.instance
      //     .collection('order')
      //     .doc(orderId)
      //     .update({'ride_status': 6});

      // 🔹 Clear active ride state
      rideStatus.setActiveRideData(null);
      rideStatus.disable78();

      Utils.showSuccessMessage(context, loc.ride_completed_successfully);

      // 🔹 Close current screen
      Navigator.of(context).pop();

      // 🔹 Show Completed Dialog after short delay (safe build)
      Future.delayed(const Duration(milliseconds: 300), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildRideCompletedDialog(context),
        );
      });
    } catch (e) {
      Utils.showErrorMessage(context, "${loc.failed_complete_ride} $e");
    }
  }


  Future<void> _changePaymode(BuildContext context, int newPaymode) async {
    final changePayModeViewModel = Provider.of<ChangePayModeViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;
    try {
      // 🔥 API CALL using ChangePayModeViewModel
      await changePayModeViewModel.changePayModeApi(
        context: context,
        orderId: orderId,
        payMode: newPaymode,
      );

      // ✅ RideViewModel listener will automatically update UI
      print("✅ Paymode changed successfully - RideViewModel listener will update UI");
    } catch (e) {
      Utils.showErrorMessage(context, "${loc.failed_change_payment_mode} $e");
    }
  }

  void _showPaymodeChangeDialog(BuildContext context, int currentPaymode) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ChangePayModeViewModel>(
          builder: (context, changePayModeVm, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(loc.change_payment_mode),
              content: changePayModeVm.loading
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(loc.changing_payment_mode),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.money,
                      color:
                      currentPaymode == 1 ? Colors.green : Colors.grey,
                    ),
                    title: Text(loc.cash_payment),
                    trailing: currentPaymode == 1
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: currentPaymode == 1
                        ? null
                        : () {
                      _changePaymode(context, 1);
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: currentPaymode == 2
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    title: Text(loc.online_payment),
                    trailing: currentPaymode == 2
                        ? Icon(Icons.check_circle, color: Colors.orange)
                        : null,
                    onTap: currentPaymode == 2
                        ? null
                        : () {
                      _changePaymode(context, 2);
                    },
                  ),
                ],
              ),
              actions: changePayModeVm.loading
                  ? []
                  : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRideCompletedDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 15),
              Text(
                loc.ride_completed_celebration,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loc.ride_completed_successfully_thank_you,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PortColor.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 45),
                ),
                onPressed: () {
                  print(
                    "🏠 OK pressed from ride completed - Navigating to Register",
                  );
                  Navigator.pop(context);
                  // Provider.of<UpdateRideStatusViewModel>(
                  //   context,
                  //   listen: false,
                  // ).updateRideApi(
                  //   context,
                  //   liveRideVm.liveOrderModel!.data!.id.toString(),
                  //   "6",
                  // );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                        (route) => false,
                  );
                  // rideStatus.setActiveRideData(null);
                  // rideStatus.disable78();
                },
                child:  Text(
                  loc.ok,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<RideViewModel>(
      builder: (context, rideViewModel, child) {
        final payMode = rideViewModel.activeRideData?['payMode'] ?? 1;
        final rideStatus = rideViewModel.activeRideData?['rideStatus'] ?? 0;
        final loc = AppLocalizations.of(context)!;
        print("🎨 CollectPaymentScreen - PayMode: $payMode, RideStatus: $rideStatus");

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
                actions: [
                  if (!(payMode == 2 && rideStatus == 6))
                    GestureDetector(
                      onTap: () => _showPaymodeChangeDialog(context, payMode),
                      child: Row(
                        children: [
                          TextConst(
                            title:
                            loc.change_pay_mode,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 1.5),
                            ),
                            child: Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                ]

            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 DYNAMIC ICON BASED ON STATE
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (payMode == 2 && rideStatus == 6)
                            ? Colors.green.withOpacity(0.1)
                            : payMode == 1
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (payMode == 2 && rideStatus == 6)
                            ? Icons.check_circle
                            : payMode == 1
                            ? Icons.money
                            : Icons.credit_card,
                        color: (payMode == 2 && rideStatus == 6)
                            ? Colors.green
                            : payMode == 1
                            ? Colors.green
                            : Colors.orange,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 24),

                    // 🔥 DYNAMIC TITLE BASED ON STATE
                    Text(
                      (payMode == 2 && rideStatus == 6)
                          ? loc.payment_successful
                          : payMode == 1
                          ? loc.cash_payment
                          : loc.online_payment,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: (payMode == 2 && rideStatus == 6)
                            ? Colors.green
                            : payMode == 1
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),

                    // 🔥 DYNAMIC CONTENT BASED ON STATE
                    if (payMode == 1) ...[
                      // ✅ CASH PAYMENT UI
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.collect_cash_from_customer,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      // SWIPE BUTTON FOR CASH PAYMENT
                      SlideToButton(
                        onAccepted: () => _handlePaymentComplete(context),
                        title: loc.pay_done,
                      ),
                    ] else if (payMode == 2 && rideStatus == 6) ...[
                      // ✅ PAYMENT SUCCESS UI (payMode=2 AND rideStatus=6)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                             Text(
                              loc.payment_completed_celebration,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc.customer_completed_online_payment,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // OK BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final rideStatus = Provider.of<RideViewModel>(
                              context,
                              listen: false,
                            );
                            final liveRideVm = Provider.of<LiveRideViewModel>(
                              context,
                              listen: false,
                            );

                            print("🏠 OK pressed - Navigating to Register");

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => Register()),
                                  (route) => false,
                            );
                            rideStatus.setActiveRideData(null);
                            rideStatus.disable78();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // ✅ ONLINE PAYMENT WAITING UI
                      Text(
                        loc.wait_for_customer_payment,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.waiting_for_payment,
                        style: TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}// WaitingForPaymentScreen is now part of CollectPaymentScreen
class LauncherI {
  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }
}

void _openWhatsApp({
  required String phone,
  String message = "",
}) async {
  final cleanNumber = phone
      .replaceAll("+", "")
      .replaceAll(" ", "")
      .replaceAll("-", "");

  final encodedMessage = Uri.encodeComponent(message);

  final Uri whatsappUrl = Uri.parse(
    "https://wa.me/$cleanNumber?text=$encodedMessage",
  );

  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint("❌ WhatsApp not installed");
  }
}