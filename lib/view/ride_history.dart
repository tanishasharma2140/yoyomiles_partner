import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:provider/provider.dart';

// ─── Stop Model ───────────────────────────────────────────────────────────────

class StopModel {
  final String name;
  final String phone;
  final double lat;
  final double lng;
  final String address;
  final int status; // 1 = reached, 0 = pending

  StopModel({
    required this.name,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.address,
    required this.status,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

List<StopModel> parseStops(dynamic stopsRaw) {
  if (stopsRaw == null) return [];
  try {
    final String stopsStr = stopsRaw.toString().trim();
    if (stopsStr.isEmpty || stopsStr == 'null') return [];
    final List<dynamic> jsonList = jsonDecode(stopsStr);
    return jsonList
        .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

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
      profileViewModel.profileApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);
    final loc = AppLocalizations.of(context)!;
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
                    Container(
                      decoration: BoxDecoration(
                        color: PortColor.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: PortColor.gold,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title: loc.ride_history,
                          size: Sizes.fontSizeEight,
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
                  ? Center(
                child: CupertinoActivityIndicator(
                  color: PortColor.blue,
                  radius: 14,
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
    final loc = AppLocalizations.of(context)!;
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
            title: loc.no_rides_yet,
            size: Sizes.fontSizeSeven,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          TextConst(
            title: loc.ride_history_placeholder,
            size: Sizes.fontSizeSeven - 2,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget dataContainer() {
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);
    final loc = AppLocalizations.of(context)!;
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
                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Sender Details Card
                  if (ride.orderType != 2)
                    _buildDetailCard(
                      loc.sender_details,
                      Icons.person_outline,
                      [
                        _buildDetailRow(loc.name, ride.senderName ?? ""),
                        _buildDetailRow(
                            loc.phone, ride.senderPhone?.toString() ?? ""),
                      ],
                    ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Route Details (with stops)
                  _buildRouteCard(ride),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Receiver Details Card
                  if (ride.orderType != 2)
                    _buildDetailCard(
                      loc.receiver_details,
                      Icons.person,
                      [
                        _buildDetailRow(loc.name, ride.reciverName ?? ""),
                        _buildDetailRow(
                            loc.phone, ride.reciverPhone?.toString() ?? ""),
                      ],
                    ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextConst(title: loc.status),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
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
                              ? loc.ride_completed
                              : ride.rideStatus == 7
                              ? loc.cancelled_by_user
                              : ride.rideStatus == 8
                              ? loc.cancelled_by_driver
                              : "None",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ride.rideStatus == 6
                                ? Colors.green
                                : Colors.red,
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: PortColor.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.space_dashboard,
                                color: PortColor.gold, size: 16),
                            SizedBox(width: 6),
                            TextConst(
                              title:
                              "${ride.distance?.toString() ?? "0"} km",
                              size: Sizes.fontSizeSeven,
                              fontWeight: FontWeight.w600,
                              color: PortColor.gold,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Launcher.launchDialPad(
                            context, ride.senderPhone?.toString() ?? ''),
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
                          child: Icon(Icons.call,
                              color: PortColor.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Rating
                  if (ride.userRating != null && ride.userRating! > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextConst(
                          title: loc.ride_rating,
                          size: Sizes.fontSizeSeven,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        Row(
                          children: List.generate(
                            ride.userRating!,
                                (index) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
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

  Widget _buildDetailCard(
      String title, IconData icon, List<Widget> children) {
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
          SizedBox(
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

  // ── Route card: pickup → stops → dropoff ──────────────────────────────────
  Widget _buildRouteCard(dynamic ride) {
    final loc = AppLocalizations.of(context)!;
    final List<StopModel> stops = parseStops(ride.stops);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // ── Pickup ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _timelineDot(color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: loc.pickup,
                      size: Sizes.fontSizeSeven - 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(height: 4),
                    TextConst(
                      title: ride.pickupAddress ?? loc.location_not_specified,
                      size: Sizes.fontSizeSeven - 2,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Stops (if any) ──
          if (stops.isNotEmpty) ...[
            for (final stop in stops) ...[
              // Dashed connector line
              _dashedConnector(),

              // Stop row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange dot with check/pending icon
                  _stopDot(reached: stop.status == 1),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + phone + badge in one row
                        Row(
                          children: [
                            Flexible(
                              child: TextConst(
                                title: stop.name,
                                size: Sizes.fontSizeSeven - 1,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6),
                            TextConst(
                              title: stop.phone,
                              size: Sizes.fontSizeSeven - 2,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 6),
                            // Reached / Pending badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stop.status == 1
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: stop.status == 1
                                      ? Colors.green
                                      : Colors.orange,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                stop.status == 1 ? "Reached" : "Pending",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: stop.status == 1
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        TextConst(
                          title: stop.address.isEmpty
                              ? loc.location_not_specified
                              : stop.address,
                          size: Sizes.fontSizeSeven - 2,
                          color: Colors.black87,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Dashed connector before dropoff
          _dashedConnector(),

          // ── Dropoff ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _timelineDot(color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextConst(
                      title: loc.dropoff,
                      size: Sizes.fontSizeSeven - 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                    SizedBox(height: 4),
                    TextConst(
                      title: ride.dropAddress ?? loc.location_not_specified,
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

  // ── Timeline helpers ───────────────────────────────────────────────────────

  /// Solid filled circle for pickup / dropoff
  Widget _timelineDot({required Color color}) {
    return Container(
      width: 18,
      height: 18,
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  /// Small dot with icon for a stop — solid if reached, faded if pending
  Widget _stopDot({required bool reached}) {
    return Container(
      width: 18,
      height: 18,
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? Colors.orange : Colors.orange.shade200,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        reached ? Icons.check : Icons.more_horiz,
        color: Colors.white,
        size: 10,
      ),
    );
  }

  /// Dashed vertical line between two stops
  Widget _dashedConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: List.generate(
          5,
              (_) => Container(
            width: 2,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.4),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}