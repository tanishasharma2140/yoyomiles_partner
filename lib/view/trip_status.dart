import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/const_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/assign_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';

class TripStatus extends StatefulWidget {
  const TripStatus({super.key});

  @override
  State<TripStatus> createState() => _TripStatusState();
}

class _TripStatusState extends State<TripStatus> {
  bool isSwitched = true;
  String? _currentAddress;
  final ScrollController _scrollController = ScrollController();

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
                  color: PortColor.gold, // Changed to gold
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
                        width: Sizes.screenWidth * 0.06,
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

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      body: Column(
        children: [
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

          // Map Section - Fixed Half Screen
          Container(
            height: Sizes.screenHeight * 0.45,
            child: ConstMap(
              onAddressFetched: (address) {
                setState(() {
                  _currentAddress = address;
                });
              },
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
                  Icon(
                    Icons.location_on,
                    color: PortColor.gold,
                    size: 16,
                  ), // Changed to gold
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

          // Bookings Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.screenWidth * 0.04,
              vertical: Sizes.screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: PortColor.white,
              border: Border(
                bottom: BorderSide(color: PortColor.greyLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: PortColor.gold,
                  size: 20,
                ), // Changed to gold
                SizedBox(width: Sizes.screenWidth * 0.02),
                TextConst(
                  title: "Available Bookings",
                  size: Sizes.fontSizeSix,
                  fontWeight: FontWeight.bold,
                  color: PortColor.black, // Changed to gold
                ),
                const Spacer(),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fetchBookings(""),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.length : 0;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Sizes.screenWidth * 0.03,
                        vertical: Sizes.screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.gold, // Changed to gold
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextConst(
                        title: "$count",
                        color: PortColor.black,
                        size: Sizes.fontSizeFour,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bookings List - Scrollable Section
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchBookings(""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: PortColor.gold,
                    ), // Changed to gold
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: PortColor.red,
                          size: 50,
                        ),
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
                        Image.asset(
                          Assets.assetsNoData,
                          height: Sizes.screenHeight * 0.15,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.02),
                        TextConst(
                          title: "No Bookings Available",
                          color: PortColor.gold, // Changed to gold
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
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.screenHeight * 0.01,
                  ),
                  itemCount: bookingList.length,
                  itemBuilder: (context, index) {
                    return BookingCard(bookingData: bookingList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Stream for matching bookings
  Stream<List<Map<String, dynamic>>> fetchBookings(String driverVehicleType) {
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
            return idStrings.contains(driverIdStr);
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
            };
          })
          .toList();

      print('📦 Matched bookings: ${filtered.length}');
      return filtered;
    });
  }
}

/// ✅ Separate Widget for Booking Card for better performance
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingCard({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    final assignRideViewModel = Provider.of<AssignRideViewModel>(context);
    final updateRideStatus = Provider.of<UpdateRideStatusViewModel>(context);
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
                    color: PortColor.gold.withOpacity(0.1), // Changed to gold
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        color: PortColor.gold,
                        size: 16,
                      ), // Changed to gold
                      SizedBox(width: Sizes.screenWidth * 0.01),
                      TextConst(
                        title: 'Booking ID',
                        size: Sizes.fontSizeFour,
                        fontWeight: FontWeight.bold,
                        color: PortColor.gold, // Changed to gold
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // FIX: Convert ID to string before passing
                      String bookingId = bookingData['id'].toString();
                      assignRideViewModel.assignRideApi(context, 1, bookingId);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: PortColor.gold, // Changed to gold
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
                SizedBox(width: Sizes.screenWidth * 0.03),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      updateRideStatus.updateRideApi(context, bookingData['id'].toString(), "8");
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
                            Icon(Icons.cancel, color: PortColor.red, size: 18),
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
          Icon(icon, color: PortColor.gold, size: 16), // Changed to gold
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
