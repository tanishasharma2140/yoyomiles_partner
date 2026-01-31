import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/circular_wave_animation.dart';
import 'package:yoyomiles_partner/res/const_without_polyline_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_appbar.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/assign_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/delete_old_order_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_ignored_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/ringtone_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';


class TripStatus extends StatefulWidget {
  const TripStatus({super.key});

  @override
  State<TripStatus> createState() => _TripStatusState();
}

class _TripStatusState extends State<TripStatus> {
  bool isSwitched = true;
  String? _currentAddress;
  double currentLat = 0.0;
  double currentLng = 0.0;
  Map<String, Timer> bookingTimers = {};
  Timer? _deleteTimer;

  late RingtoneViewModel ringtoneVM;
  Set<String> _seenBookingIds = {};
  StreamSubscription? _bookingSubscription;

  int userIds = 0;

  // 🔥 Track if ride is being accepted to prevent navigation issues
  bool _isAcceptingRide = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ringtoneVM = Provider.of<RingtoneViewModel>(context, listen: false);
      final deleteOldOrderVm = Provider.of<DeleteOldOrderViewModel>(context, listen: false);

      // 1st Immediate hit
      deleteOldOrderVm.deleteOldOrderApi();

      // periodic every 2 min
      _deleteTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        deleteOldOrderVm.deleteOldOrderApi();
      });
    });
    final ride = Provider.of<RideViewModel>(context, listen: false);
    ride.handleRideUpdate("", context);

  }

  @override
  void dispose() {
    try {
      _bookingSubscription?.cancel();
      bookingTimers.forEach((key, timer) => timer.cancel());
      // Stop ringtone on dispose
      ringtoneVM.stopRingtone();
      _deleteTimer?.cancel();
    } catch (_) {}
    super.dispose();
  }

  void getCurrentLocation() async {
    try {
      final userId = await UserViewModel().getUser();
      setState(() {
        userIds = userId!;
      });
      Position pos = await Geolocator.getCurrentPosition();
      currentLat = pos.latitude;
      currentLng = pos.longitude;

      List<Placemark> placemark = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      _currentAddress =
          "${placemark.first.street}, ${placemark.first.locality}";
      if (mounted) setState(() {});
      Provider.of<ConstMapController>(context,listen: false).toggleLightMode(true);
    } catch (e) {
      print("⚠️ getCurrentLocation error: $e");
    }
  }

  void _showSwitchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final onlineStatusViewModel = Provider.of<OnlineStatusViewModel>(
          context,
          listen: false,
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
                      onTap: () async {
                        await onlineStatusViewModel.onlineStatusApi(context, 0);
                        if (mounted) {
                          setState(() {
                            isSwitched = false;
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: Sizes.screenHeight * 0.05,
                        width: Sizes.screenWidth * 0.2,
                        decoration: BoxDecoration(
                          color: PortColor.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const TextConst(
                          title: "Yes",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: Sizes.screenHeight * 0.05,
                        width: Sizes.screenWidth * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const TextConst(
                          title: "No",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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


  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final mapCtrl = Provider.of<ConstMapController>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Provider.of<RingtoneViewModel>(context, listen: false).stopRingtone();
              Navigator.pop(context);
            },
          ),
          name: profileViewModel.profileModel!.data!.driverName ?? "Known",
          imageUrl: profileViewModel.profileModel!.data!.ownerSelfie ?? "",
          actions: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isSwitched,
                onChanged: (value) {
                  if (value == false) {
                    _showSwitchDialog();
                  } else {
                    final onlineStatusViewModel =
                        Provider.of<OnlineStatusViewModel>(
                          context,
                          listen: false,
                        );
                    onlineStatusViewModel.onlineStatusApi(context, 1);
                    setState(() {
                      isSwitched = true;
                    });
                  }
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.blue[50],
                activeTrackColor: PortColor.gold,
                inactiveTrackColor: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Consumer<RideViewModel>(
          builder: (context, rideVM, child) {
            print("hgfhg ${rideVM.allRideData}");
            final bookingList = rideVM.allRideData ?? [];
            final ringtone = Provider.of<RingtoneViewModel>(context, listen: false);

            if (bookingList.isNotEmpty && !ringtone.isRinging) {
              ringtone.playRingtone();
            }

            if (bookingList.isEmpty && ringtone.isRinging) {
              ringtone.stopRingtone();
            }

            return Stack(
              children: [
                Positioned.fill(
                  top: 0,
                  child: ConstWithoutPolylineMap(
                    // isLightMode: false,

                    backIconAllowed: false,
                    onAddressFetched: (address) {
                      if (_currentAddress != address && mounted) {
                        setState(() {
                          _currentAddress = address;
                        });
                      }
                    }, controller: mapCtrl,
                  ),
                ),
                if (bookingList.isEmpty) ...[
                  Align(
                    alignment: const Alignment(0, -0.3),
                    child: CircularWaveAnimation(
                      size: 180,
                      color: PortColor.gold.withOpacity(0.2),
                      waveCount: 3,
                      duration: const Duration(seconds: 2),
                      child: Transform.translate(
                        offset: const Offset(0, -12),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Image.asset(
                            "assets/yellow_pin.png",
                            fit: BoxFit.contain,
                            color: PortColor.blackLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 14,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 6,
                              child: LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  PortColor.gold,
                                ),
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextConst(
                            title: "Waiting for a new ride request…",
                            size: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                          const SizedBox(height: 6),
                          TextConst(
                            title:
                                "Stay online and you'll receive a booking as soon as a customer requests a ride.",
                            textAlign: TextAlign.center,
                            size: 14,
                            fontFamily: AppFonts.poppinsReg,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ] else
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.6,
                    maxChildSize: 0.6,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: PortColor.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping,
                                    color: PortColor.gold,
                                  ),
                                  const SizedBox(width: 8),
                                  TextConst(
                                    title: "Available Bookings",
                                    size: Sizes.fontSizeSix,
                                    fontWeight: FontWeight.bold,
                                    color: PortColor.black,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PortColor.gold,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextConst(
                                      title: "${bookingList.length}",
                                      color: PortColor.white,
                                      size: Sizes.fontSizeFour,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Colors.grey),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: bookingList.length,
                                itemBuilder: (context, index) {
                                  return BookingCard(
                                    bookingData: bookingList[index],
                                    onAccept: (bookingId) {
                                      _handleAcceptRide(
                                        bookingId,
                                        bookingList[index],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                if (_currentAddress != null)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: PortColor.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextConst(
                              title: _currentAddress!,
                              color: PortColor.black,
                              size: Sizes.fontSizeFour,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔥 Centralized accept handler
  void _handleAcceptRide(
    String bookingId,
    Map<String, dynamic> bookingData,
  ) async {
    if (_isAcceptingRide) {
      print("⚠️ Already accepting a ride");
      return;
    }

    print("🚗 ACCEPT pressed for bookingId: $bookingId");

    // Stop ringtone immediately
    Provider.of<RingtoneViewModel>(context, listen: false).stopRingtone();

    // Set accepting flag
    setState(() {
      _isAcceptingRide = true;
    });

    try {
      final assignRideViewModel = Provider.of<AssignRideViewModel>(
        context,
        listen: false,
      );

      await assignRideViewModel.assignRideApi(
        context,
        1,
        bookingId,
        bookingData,
      );
    } catch (e) {
      print("❌ Accept ride error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAcceptingRide = false;
        });
      }
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: PortColor.gold),
          SizedBox(height: Sizes.screenHeight * 0.02),
          TextConst(
            title: 'Accepting ride...',
            size: Sizes.fontSizeFive,
            color: PortColor.black,
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final Function(String) onAccept;

  const BookingCard({
    super.key,
    required this.bookingData,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final assignRideViewModel = Provider.of<AssignRideViewModel>(context);
    final ignoredRideVm = Provider.of<DriverIgnoredRideViewModel>(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Sizes.screenWidth * 0.03,
        vertical: Sizes.screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortColor.greyLight),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(Sizes.screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.screenWidth * 0.03,
                    vertical: Sizes.screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: PortColor.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        color: PortColor.gold,
                        size: 16,
                      ),
                      SizedBox(width: Sizes.screenWidth * 0.01),
                      TextConst(
                        title: 'Booking ID',
                        size: Sizes.fontSizeFour,
                        fontWeight: FontWeight.bold,
                        color: PortColor.gold,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Sizes.screenWidth * 0.02),
                Expanded(
                  child: TextConst(
                    title: bookingData['id'].toString(),
                    size: Sizes.fontSizeFour,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Sizes.screenHeight * 0.006,
                      horizontal: Sizes.screenWidth * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.call, color: PortColor.blackLight, size: 16),
                        SizedBox(width: Sizes.screenWidth * 0.01),
                        TextConst(
                          title: 'Call',
                          color: PortColor.blackLight,
                          size: Sizes.fontSizeFour,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Sizes.screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    // Stop ringtone on ignore
                    Provider.of<RingtoneViewModel>(context, listen: false).stopRingtone();

                    ignoredRideVm.driverIgnoredRideApi(
                      context: context,
                      orderId: bookingData['id'].toString(),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Sizes.screenHeight * 0.006,
                      horizontal: Sizes.screenWidth * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 16),
                        SizedBox(width: Sizes.screenWidth * 0.01),
                        TextConst(
                          title: 'Ignore',
                          color: Colors.red,
                          size: Sizes.fontSizeFour,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.01),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.screenWidth * 0.04,
                    vertical: Sizes.screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.currency_rupee, color: Colors.green, size: 18),
                      SizedBox(width: Sizes.screenWidth * 0.01),
                      TextConst(
                        title: '${bookingData['amount'] ?? '0'}',
                        size: Sizes.fontSizeFour,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Sizes.screenWidth * 0.03),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.screenWidth * 0.04,
                    vertical: Sizes.screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.social_distance, color: Colors.blue, size: 18),
                      SizedBox(width: Sizes.screenWidth * 0.01),
                      TextConst(
                        title: '${bookingData['distance'] ?? '0'} km',
                        size: Sizes.fontSizeFour,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.015),
            const Divider(height: 1),
            SizedBox(height: Sizes.screenHeight * 0.01),
            if (bookingData['order_type'] != 2) ...[
              _buildDetailRow(
                icon: Icons.person_outline,
                title: "Sender",
                content: bookingData['sender_name'] ?? "N/A",
              ),
              _buildDetailRow(
                icon: Icons.phone,
                title: "Phone",
                content: bookingData['sender_phone'] ?? "N/A",
              ),
            ],
            _buildDetailRow(
              icon: Icons.location_on,
              title: "Pickup",
              content: bookingData['pickup_address'] ?? "N/A",
              isAddress: true,
            ),
            SizedBox(height: Sizes.screenHeight * 0.01),
            const Divider(height: 1),
            SizedBox(height: Sizes.screenHeight * 0.01),
            if (bookingData['order_type'] != 2) ...[
              _buildDetailRow(
                icon: Icons.person_outline,
                title: "Receiver",
                content: bookingData['reciver_name'] ?? "N/A",
              ),
              _buildDetailRow(
                icon: Icons.phone,
                title: "Phone",
                content: bookingData['reciver_phone'] ?? "N/A",
              ),
            ],
            _buildDetailRow(
              icon: Icons.location_on,
              title: "Drop",
              content: bookingData['drop_address'] ?? "N/A",
              isAddress: true,
            ),

            SizedBox(height: Sizes.screenHeight * 0.015),
            const Divider(height: 1),
            SizedBox(height: Sizes.screenHeight * 0.015),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      String bookingId = bookingData['id'].toString();
                      onAccept(bookingId);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: !assignRideViewModel.loading
                            ? TextConst(
                                title: 'Accept',
                                color: PortColor.white,
                                fontWeight: FontWeight.w500,
                              )
                            : SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
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
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    bool isAddress = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.screenHeight * 0.008),
      child: Row(
        crossAxisAlignment: isAddress
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: PortColor.gold, size: 16),
          SizedBox(width: Sizes.screenWidth * 0.02),
          SizedBox(
            width: Sizes.screenWidth * 0.15,
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
}
