import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:provider/provider.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideHistoryViewModel =
      Provider.of<RideHistoryViewModel>(context, listen: false);
      rideHistoryViewModel.rideHistoryApi();
      final profileViewModel =
      Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.profileApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        body: Column(
          children: [
            // Header
            Container(
              height: Sizes.screenHeight * 0.12,
              decoration: BoxDecoration(
                color: PortColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: PortColor.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: PortColor.gold,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // Title
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title: "Ride History",
                          size: Sizes.fontSizeEight + 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 50,
                          decoration: BoxDecoration(
                            color: PortColor.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: rideHistoryViewModel.loading
                  ?  Center(
                child: CupertinoActivityIndicator(
                  color: PortColor.blue,
                  radius: 14, // optional – size control
                ),
              )
                  : rideHistoryViewModel.rideHistoryModel == null ||
                  rideHistoryViewModel.rideHistoryModel!.data == null ||
                  rideHistoryViewModel.rideHistoryModel!.data!.isEmpty
                  ? pendingContainer()
                  : dataContainer(),
            ),

          ],
        ),
      ),
    );
  }

  Widget pendingContainer() {
    return Container(
      height: Sizes.screenHeight * 0.76,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/no_data.gif",
              height: Sizes.screenHeight * 0.4,
              width: Sizes.screenWidth * 0.6,
            ),
          ),
          SizedBox(height: 20),
          TextConst(
            title: "No rides yet",
            size: Sizes.fontSizeSeven,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          TextConst(
            title: "Your ride history will appear here",
            size: Sizes.fontSizeSeven - 2,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget dataContainer() {
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);
    final profile = Provider.of<ProfileViewModel>(context);
    return ListView.builder(
      itemCount: rideHistoryViewModel.rideHistoryModel!.data!.length,
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.screenWidth * 0.04,
        vertical: Sizes.screenHeight * 0.02,
      ),
      itemBuilder: (context, index) {
        final ride = rideHistoryViewModel.rideHistoryModel!.data![index];
        return Padding(
          padding: EdgeInsets.only(bottom: Sizes.screenHeight * 0.02),
          child: Container(
            decoration: BoxDecoration(
              color: PortColor.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextConst(
                        title: "Booking ID",
                        size: Sizes.fontSizeSeven - 2,
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Sender Details Card
                  _buildDetailCard(
                    "Sender Details",
                    Icons.person_outline,
                    [
                      _buildDetailRow("Name", ride.senderName ?? ""),
                      _buildDetailRow("Phone", ride.senderPhone?.toString() ?? ""),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Route Details
                  _buildRouteCard(ride),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Receiver Details Card
                  _buildDetailCard(
                    "Receiver Details",
                    Icons.person,
                    [
                      _buildDetailRow("Name", ride.reciverName ?? ""),
                      _buildDetailRow("Phone", ride.reciverPhone?.toString() ?? ""),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextConst(
                        title: "Status",
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ride.rideStatus == 6
                              ? Colors.green.withOpacity(0.1)
                              : ride.rideStatus == 7
                              ? Colors.red.withOpacity(0.1)
                              : ride.rideStatus == 8
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ride.rideStatus == 6
                              ? "Ride Completed"
                              : ride.rideStatus == 7
                              ? "Cancelled by User"
                              : ride.rideStatus == 8
                          ?"Cancelled by Driver"
                              :"None"
                          ,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ride.rideStatus == 6
                                ? Colors.red
                                : ride.rideStatus == 7
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.01),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: PortColor.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.space_dashboard, color: PortColor.gold, size: 16),
                            SizedBox(width: 6),
                            TextConst(
                              title: "${ride.distance?.toString() ?? "0"} km",
                              size: Sizes.fontSizeSeven,
                              fontWeight: FontWeight.w600,
                              color: PortColor.gold,
                            ),
                          ],
                        ),
                      ),

                      // Call Button
                      GestureDetector(
                        onTap: () => Launcher.launchDialPad(context, ride.senderPhone?.toString() ?? ''),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: PortColor.gold,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: PortColor.gold.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.call, color: PortColor.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextConst(
                        title: "Ride Rating",
                        size: Sizes.fontSizeSeven,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      Row(
                        children: List.generate(profile.profileModel!.data!.ratingCount!, (index)
                        => Icon(Icons.star_rounded, color: Colors.amber, size: 18),
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

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortColor.scaffoldBgGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: PortColor.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: PortColor.gold, size: 16),
              ),
              SizedBox(width: 10),
              TextConst(
                title: title,
                size: Sizes.fontSizeSeven,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 80,
            child: TextConst(
              title: "$label:",
              size: Sizes.fontSizeSeven - 2,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: TextConst(
              title: value.isEmpty ? "Not Available" : value,
              size: Sizes.fontSizeSeven - 2,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(dynamic ride) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: "Pickup",
                      size: Sizes.fontSizeSeven - 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(height: 4),
                    TextConst(
                      title: ride.pickupAddress ?? "Location not specified",
                      size: Sizes.fontSizeSeven - 2,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Connecting Line
          Container(
            margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            width: 2,
            height: 20,
            color: Colors.orange.withOpacity(0.3),
          ),

          // Dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: "Dropoff",
                      size: Sizes.fontSizeSeven - 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(height: 4),
                    TextConst(
                      title: ride.dropAddress ?? "Location not specified",
                      size: Sizes.fontSizeSeven - 2,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}