import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/const_without_polyline_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_appbar.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/assign_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

class TripStatus extends StatefulWidget {
  const TripStatus({super.key});

  @override
  State<TripStatus> createState() => _TripStatusState();
}

class _TripStatusState extends State<TripStatus> {
  bool isSwitched = true;
  String? _currentAddress;

  // bool isSwitched = true;

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
                        // ✅ Close dialog
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

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar:  CustomAppBar(
          name: profileViewModel.profileModel!.data!.driverName?? "Known",
          imageUrl: profileViewModel.profileModel!.data!.ownerSelfie ?? "",
          actions: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isSwitched,
                onChanged: (value) {
                  if (value == false) {
                    // 👇 Don't turn off immediately — just show dialog
                    _showSwitchDialog();
                  } else {
                    // ✅ Turn ON instantly + call API
                    final onlineStatusViewModel =
                    Provider.of<OnlineStatusViewModel>(context, listen: false);
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
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fetchBookings("",context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: PortColor.gold),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: PortColor.red, size: 50),
                    SizedBox(height: Sizes.screenHeight * 0.02),
                    TextConst(
                      title: 'Error loading bookings',
                      color: PortColor.red,
                      size: Sizes.fontSizeFive,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Assets.assetsNoData,
                        height: Sizes.screenHeight * 0.15),
                    SizedBox(height: Sizes.screenHeight * 0.02),
                    TextConst(
                      title: "No Bookings Available",
                      color: PortColor.gold,
                      fontWeight: FontWeight.bold,
                      size: Sizes.fontSizeSix,
                    ),
                    SizedBox(height: Sizes.screenHeight * 0.01),
                    TextConst(
                      title: "New bookings will appear here",
                      color: PortColor.gray,
                      size: Sizes.fontSizeFour,
                    ),
                  ],
                ),
              );
            }

            final bookingList = snapshot.data!;

            return Stack(
              children: [
                ///  FIXED MAP SECTION
                Positioned.fill(
                  top: 0,
                  bottom: MediaQuery.of(context).size.height * 0.25,
                  child: SizedBox(
                    height: Sizes.screenHeight * 0.4,
                    child: ConstWithoutPolylineMap(
                      backIconAllowed: false,
                      onAddressFetched: (address) {
                        if (_currentAddress != address) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _currentAddress = address;
                            });
                          });
                        }
                      },
                    ),
                  ),
                ),

                ///  DRAGGABLE SCROLLABLE BOOKING LIST
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
                          // Drag Handle
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

                          // Header Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.local_shipping, color: PortColor.gold),
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
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: PortColor.gold,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextConst(
                                    title: "${bookingList.length}",
                                    color: PortColor.black,
                                    size: Sizes.fontSizeFour,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, color: Colors.grey),

                          // Booking List
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: bookingList.length,
                              itemBuilder: (context, index) {
                                return BookingCard(
                                  bookingData: bookingList[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                ///  TOP CURRENT ADDRESS BANNER
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
                          Icon(Icons.location_on, color: PortColor.gold, size: 18),
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
}

/// ✅ CORRECTED Stream for matching bookings with ride_status filter
Stream<List<Map<String, dynamic>>> fetchBookings(String driverVehicleType, context) {
  final profileViewModel = Provider.of<ProfileViewModel>(
    context,
    listen: false,
  );
  final driverId = profileViewModel.profileModel!.data!.id;
  final driverIdStr = driverId.toString();

  final bookings = FirebaseFirestore.instance.collection('order');

  return bookings.snapshots().map((snapshot) {
    final filtered = snapshot.docs
        .where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // ✅ CHECK 1: Ride status should be 1, 2, 3, or 4 ONLY
      final rideStatus = data['ride_status'] ?? 0;
      final isActiveStatus = rideStatus == 0 || rideStatus == 1 || rideStatus == 2 || rideStatus == 3;

      if (!isActiveStatus) {
        return false; // Skip if ride status is NOT 1,2,3,4
      }

      // ✅ CHECK 2: Driver should be in available_driver_id list
      final raw = data['available_driver_id'];
      List<dynamic> ids = [];

      if (raw is List) {
        ids = raw;
      } else if (raw is String && raw.isNotEmpty) {
        ids = [raw];
      } else if (raw is int) {
        ids = [raw];
      }

      final idStrings = ids.map((e) => e.toString()).toList();
      final isDriverAvailable = idStrings.contains(driverIdStr);

      return isDriverAvailable;
    })
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Convert all fields to proper types
      return {
        'id': data['id']?.toString() ?? '', // Convert to string
        'sender_name': data['sender_name']?.toString() ?? 'N/A',
        'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
        'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
        'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
        'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
        'drop_address': data['drop_address']?.toString() ?? 'N/A',
        'available_driver_id': data['available_driver_id'],
        'document_id': doc.id, // Add document ID for reference
        'amount': data['amount'] ?? 0,
        'distance': data['distance'] ?? 0,
      };
    })
        .toList();

    print('📦 Available bookings (ONLY status 1,2,3,4): ${filtered.length}');

    // Debug: Print status of filtered bookings
    for (var booking in filtered) {
      print('🎯 Booking ID: ${booking['id']}');
    }

    return filtered;
  });
}

/// ✅ Separate Widget for Booking Card for better performance
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingCard({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final assignRideViewModel = Provider.of<AssignRideViewModel>(context);

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
            // Booking header
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
                  onTap: () => Launcher.launchDialPad(
                    context,
                    bookingData['sender_phone'].toString(),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Sizes.screenHeight * 0.006,
                      horizontal: Sizes.screenWidth * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.call, color: Colors.white, size: 16),
                        SizedBox(width: Sizes.screenWidth * 0.01),
                        TextConst(
                          title: 'Call',
                          color: Colors.white,
                          size: Sizes.fontSizeFour,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Amount and Distance below header - ALTERNATIVE DESIGN
            SizedBox(height: Sizes.screenHeight * 0.01),
            Row(
              children: [
                // Amount with rupee icon
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
                // Distance with car icon
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
                      Icon(Icons.directions_car, color: Colors.blue, size: 18),
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

            // Sender Details
            SizedBox(height: Sizes.screenHeight * 0.01),
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
            _buildDetailRow(
              icon: Icons.location_on,
              title: "Pickup",
              content: bookingData['pickup_address'] ?? "N/A",
              isAddress: true,
            ),

            SizedBox(height: Sizes.screenHeight * 0.01),
            const Divider(height: 1),

            // Receiver Details
            SizedBox(height: Sizes.screenHeight * 0.01),
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
            _buildDetailRow(
              icon: Icons.location_on,
              title: "Drop",
              content: bookingData['drop_address'] ?? "N/A",
              isAddress: true,
            ),

            SizedBox(height: Sizes.screenHeight * 0.015),
            const Divider(height: 1),
            SizedBox(height: Sizes.screenHeight * 0.015),

            // Action Buttons
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // FIX: Convert ID to string before passing
                      String bookingId = bookingData['id'].toString();
                      assignRideViewModel.assignRideApi(context, 1, bookingId,bookingData);
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
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextConst(
                              title: 'Accept',
                              color: PortColor.blackLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
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