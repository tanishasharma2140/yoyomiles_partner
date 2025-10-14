import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/const_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';

class LiveRideScreen extends StatefulWidget {
  const LiveRideScreen({super.key});

  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Shrutii");
      final liveRideViewModel = Provider.of<LiveRideViewModel>(
        context,
        listen: false,
      );
      liveRideViewModel.liveRideApi();
      print("tanu");
    });
  }

  bool isSwitched = true;
  String? _currentAddress;

  void _showSwitchDialog(bool value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final onlineStatusViewModel = Provider.of<OnlineStatusViewModel>(
          context,
        );
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(Sizes.screenHeight * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: PortColor.gray),
              color: PortColor.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Assets.assetsOffline),
                SizedBox(height: Sizes.screenHeight * 0.02),
                TextConst(
                  title: 'Are you sure you want to go offline?',
                  size: Sizes.fontSizeFive,
                  fontWeight: FontWeight.bold,
                  color: PortColor.gold,
                ),
                SizedBox(height: Sizes.screenHeight * 0.02),
                TextConst(
                  title: 'You can always switch back online later.',
                  size: Sizes.fontSizeFour,
                  color: PortColor.gray,
                ),
                SizedBox(height: Sizes.screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onlineStatusViewModel.onlineStatusApi(context, 0);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: Sizes.screenHeight * 0.05,
                        width: Sizes.screenWidth * 0.07,
                        child: const TextConst(
                          title: "Yes",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isSwitched = true;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: Sizes.screenHeight * 0.05,
                        width: Sizes.screenWidth * 0.06,
                        child: const TextConst(
                          title: "No",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void _showWaitingForPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_filled,
                  color: Colors.orange,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Waiting for Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please wait while the customer completes the payment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
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
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        body: Column(
          children: [
            SizedBox(height: topPadding),
            // Header Section
            Container(
              height: Sizes.screenHeight * 0.085,
              decoration: BoxDecoration(
                color: PortColor.white,
                border: Border(
                  bottom: BorderSide(
                    color: PortColor.gray,
                    width: Sizes.screenWidth * 0.001,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: Sizes.screenWidth * 0.03),
                  ClipOval(
                    child: Image.network(
                      profileViewModel.profileModel!.data!.ownerSelfie ?? "",
                      height: Sizes.screenHeight * 0.06,
                      width: Sizes.screenHeight * 0.06,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: Sizes.screenHeight * 0.06,
                        width: Sizes.screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: PortColor.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: PortColor.white),
                      ),
                    ),
                  ),
                  SizedBox(width: Sizes.screenWidth * 0.02),
                  Expanded(
                    child: TextConst(
                      title:
                          profileViewModel.profileModel!.data!.driverName ??
                          "Driver",
                      size: Sizes.fontSizeSeven,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                        if (!value) {
                          _showSwitchDialog(value);
                        }
                      },
                      activeColor: PortColor.grey,
                      inactiveThumbColor: Colors.blue[50],
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: Sizes.screenWidth * 0.03),
                ],
              ),
            ),

            // Map Section - Fixed Half Screen with proper constraints
            Expanded(
              flex: 5, // 50% of screen
              child: SizedBox(
                width: double.infinity,
                child: ConstMap(
                  onAddressFetched: (address) {
                    setState(() {
                      _currentAddress = address;
                    });
                  },
                ),
              ),
            ),

            // Current Location Chip
            if (_currentAddress != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.04,
                  vertical: Sizes.screenHeight * 0.01,
                ),
                color: PortColor.white,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: PortColor.gold, size: 16),
                    SizedBox(width: Sizes.screenWidth * 0.02),
                    Expanded(
                      child: TextConst(
                        title: _currentAddress!,
                        size: Sizes.fontSizeFour,
                        color: PortColor.blackLight,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Ride Details Section - Scrollable
            Expanded(
              flex: 5, // 50% of screen
              child: _buildRideDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetails() {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    final updateRideStatus = Provider.of<UpdateRideStatusViewModel>(context);

    if (liveRideViewModel.liveOrderModel == null || liveRideViewModel.loading) {
      return Center(child: CircularProgressIndicator(color: PortColor.gold));
    }

    // If no live ride data, show empty state
    if (liveRideViewModel.liveOrderModel!.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.assetsNoData, height: Sizes.screenHeight * 0.15),
            SizedBox(height: Sizes.screenHeight * 0.02),
            TextConst(
              title: "No Active Ride",
              color: PortColor.gold,
              fontWeight: FontWeight.bold,
              size: Sizes.fontSizeSix,
            ),
            SizedBox(height: Sizes.screenHeight * 0.01),
            TextConst(
              title: "You don't have any active ride at the moment",
              color: PortColor.gray,
              size: Sizes.fontSizeFour,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.screenWidth * 0.03,
        vertical: Sizes.screenHeight * 0.01,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: PortColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PortColor.greyLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Sizes.screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          icon: Icons.confirmation_number,
                          title: "Booking ID",
                          content: liveRideViewModel.liveOrderModel!.data!.id
                              .toString(),
                          isHeader: true,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.008),
                        _buildDetailRow(
                          icon: Icons.directions_car,
                          title: "Vehicle Type",
                          content:
                              liveRideViewModel
                                  .liveOrderModel!
                                  .data!
                                  .vehicleType ??
                              "N/A",
                          isHeader: true,
                        ),
                      ],
                    ),
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
                            title: 'Call',
                            color: Colors.black,
                            size: Sizes.fontSizeFour,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Sizes.screenHeight * 0.015),
              Divider(height: 1),

              // Sender Details
              SizedBox(height: Sizes.screenHeight * 0.015),
              _buildSectionHeader("Sender Details"),
              SizedBox(height: Sizes.screenHeight * 0.01),
              _buildDetailRow(
                icon: Icons.person_outline,
                title: "Name",
                content:
                    liveRideViewModel.liveOrderModel!.data!.senderName ?? "N/A",
              ),
              _buildDetailRow(
                icon: Icons.phone,
                title: "Phone",
                content:
                    liveRideViewModel.liveOrderModel!.data!.senderPhone
                        ?.toString() ??
                    "N/A",
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                title: "Address",
                content:
                    liveRideViewModel.liveOrderModel!.data!.pickupAddress ??
                    "N/A",
                isAddress: true,
              ),

              SizedBox(height: Sizes.screenHeight * 0.015),
              Divider(height: 1),

              // Receiver Details
              SizedBox(height: Sizes.screenHeight * 0.015),
              _buildSectionHeader("Receiver Details"),
              SizedBox(height: Sizes.screenHeight * 0.01),
              _buildDetailRow(
                icon: Icons.person_outline,
                title: "Name",
                content:
                    liveRideViewModel.liveOrderModel!.data!.reciverName ??
                    "N/A",
              ),
              _buildDetailRow(
                icon: Icons.phone,
                title: "Phone",
                content:
                    liveRideViewModel.liveOrderModel!.data!.reciverPhone
                        ?.toString() ??
                    "N/A",
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                title: "Address",
                content:
                    liveRideViewModel.liveOrderModel!.data!.dropAddress ??
                    "N/A",
                isAddress: true,
              ),

              SizedBox(height: Sizes.screenHeight * 0.015),
              Divider(height: 1),
              SizedBox(height: Sizes.screenHeight * 0.015),

              // Current Status
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
                            "Current Status: ${_getStatusText(liveRideViewModel.liveOrderModel!.data!.rideStatus)}",
                        size: Sizes.fontSizeFive,
                        fontWeight: FontWeight.w600,
                        color: PortColor.gold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Sizes.screenHeight * 0.02),

              // Action Buttons
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
                            liveRideViewModel
                                .liveOrderModel!
                                .data!
                                .rideStatus ??
                            1;

                        try {
                          if (currentStatus == 1) {
                            // ✅ Accepted -> Out for Pickup
                            await FirebaseFirestore.instance
                                .collection('order')
                                .doc(orderId.toString())
                                .update({'ride_status': 2});

                            liveRideViewModel.liveOrderModel!.data!.rideStatus =
                                2;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Ride status updated: Start for Pickup Location",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (currentStatus == 2) {
                            // ✅ Out for Pickup -> Arrived at Pickup Point
                            await FirebaseFirestore.instance
                                .collection('order')
                                .doc(orderId.toString())
                                .update({'ride_status': 3});

                            liveRideViewModel.liveOrderModel!.data!.rideStatus =
                                3;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Ride status updated: Arrived at Pickup Point",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (currentStatus == 3) {
                            // ✅ Arrived at Pickup -> OTP verification popup
                            _showOtpDialog(orderId.toString());
                            return;
                          } else if (currentStatus == 4) {
                            // ✅ Ride started -> reached destination
                            await FirebaseFirestore.instance
                                .collection('order')
                                .doc(orderId.toString())
                                .update({'ride_status': 5});

                            liveRideViewModel.liveOrderModel!.data!.rideStatus =
                                5;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Ride status updated: Reached destination",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            final payMode =
                                liveRideViewModel
                                    .liveOrderModel!
                                    .data!.paymode??
                                0;
                            if (payMode == 2) {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  _showWaitingForPaymentDialog();
                                },
                              );
                            }
                          }

                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to update ride status: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Sizes.screenHeight * 0.014,
                        ),
                        decoration: BoxDecoration(
                          color: PortColor.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextConst(
                            title: _getButtonText(
                              liveRideViewModel
                                  .liveOrderModel!
                                  .data!
                                  .rideStatus,
                            ),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            size: Sizes.fontSizeFive,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: Sizes.screenWidth * 0.03),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        updateRideStatus.updateRideApi(
                          context,
                          liveRideViewModel.liveOrderModel!.data!.id.toString(),
                          "8",
                        );
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
                                title: 'Reject',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(int? status) {
    switch (status) {
      case 1:
        return "Start for Pickup";
      case 2:
        return "Arrived at Pickup Point";
      case 3:
        return "Start Ride";
      case 4:
        return "Reached"; // 👈 when status = 4, show 'Reached'
      case 5:
        return "Ride Completed"; // 👈 final state after reaching
      default:
        return "Start for Pickup";
    }
  }

  void _showOtpDialog(String orderId) {
    final TextEditingController _otpController = TextEditingController();
    final liveRideViewModel = Provider.of<LiveRideViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white, // White background
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
                "Trip OTP Verification",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.kanitReg,
                  color: Colors.black, // Black text for clarity
                ),
              ),
              const SizedBox(height: 20),

              // OTP input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // grey border when not focused
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey, // grey border when focused
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
                      child: const Text(
                        "Cancel",
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter OTP"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final doc = await FirebaseFirestore.instance
                              .collection('order')
                              .doc(orderId)
                              .get();

                          final firestoreOtp =
                              doc.data()?['otp']?.toString() ?? "";

                          if (firestoreOtp == enteredOtp) {
                            await FirebaseFirestore.instance
                                .collection('order')
                                .doc(orderId)
                                .update({'ride_status': 4});

                            liveRideViewModel.liveOrderModel!.data!.rideStatus =
                                4;

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("OTP verified! Ride started."),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP. Try again."),
                                backgroundColor: Colors.red,
                              ),
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
                      child: const Text(
                        "Verify",
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    bool isAddress = false,
    bool isHeader = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.screenHeight * 0.01),
      child: Row(
        crossAxisAlignment: isAddress
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: PortColor.gold, size: 16),
          SizedBox(width: Sizes.screenWidth * 0.02),
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
              maxLines: isAddress ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int? rideStatus) {
    switch (rideStatus) {
      case 1:
        return "Accepted by Driver";
      case 2:
        return "Out for PickUp";
      case 3:
        return "At Pickup Point";
      case 4:
        return "Ride Started";
      default:
        return "Unknown Status";
    }
  }
}
