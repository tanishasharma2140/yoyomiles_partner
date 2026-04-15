import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
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
import 'package:yoyomiles_partner/view_model/update_stop_status_view_model.dart';
import 'package:yoyomiles_partner/model/live_ride_model.dart';

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
  int? _localRideStatus;
  bool _paymentScreenOpened = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveRideViewModel = Provider.of<LiveRideViewModel>(
        context,
        listen: false,
      );
      final rideViewModel = Provider.of<RideViewModel>(context, listen: false);

      rideViewModel.addListener(_onRideUpdate);

      liveRideViewModel.liveRideApi().then((_) {
        if (liveRideViewModel.liveOrderModel?.data != null) {
          final data = liveRideViewModel.liveOrderModel!.data!;
          pickupLat = double.tryParse(data.pickupLatitute.toString()) ?? 0.0;
          pickupLng = double.tryParse(data.pickLongitude.toString()) ?? 0.0;
          dropLat = double.tryParse(data.dropLatitute.toString()) ?? 0.0;
          dropLng = double.tryParse(data.dropLogitute.toString()) ?? 0.0;

          int status = data.rideStatus ?? 1;
          setState(() {
            _localRideStatus = status;
          });

          if (status == 5 && !_paymentScreenOpened) {
            _paymentScreenOpened = true;
            Future.delayed(
              const Duration(milliseconds: 300),
              () => _navigateToWaitingPaymentScreen(),
            );
          }
        }
      });
    });
  }

  void _onRideUpdate() {
    if (!mounted) return;
    final rideVm = Provider.of<RideViewModel>(context, listen: false);
    final socketStatus = rideVm.activeRideData?['rideStatus'];

    if (socketStatus != null && _localRideStatus != null) {
      setState(() {
        _localRideStatus = null;
      });
      print(
        "🔄 Local status cleared, Socket Status: $socketStatus took priority",
      );
    }
  }

  bool isSwitched = true;
  String? _currentAddress;
  bool _showPaymentSuccessDialog = false;
  bool _showRideCompletedDialog = false;

  Future<void> _openGoogleMapsDirections() async {
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final liveData = liveRideVm.liveOrderModel?.data;
    if (liveData == null) return;

    String destinationLat = dropLat.toString();
    String destinationLng = dropLng.toString();

    // Check for stops
    if (liveData.stops != null && liveData.stops!.isNotEmpty) {
      final pendingStop = liveData.stops!.indexWhere((s) => s.status.toString() == "0");
      if (pendingStop != -1) {
        destinationLat = liveData.stops![pendingStop].lat.toString();
        destinationLng = liveData.stops![pendingStop].lng.toString();
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url =
          "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$destinationLat,$destinationLng&travelmode=driving";
      await LauncherI.launchURL(url);
    } catch (e) {
      final url =
          "https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving";
      await LauncherI.launchURL(url);
    }
  }

  void _navigateToWaitingPaymentScreen() {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(
      context,
      listen: false,
    );
    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();
    print("🪟 Navigating to CollectPaymentScreen: $orderId");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollectPaymentScreen(orderId: orderId),
      ),
    );
  }

  void _showPaymentSuccessDialogMethod() {
    if (_showPaymentSuccessDialog) return;
    setState(() => _showPaymentSuccessDialog = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPaymentSuccessDialog(),
    ).then((_) => setState(() => _showPaymentSuccessDialog = false));
  }

  void _showRideCompletedDialogMethod() {
    if (_showRideCompletedDialog) return;
    setState(() => _showRideCompletedDialog = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildRideCompletedDialog(),
    ).then((_) => setState(() => _showRideCompletedDialog = false));
  }

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
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 15),
              Text(
                loc.payment_successful,
                style: const TextStyle(
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
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutesName.tripStatus,
                  (route) => route.settings.name == RoutesName.register,
                ),
                child: Text(
                  loc.ok,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideCompletedDialog() {
    final loc = AppLocalizations.of(context)!;
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final ride = Provider.of<RideViewModel>(context, listen: false);
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
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
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
                  Navigator.pop(context);
                  Provider.of<UpdateRideStatusViewModel>(
                    context,
                    listen: false,
                  ).updateRideApi(
                    context,
                    liveRideVm.liveOrderModel!.data!.id.toString(),
                    "",
                    "",
                    "",
                    "6",
                  );
                  ride.setActiveRideData(null);
                  ride.disable78();
                },
                child: Text(
                  loc.ok,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReachedButtonClick() async {
    final rideVm = Provider.of<RideViewModel>(context, listen: false);
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final updateRideStatusVm = Provider.of<UpdateRideStatusViewModel>(
      context,
      listen: false,
    );
    final updateStopStatusVm = Provider.of<UpdateStopStatusViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;
    final orderId = liveRideVm.liveOrderModel!.data!.id.toString();
    final liveData = liveRideVm.liveOrderModel!.data!;

    if (liveData.stops != null && liveData.stops!.isNotEmpty) {
      final pendingStopIndex = liveData.stops!.indexWhere((s) => s.status.toString() == "0");
      if (pendingStopIndex != -1) {
        await updateStopStatusVm.updateStopStatusApi(
          context: context,
          orderId: orderId,
          stopIndex: pendingStopIndex.toString(),
        );
        await liveRideVm.liveRideApi();
        await _openGoogleMapsDirections();
        return;
      }
    }

    try {
      final payMode =
          rideVm.activeRideData?['payMode'] ??
          liveRideVm.liveOrderModel?.data?.paymode ??
          0;
      print("💰 Destination Reached | payMode detected: $payMode");

      if (payMode == 3) {
        await updateRideStatusVm.updateRideApi(
          context,
          orderId,
          "",
          "",
          "",
          "6",
          navigateAfter: true,
        );
        Utils.showSuccessMessage(context, loc.ride_completed_wallet);
        Future.delayed(
          const Duration(milliseconds: 300),
          () => _showRideCompletedDialogMethod(),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String lat = position.latitude.toString();
      String lng = position.longitude.toString();

      await updateRideStatusVm.updateRideApi(
        context,
        orderId,
        "",
        lat,
        lng,
        "5",
      );
      Utils.showSuccessMessage(
        context,
        (payMode == 1)
            ? loc.reached_destination
            : loc.ride_status_reached_destination,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CollectPaymentScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      Utils.showErrorMessage(context, "${loc.failed_update_ride_status} $e");
    }
  }

  // void _showGoToMapDialog() {
  //   final loc = AppLocalizations.of(context)!;
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(18),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(Icons.check_circle, color: Colors.green, size: 40),
  //             const SizedBox(height: 12),
  //             TextConst(
  //               title: loc.otp_verified,
  //               size: 16,
  //               fontWeight: FontWeight.w700,
  //             ),
  //             const SizedBox(height: 8),
  //             TextConst(
  //               title: loc.open_google_maps_navigation,
  //               textAlign: TextAlign.center,
  //               size: 13,
  //               color: Colors.black54,
  //             ),
  //             const SizedBox(height: 18),
  //             InkWell(
  //               onTap: () async {
  //                 Navigator.pop(context);
  //                 await _openGoogleMapsDirections();
  //               },
  //               borderRadius: BorderRadius.circular(8),
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: const EdgeInsets.symmetric(vertical: 12),
  //                 decoration: BoxDecoration(
  //                   color: PortColor.gold,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     loc.go_to_map,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    Provider.of<RideViewModel>(
      context,
      listen: false,
    ).removeListener(_onRideUpdate);
    super.dispose();
  }

  Future<void> _openGoogleMapsFromCurrentLocation() async {
    final loc = AppLocalizations.of(context)!;
    final pickupLatLng = "$pickupLat,$pickupLng";
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url =
          "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$pickupLatLng&travelmode=driving";
      await LauncherI.launchURL(url);
    } catch (e) {
      final url =
          "https://www.google.com/maps/dir/?api=1&destination=$pickupLatLng&travelmode=driving";
      await LauncherI.launchURL(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: SafeArea(
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
              return Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ConstMap(
                      data: [widget.booking],
                      rideStatus:
                          liveRideViewModel.liveOrderModel?.data?.rideStatus,
                      onAddressFetched: (address) =>
                          setState(() => _currentAddress = address),
                    ),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.75,
                    minChildSize: 0.45,
                    maxChildSize: 0.77,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: _buildSheetContent(
                          scrollController,
                          rideVm.activeRideData,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(int? rideStatus, Data? liveData) {
    if (rideStatus == 4 && liveData?.stops != null && liveData!.stops!.isNotEmpty) {
      final pendingStop = liveData.stops!.indexWhere((s) => s.status.toString() == "0");
      if (pendingStop != -1) {
        return Colors.orangeAccent;
      }
    }
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

  String _getButtonText(int? status, Data? liveData) {
    final loc = AppLocalizations.of(context)!;
    if (status == 4 && liveData?.stops != null && liveData!.stops!.isNotEmpty) {
      final pendingStop = liveData.stops!.indexWhere((s) => s.status.toString() == "0");
      if (pendingStop != -1) {
        return "Reached Stop ${pendingStop + 1}";
      }
    }
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
    final loc = AppLocalizations.of(context)!;
    final rideVm = Provider.of<RideViewModel>(context, listen: false);
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final updateRideStatusVm = Provider.of<UpdateRideStatusViewModel>(
      context,
      listen: false,
    );

    final savedOtp =
        rideVm.activeRideData?['otp']?.toString().isNotEmpty == true
        ? rideVm.activeRideData!['otp'].toString()
        : liveRideVm.liveOrderModel?.data?.otp?.toString() ?? '';

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
                  style: const TextStyle(
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
                    hintStyle: const TextStyle(color: Colors.grey),
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
                        child: Text(
                          loc.cancel,
                          style: const TextStyle(color: Colors.black),
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
                            Utils.showErrorMessage(
                              context,
                              loc.please_enter_otp,
                            );
                            return;
                          }
                          if (savedOtp == enteredOtp) {
                            setState(() {
                              _localRideStatus = 4;
                              isOtpVerified = true;
                            });
                            Navigator.of(context).pop();

                            await updateRideStatusVm.updateRideApi(
                              context,
                              orderId,
                              enteredOtp,
                              "",
                              "",
                              "4",
                            );
                            buildNavigateFromMapButton();
                          } else {
                            Utils.showErrorMessage(
                              context,
                              loc.invalid_otp_try_again,
                            );
                          }
                        },
                        child: Text(
                          loc.verify,
                          style: const TextStyle(color: Colors.white),
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
    final contactListVm = Provider.of<ContactListViewModel>(
      context,
      listen: false,
    );
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
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 22,
                ),
                const SizedBox(width: 6),
                TextConst(
                  title: loc.emergency,
                  size: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () =>
                _openWhatsApp(phone: supportNumber, message: sosMessage),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextConst(
                title: loc.sos,
                color: Colors.white,
                size: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openWhatsApp(
              phone: supportNumber,
              message: loc.support_help_message,
            ),
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
    IconData? icon,
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
          if (icon != null) ...[
            Icon(icon, color: PortColor.gold, size: 16),
            SizedBox(width: Sizes.screenWidth * 0.02),
          ],
          SizedBox(
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
    Map<String, dynamic>? activeRideDataFromSocket,
  ) {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    if (liveRideViewModel.liveOrderModel == null || liveRideViewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(color: PortColor.gold),
      );
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
    final liveData = liveRideViewModel.liveOrderModel!.data!;
    final int rs =
        _localRideStatus ??
        activeRideDataFromSocket?['rideStatus'] ??
        liveData.rideStatus ??
        1;
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
                          content: liveData.id.toString(),
                          isHeader: true,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.008),
                        _buildDetailRow(
                          title: loc.vehicle_type,
                          content: liveData.vehicleName ?? "N/A",
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
                            const Icon(
                              Icons.currency_rupee,
                              color: Colors.green,
                              size: 14,
                            ),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title: '${liveData.amount ?? '0'}',
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
                            const Icon(
                              Icons.space_dashboard,
                              color: Colors.blue,
                              size: 14,
                            ),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title: '${liveData.distance ?? '0'} km',
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
                      liveData.senderPhone?.toString() ?? '9876543210',
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
                          const Icon(Icons.call, color: Colors.black, size: 16),
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
        const Divider(height: 1),
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
                  if (liveData.orderType.toString() == "2") ...[
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content: liveData.pickupAddress ?? "N/A",
                      isAddress: true,
                      bold: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      title: loc.name,
                      content: liveData.senderName ?? "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: loc.phone,
                      content: liveData.senderPhone?.toString() ?? "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content: liveData.pickupAddress ?? "N/A",
                      isAddress: true,
                    ),
                  ],
                  if (liveData.stops != null && liveData.stops!.isNotEmpty) ...[
                    SizedBox(height: Sizes.screenHeight * 0.015),
                    const Divider(height: 1),
                    SizedBox(height: Sizes.screenHeight * 0.015),
                    _buildSectionHeader("Stops"),
                    SizedBox(height: Sizes.screenHeight * 0.01),
                    ...liveData.stops!.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Stops stop = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.stop_circle_outlined,
                            title: "Stop ${idx + 1}",
                            content: stop.name ?? "N/A",
                            bold: true,
                          ),
                          _buildDetailRow(
                            title: "Phone",
                            content: stop.phone ?? "N/A",
                          ),
                          _buildDetailRow(
                            title: "Address",
                            content: stop.address ?? "N/A",
                            isAddress: true,
                          ),
                          _buildDetailRow(
                            title: "Status",
                            content: stop.status.toString() == "1" ? "Reached" : "Pending",
                            bold: true,
                          ),
                          if (idx != liveData.stops!.length - 1) const Divider(height: 16),
                        ],
                      );
                    }).toList(),
                  ],
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  const Divider(height: 1),
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildSectionHeader(loc.receiver_details),
                  SizedBox(height: Sizes.screenHeight * 0.01),
                  if (liveData.orderType.toString() == "2") ...[
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content: liveData.dropAddress ?? "N/A",
                      isAddress: true,
                      bold: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      title: loc.name,
                      content: liveData.reciverName ?? "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: loc.phone,
                      content: liveData.reciverPhone?.toString() ?? "N/A",
                    ),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: loc.address,
                      content: liveData.dropAddress ?? "N/A",
                      isAddress: true,
                    ),
                  ],
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  const Divider(height: 1),
                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildEmergencySection(),
                  SizedBox(height: Sizes.screenHeight * 0.012),
                  if (rs == 2) buildNavigateToMapButton(),
                  if (rs == 4)  buildNavigateFromMapButton(),
                  SizedBox(height: Sizes.screenHeight * 0.012),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Sizes.screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: PortColor.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: PortColor.gold, size: 18),
                        SizedBox(width: Sizes.screenWidth * 0.02),
                        Expanded(
                          child: TextConst(
                            title:
                                "${loc.current_status} ${_getStatusText(rs)}",
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
                            final updateRideStatusVm =
                                Provider.of<UpdateRideStatusViewModel>(
                                  context,
                                  listen: false,
                                );
                            final orderId = liveData.id.toString();
                            int currentStatus = rs;
                            try {
                              if (currentStatus == 1) {
                                setState(() {
                                  _localRideStatus = 2;
                                });
                                await updateRideStatusVm.updateRideApi(
                                  context,
                                  orderId,
                                  "",
                                  "",
                                  "",
                                  "2",
                                );
                                buildNavigateToMapButton();
                                // _showGoToMapPopupFromCurrentLocation();
                                Utils.showSuccessMessage(
                                  context,
                                  loc.ride_status_start_pickup,
                                );
                              } else if (currentStatus == 2) {
                                setState(() {
                                  _localRideStatus = 3;
                                });
                                await updateRideStatusVm.updateRideApi(
                                  context,
                                  orderId,
                                  "",
                                  "",
                                  "",
                                  "3",
                                );
                                Utils.showSuccessMessage(
                                  context,
                                  loc.ride_status_arrived_pickup,
                                );
                              } else if (currentStatus == 3) {
                                _showOtpDialog(orderId);
                              } else if (currentStatus == 4) {
                                _handleReachedButtonClick();
                              }
                            } catch (e) {
                              setState(() => _localRideStatus = currentStatus);
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
                              color: _getButtonColor(rs, liveData),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextConst(
                                title: _getButtonText(rs, liveData),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                size: Sizes.fontSizeFive,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (rs < 4) ...[
                        SizedBox(width: Sizes.screenWidth * 0.03),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                Provider.of<UpdateRideStatusViewModel>(
                                  context,
                                  listen: false,
                                ).updateRideApi(
                                  context,
                                  liveData.id.toString(),
                                  "",
                                  "",
                                  "",
                                  "8",
                                  navigateAfter: true,
                                ),
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
                                    const Icon(
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
  Widget buildNavigateToMapButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () async {
          await _openGoogleMapsFromCurrentLocation();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: PortColor.gold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation, color: Colors.black),
              SizedBox(width: 8),
              TextConst(
                title:
                "Navigate to Pickup Location",
                color: PortColor.black,
                size: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigateFromMapButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () async {
          await _openGoogleMapsDirections();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: PortColor.gold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation, color: Colors.black),
              SizedBox(width: 8),
              TextConst(
                title:
                "Navigate to Drop Location",
                color: PortColor.black,
                size: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectPaymentScreen extends StatelessWidget {
  final String orderId;
  const CollectPaymentScreen({super.key, required this.orderId});

  void _handlePaymentComplete(BuildContext context) async {
    final liveRideVm = Provider.of<LiveRideViewModel>(context, listen: false);
    final rideStatus = Provider.of<RideViewModel>(context, listen: false);
    final updateRideVM = Provider.of<UpdateRideStatusViewModel>(
      context,
      listen: false,
    );
    final loc = AppLocalizations.of(context)!;
    try {
      await updateRideVM.updateRideApi(
        context,
        liveRideVm.liveOrderModel!.data!.id.toString(),
        "",
        "",
        "",
        "6",
      );
      rideStatus.setActiveRideData(null);
      rideStatus.disable78();
      Utils.showSuccessMessage(context, loc.ride_completed_successfully);
      Navigator.of(context).pop();
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
      await changePayModeViewModel.changePayModeApi(
        context: context,
        orderId: orderId,
        payMode: newPaymode,
      );
      Utils.showSuccessMessage(context, "Paymode Change Success");
    } catch (e) {
      Utils.showErrorMessage(context, "${loc.failed_change_payment_mode} $e");
    }
  }

  void _showPaymodeChangeDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer2<ChangePayModeViewModel, RideViewModel>(
          builder: (context, changePayModeVm, rideVm, child) {
            final liveRideVm = Provider.of<LiveRideViewModel>(
              context,
              listen: false,
            );
            final payMode =
                rideVm.activeRideData?['payMode'] ??
                    liveRideVm.liveOrderModel?.data?.paymode ??
                    0;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(loc.change_payment_mode),
              content: changePayModeVm.loading
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(loc.changing_payment_mode),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.money,
                      color: payMode == 1 ? Colors.green : Colors.grey,
                    ),
                    title: Text(loc.cash_payment),
                    trailing: payMode == 1
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : null,
                    onTap: payMode == 1
                        ? null
                        : () => _changePaymode(context, 1),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: payMode == 2 ? Colors.orange : Colors.grey,
                    ),
                    title: Text(loc.online_payment),
                    trailing: payMode == 2
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                    )
                        : null,
                    onTap: payMode == 2
                        ? null
                        : () => _changePaymode(context, 2),
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
    final rideStatus = Provider.of<RideViewModel>(context, listen: false);
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
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
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
                  rideStatus.setActiveRideData(null);
                  rideStatus.disable78();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Register()),
                        (route) => false,
                  );
                },
                child: Text(
                  loc.ok,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
    return Consumer2<RideViewModel, ChangePayModeViewModel>(
      builder: (context, rideViewModel, changePayModeVm, child) {
        final liveRideVm = Provider.of<LiveRideViewModel>(
          context,
          listen: false,
        );
        final activeData = rideViewModel.activeRideData;
        final int rideStatus = activeData?['rideStatus'] ?? 0;
        final int payMode =
            activeData?['payMode'] ??
                liveRideVm.liveOrderModel?.data?.paymode ??
                0;
        final loc = AppLocalizations.of(context)!;
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                if (rideStatus != 6)
                  GestureDetector(
                    onTap: () => _showPaymodeChangeDialog(context),
                    child: Row(
                      children: [
                        TextConst(
                          title: loc.change_pay_mode,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (rideStatus == 6)
                            ? Colors.green.withOpacity(0.1)
                            : payMode == 1
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (rideStatus == 6)
                            ? Icons.check_circle
                            : payMode == 1
                            ? Icons.money
                            : Icons.credit_card,
                        color: (rideStatus == 6)
                            ? Colors.green
                            : payMode == 1
                            ? Colors.green
                            : Colors.orange,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      (rideStatus == 6)
                          ? loc.payment_successful
                          : payMode == 1
                          ? loc.cash_payment
                          : loc.online_payment,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: (rideStatus == 6)
                            ? Colors.green
                            : payMode == 1
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (payMode == 1 && rideStatus != 6) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.collect_cash_from_customer,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SlideToButton(
                        onAccepted: () => _handlePaymentComplete(context),
                        title: loc.pay_done,
                      ),
                    ] else if (rideStatus == 6) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.payment_completed_celebration,
                              style: const TextStyle(
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const Register(),
                              ),
                                  (route) => false,
                            );
                            rideViewModel.setActiveRideData(null);
                            rideViewModel.disable78();
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
                      Text(
                        loc.wait_for_customer_payment,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.waiting_for_payment,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                        ),
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
}

class LauncherI {
  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }
}

void _openWhatsApp({required String phone, String message = ""}) async {
  final cleanNumber = phone
      .replaceAll("+", "")
      .replaceAll(" ", "")
      .replaceAll("-", "");
  final encodedMessage = Uri.encodeComponent(message);
  final Uri whatsappUrl = Uri.parse(
    "https://wa.me/$cleanNumber?text=$encodedMessage",
  );
  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  } else {
    debugPrint("❌ WhatsApp not installed");
  }
}
