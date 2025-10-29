import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/const_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_appbar.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';

class LiveRideScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  const LiveRideScreen({super.key, required this.booking});

  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveRideViewModel = Provider.of<LiveRideViewModel>(
        context,
        listen: false,
      );
      liveRideViewModel.liveRideApi().then((_) {
        // ✅ YEH LINE ADD KARO - Listener start karo after data load
        if (liveRideViewModel.liveOrderModel?.data?.id != null) {
          _startRideStatusListener(liveRideViewModel.liveOrderModel!.data!.id.toString());
        }
      });
    });
  }

  bool isSwitched = true;
  String? _currentAddress;

  // 🔥 ALAG-ALAG FLAGS FOR DIFFERENT DIALOGS
  bool _showWaitingForPaymentDialog = false;
  bool _showPaymentSuccessDialog = false;
  bool _showRideCompletedDialog = false;
  bool _showRideCancelledDialog = false;

  StreamSubscription<DocumentSnapshot>? _paymentSubscription;
  StreamSubscription<DocumentSnapshot>? _rideStatusSubscription;

  // 🔥 WAITING FOR PAYMENT DIALOG - ALAG FUNCTION
  void _showWaitingForPaymentDialogMethod() {
    if (_showWaitingForPaymentDialog) {
      print("⚠️ Waiting payment dialog already showing");
      return;
    }

    final liveRideViewModel = Provider.of<LiveRideViewModel>(context, listen: false);
    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();

    print("🪟 Showing WAITING payment dialog for order: $orderId");

    setState(() {
      _showWaitingForPaymentDialog = true;
    });

    _startPaymentListener(orderId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildWaitingForPaymentDialog();
      },
    ).then((_) {
      print("🔒 Waiting payment dialog closed");
      setState(() {
        _showWaitingForPaymentDialog = false;
      });
      _paymentSubscription?.cancel();
      _paymentSubscription = null;
    });
  }

  // 🔥 PAYMENT SUCCESS DIALOG - ALAG FUNCTION
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
  void _showRideCancelledDialogMethod(String userName) {
    if (_showRideCancelledDialog) {
      print("⚠️ Ride cancelled dialog already showing");
      return;
    }

    print("❌ Showing RIDE CANCELLED dialog by user: $userName");

    setState(() {
      _showRideCancelledDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildRideCancelledDialog(userName);
      },
    ).then((_) {
      print("🔒 Ride cancelled dialog closed");
      setState(() {
        _showRideCancelledDialog = false;
      });

      // ✅ Register screen par navigate karo
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Register()),
            (route) => false,
      );
    });
  }

  // 🔥 ALAG-ALAG DIALOG WIDGETS
  Widget _buildWaitingForPaymentDialog() {
    return WillPopScope(
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
                Icons.access_time_filled,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "Waiting for Payment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Please wait while the customer completes the payment.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Waiting for payment...",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
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

  Widget _buildPaymentSuccessDialog() {
    return WillPopScope(
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
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "Payment Successful!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Payment has been successfully received. Thank you!",
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
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
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
 final liveRideVm = Provider.of<LiveRideViewModel>(context);
    return WillPopScope(
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
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "Ride Completed!🎉🎉",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PortColor.gold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your ride has been completed successfully. Thank you!",
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
                  print("🏠 OK pressed from ride completed - Navigating to Register");
                  Navigator.pop(context);
                  Provider.of<UpdateRideStatusViewModel>(context,listen: false).updateRideApi(context, liveRideVm.liveOrderModel!.data!.id.toString(), "6");
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
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
    return WillPopScope(
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
                Icons.cancel,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "Ride Cancelled!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ride has been cancelled by $userName",
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
                  print("🏠 OK pressed from cancelled - Navigating to Register");
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Register()),
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Listen for ride_status changes for payment flow
  void _startPaymentListener(String orderId) {
    print("🔔 Starting payment listener for order: $orderId");

    try {
      _paymentSubscription = FirebaseFirestore.instance
          .collection('order')
          .doc(orderId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final rideStatus = data['ride_status'] ?? 0;
          print("📢 Payment Listener - ride_status: $rideStatus");

          // 🔥 AGAR WAITING DIALOG SHOW HAI AUR STATUS 6 HO GAYA
          if (_showWaitingForPaymentDialog && rideStatus == 6) {
            print("💰 Payment successful detected! Closing waiting dialog and showing success");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Pehle waiting dialog band karo
              Navigator.of(context).pop();

              // Phir success dialog show karo
              _showPaymentSuccessDialogMethod();
            });
          }
        }
      }, onError: (error) {
        print("🔥 Payment listener error: $error");
      });
    } catch (e) {
      print("❌ Error starting payment listener: $e");
    }
  }

  // ✅ FIXED: Listen for ride status changes (specifically for status 7 - cancelled)
  void _startRideStatusListener(String orderId) {
    print("🔔 Starting ride status listener for order: $orderId");

    try {
      _rideStatusSubscription = FirebaseFirestore.instance
          .collection('order')
          .doc(orderId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final rideStatus = data['ride_status'] ?? 0;
          final userName = data['sender_name'] ?? 'User';

          print("📢 Ride Status Listener - ride_status: $rideStatus, user: $userName");

          // 🔥 AGAR RIDE STATUS 7 HO GAYA (CANCELLED)
          if (rideStatus == 7 && !_showRideCancelledDialog) {
            print("❌ Ride cancelled detected! Showing cancelled dialog");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Cancel dialog show karo
              _showRideCancelledDialogMethod(userName);
            });
          }
        }
      }, onError: (error) {
        print("🔥 Ride status listener error: $error");
      });
    } catch (e) {
      print("❌ Error starting ride status listener: $e");
    }
  }

  // Check if payment is already completed when reaching status 5
  void _checkPaymentStatus() {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context, listen: false);
    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();

    print("🔍 Checking payment status for order: $orderId");

    FirebaseFirestore.instance
        .collection('order')
        .doc(orderId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final rideStatus = data['ride_status'] ?? 0;
        final payMode = data['paymode'] ?? 0;

        print("📊 Current status - ride_status: $rideStatus, paymode: $payMode");

        if (rideStatus == 5 && payMode == 2) {
          print("💵 Showing waiting dialog from manual check");
          // Check if already at status 6
          if (rideStatus == 6) {
            print("💰 Already paid - showing success dialog");
            Future.delayed(const Duration(milliseconds: 300), () {
              _showPaymentSuccessDialogMethod();
            });
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              _showWaitingForPaymentDialogMethod();
            });
          }
        } else if (rideStatus == 6) {
          print("💰 Showing success dialog from manual check");
          Future.delayed(const Duration(milliseconds: 300), () {
            _showPaymentSuccessDialogMethod();
          });
        }
      }
    }).catchError((error) {
      print("❌ Error checking payment status: $error");
    });
  }

  // NEW: Handle Reached button click with paymode condition
  void _handleReachedButtonClick() async {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context, listen: false);
    final orderId = liveRideViewModel.liveOrderModel!.data!.id.toString();

    try {
      // First get current order data to check paymode
      final doc = await FirebaseFirestore.instance
          .collection('order')
          .doc(orderId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final payMode = data['paymode'] ?? 0;

        print("💰 Reached button clicked - paymode: $payMode");

        if (payMode == 1) {
          // Cash payment - update to status 6 and show ride completed dialog
          print("💵 Cash payment detected - updating to status 6");
          await FirebaseFirestore.instance
              .collection('order')
              .doc(orderId)
              .update({'ride_status': 6});

          liveRideViewModel.liveOrderModel!.data!.rideStatus = 6;
          Utils.showSuccessMessage(context, "Ride completed successfully!");

          // Show ride completed dialog
          Future.delayed(const Duration(milliseconds: 500), () {
            _showRideCompletedDialogMethod();
          });
        } else {
          // Online payment - update to status 5 and show waiting for payment
          print("💳 Online payment detected - updating to status 5");
          await FirebaseFirestore.instance
              .collection('order')
              .doc(orderId)
              .update({'ride_status': 5});

          liveRideViewModel.liveOrderModel!.data!.rideStatus = 5;
          Utils.showSuccessMessage(context, "Ride status updated: Reached destination");

          // Show waiting for payment dialog
          Future.delayed(const Duration(milliseconds: 500), () {
            _showWaitingForPaymentDialogMethod();
          });
        }
        setState(() {});
      }
    } catch (e) {
      Utils.showErrorMessage(context, "Failed to update ride status: $e");
    }
  }

  @override
  void dispose() {
    print("🗑️ Disposing LiveRideScreen - Cancelling listeners");
    _paymentSubscription?.cancel();
    _rideStatusSubscription?.cancel();
    super.dispose();
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
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ConstMap(
                data: [widget.booking],
                rideStatus: liveRideViewModel.liveOrderModel?.data?.rideStatus, // ✅ NEW: Ride status pass karo
                onAddressFetched: (address) {
                  setState(() {
                    _currentAddress = address;
                  });
                },
              ),
            ),

            // ✅ SIMPLIFIED STREAMBUILDER - Sirf UI update ke liye
            if (liveRideViewModel.liveOrderModel?.data?.id != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('order')
                    .doc(liveRideViewModel.liveOrderModel!.data!.id.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final rideStatus = data['ride_status'] ?? 0;

                    // ✅ UI update ke liye status refresh karo
                    if (liveRideViewModel.liveOrderModel!.data!.rideStatus != rideStatus) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        liveRideViewModel.liveOrderModel!.data!.rideStatus = rideStatus;
                        setState(() {});
                      });
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),

            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.28,
              maxChildSize: 0.65,
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
                  child: _buildSheetContent(scrollController),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (Rest of the methods remain the same - _getButtonColor, _getButtonText, _showOtpDialog, _buildSectionHeader, _buildDetailRow, _getStatusText, _buildSheetContent)
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
    switch (status) {
      case 1:
        return "Start for Pickup";
      case 2:
        return "Arrived at Pickup Point";
      case 3:
        return "Start Ride";
      case 4:
        return "Reached";
      case 5:
        return "Ride Completed";
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
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  "Trip OTP Verification",
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
                    hintText: "Enter OTP",
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

                              liveRideViewModel.liveOrderModel!.data!.rideStatus = 4;

                              Navigator.of(context).pop();
                              Utils.showSuccessMessage(context, "OTP verified! Ride started.");
                              setState(() {});
                            } else {
                              Utils.showErrorMessage(context, "Invalid OTP. Try again.");
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
      case 5:
        return "Reached Destination";
      case 6:
        return "Payment Completed";
      case 7:
        return "Ride Cancelled";
      default:
        return "Unknown Status";
    }
  }

  Widget _buildSheetContent(ScrollController scrollController) {
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    final updateRideStatus = Provider.of<UpdateRideStatusViewModel>(context);

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
            ),
          ),
        ],
      );
    }

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
                          icon: Icons.confirmation_number,
                          title: "Booking ID",
                          content: liveRideViewModel.liveOrderModel!.data!.id.toString(),
                          isHeader: true,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.008),
                        _buildDetailRow(
                          icon: Icons.directions_car,
                          title: "Vehicle Type",
                          content: liveRideViewModel.liveOrderModel!.data!.vehicleName??"N/A",
                          isHeader: true,
                        ),
                      ],
                    ),
                  ),

                  // Amount and Distance as small badges
                  Column(
                    children: [
                      // Amount Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.screenWidth * 0.025,
                          vertical: Sizes.screenHeight * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_rupee, color: Colors.green, size: 14),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title: '${liveRideViewModel.liveOrderModel!.data!.amount ?? '0'}',
                              size: Sizes.fontSizeFour - 1,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Sizes.screenHeight * 0.005),
                      // Distance Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.screenWidth * 0.025,
                          vertical: Sizes.screenHeight * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.space_dashboard, color: Colors.blue, size: 14),
                            SizedBox(width: Sizes.screenWidth * 0.006),
                            TextConst(
                              title: '${liveRideViewModel.liveOrderModel!.data!.distance ?? '0'} km',
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
                      liveRideViewModel.liveOrderModel!.data!.senderPhone?.toString() ?? '9876543210',
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
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.2,
              ),
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
                  _buildSectionHeader("Sender Details"),
                  SizedBox(height: Sizes.screenHeight * 0.01),
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    title: "Name",
                    content: liveRideViewModel.liveOrderModel!.data!.senderName ?? "N/A",
                  ),
                  _buildDetailRow(
                    icon: Icons.phone,
                    title: "Phone",
                    content: liveRideViewModel.liveOrderModel!.data!.senderPhone?.toString() ?? "N/A",
                  ),
                  _buildDetailRow(
                    icon: Icons.location_on,
                    title: "Address",
                    content: liveRideViewModel.liveOrderModel!.data!.pickupAddress ?? "N/A",
                    isAddress: true,
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  Divider(height: 1),

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  _buildSectionHeader("Receiver Details"),
                  SizedBox(height: Sizes.screenHeight * 0.01),
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    title: "Name",
                    content: liveRideViewModel.liveOrderModel!.data!.reciverName ?? "N/A",
                  ),
                  _buildDetailRow(
                    icon: Icons.phone,
                    title: "Phone",
                    content: liveRideViewModel.liveOrderModel!.data!.reciverPhone?.toString() ?? "N/A",
                  ),
                  _buildDetailRow(
                    icon: Icons.location_on,
                    title: "Address",
                    content: liveRideViewModel.liveOrderModel!.data!.dropAddress ?? "N/A",
                    isAddress: true,
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.015),
                  Divider(height: 1),
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
                            title: "Current Status: ${_getStatusText(liveRideViewModel.liveOrderModel!.data!.rideStatus)}",
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
                            final liveRideViewModel = Provider.of<LiveRideViewModel>(context, listen: false);
                            final orderId = liveRideViewModel.liveOrderModel!.data!.id;
                            int currentStatus = liveRideViewModel.liveOrderModel!.data!.rideStatus ?? 1;

                            try {
                              if (currentStatus == 1) {
                                await FirebaseFirestore.instance
                                    .collection('order')
                                    .doc(orderId.toString())
                                    .update({'ride_status': 2});
                                liveRideViewModel.liveOrderModel!.data!.rideStatus = 2;
                                Utils.showSuccessMessage(context, "Ride status updated: Start for Pickup Location");
                              } else if (currentStatus == 2) {
                                await FirebaseFirestore.instance
                                    .collection('order')
                                    .doc(orderId.toString())
                                    .update({'ride_status': 3});
                                liveRideViewModel.liveOrderModel!.data!.rideStatus = 3;
                                Utils.showSuccessMessage(context, "Ride status updated: Arrived at Pickup Point");
                              } else if (currentStatus == 3) {
                                _showOtpDialog(orderId.toString());
                                return;
                              } else if (currentStatus == 4) {
                                // Use the new function to handle reached button with paymode condition
                                _handleReachedButtonClick();
                                return;
                              }
                              setState(() {});
                            } catch (e) {
                              Utils.showErrorMessage(context, "Failed to update ride status: $e");
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: Sizes.screenHeight * 0.014,
                            ),
                            decoration: BoxDecoration(
                              color: _getButtonColor(liveRideViewModel.liveOrderModel!.data!.rideStatus),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextConst(
                                title: _getButtonText(liveRideViewModel.liveOrderModel!.data!.rideStatus),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                size: Sizes.fontSizeFive,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (liveRideViewModel.liveOrderModel!.data!.rideStatus! < 4) ...[
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
