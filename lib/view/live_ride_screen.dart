import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/const_map.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/live_ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/update_ride_status_view_model.dart';
import 'package:provider/provider.dart';

class LiveRideScreen extends StatefulWidget {
  const LiveRideScreen({super.key});

  @override
  State<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends State<LiveRideScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Shrutii");
      final liveRideViewModel =
          Provider.of<LiveRideViewModel>(context, listen: false);
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
        final onlineStatusViewModel =
            Provider.of<OnlineStatusViewModel>(context);
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
                  title:
                  'Are you sure you want to go offline?',
                  size: Sizes.fontSizeFive,
                  fontWeight: FontWeight.bold,
                  color: PortColor.blue,
                ),
                SizedBox(height: Sizes.screenHeight * 0.02),
                TextConst(
                  title:
                  'You can always switch back online later.',
                  size: Sizes.fontSizeFour,
                  color: PortColor.gray,
                ),
                SizedBox(height: Sizes.screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        onlineStatusViewModel.onlineStatusApi(
                            context, 0, "userId");
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: Sizes.screenHeight * 0.05,
                          width: Sizes.screenWidth * 0.06,
                          child: const TextConst(
                            title:
                            "Yes",
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Container(
                        alignment: Alignment.center,
                        height: Sizes.screenHeight * 0.05,
                        width: Sizes.screenWidth * 0.06,
                        child: const TextConst(
                          title:
                          "No",
                          fontWeight: FontWeight.bold,
                        ))
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: Sizes.screenHeight * 0.03),
        child: Column(
          children: [
            Container(
              height: Sizes.screenHeight * 0.085,
              decoration: BoxDecoration(
                color: PortColor.white,
                border: Border(
                  top: const BorderSide(color: PortColor.white),
                  left: const BorderSide(color: PortColor.white),
                  right: const BorderSide(color: PortColor.white),
                  bottom: BorderSide(
                    color: PortColor.gray,
                    width: Sizes.screenWidth * 0.001,
                  ),
                ),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      profileViewModel.profileModel!.data!.ownerSelfie ?? "",
                      height: Sizes.screenHeight * 0.06,
                      width: Sizes.screenHeight * 0.06,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: Sizes.screenWidth * 0.02),
                  TextConst(
                    title:
                    profileViewModel.profileModel!.data!.driverName ?? "",
                    size: Sizes.fontSizeSeven,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                        _showSwitchDialog(value);
                      },
                      activeColor: PortColor.grey,
                      inactiveThumbColor: Colors.blue[50],
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
            ConstMap(
              onAddressFetched: (address) {
                setState(() {
                  _currentAddress = address;
                });
              },
            ),
          ],
        ),
      ),
      bottomSheet: booking(),
    );
  }

  Widget booking() {
    final updateRideStatusViewModel =
        Provider.of<UpdateRideStatusViewModel>(context);
    final liveRideViewModel = Provider.of<LiveRideViewModel>(context);
    //Changes yha agr loader hi walk rha to ise remove
    if (liveRideViewModel.liveOrderModel == null ||
        liveRideViewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(color: PortColor.porterPartner,), // Show loader.
      );
    }
    //yha tkk
    return Container(
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PortColor.grey),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.screenWidth * 0.044,
          vertical: Sizes.screenHeight * 0.01,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column for Booking Ids
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextConst(
                          title:
                          'Booking Id : ',
                          fontWeight: FontWeight.bold,
                          size: Sizes.fontSizeSix,
                          color: PortColor.blue,
                        ),
                        TextConst(
                          title:
                          liveRideViewModel.liveOrderModel!.data!.id
                                  .toString() ??
                              "",
                          fontWeight: FontWeight.bold,
                          size: Sizes.fontSizeFive,
                        ),
                      ],
                    ),
                    SizedBox(height: Sizes.screenHeight * 0.002),
                    Row(
                      children: [
                        TextConst(
                          title:
                          'Vehicle Type : ',
                          fontWeight: FontWeight.bold,
                          size: Sizes.fontSizeSix,
                          color: PortColor.blue,
                        ),
                        TextConst(
                          title:
                          liveRideViewModel.liveOrderModel!.data!.vehicleType ??
                              "",
                          fontWeight: FontWeight.bold,
                          size: Sizes.fontSizeFive,
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Launcher.launchDialPad(context, '9876543210'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Sizes.screenHeight * 0.005,
                      horizontal: Sizes.screenWidth * 0.035,
                    ),
                    decoration: BoxDecoration(
                      color: PortColor.partner,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call, color: Colors.white),
                        SizedBox(width: Sizes.screenWidth * 0.01),
                        TextConst(
                          title:
                          'Call',
                          color: PortColor.white,
                          size: Sizes.fontSizeSeven,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.003),
            Divider(thickness: Sizes.screenWidth * 0.002, color: Colors.grey),
            SizedBox(height: Sizes.screenHeight * 0.01),
            const TextConst(   title: "Sender Details:", fontWeight: FontWeight.bold),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Name     : ', fontWeight: FontWeight.bold),
                TextConst(
                    title:
                    liveRideViewModel.liveOrderModel!.data!.senderName ?? ""),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Phone     : ', fontWeight: FontWeight.bold),
                TextConst(   title: liveRideViewModel.liveOrderModel!.data!.senderPhone
                        .toString() ??
                    ""),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Address  : ', fontWeight: FontWeight.bold),
                SizedBox(
                  width: Sizes.screenWidth * 0.7,
                  child: TextConst(   title:
                  liveRideViewModel.liveOrderModel!.data!.pickupAddress ??
                          ""),
                ),
              ],
            ),

            Divider(thickness: Sizes.screenWidth * 0.002, color: Colors.grey),

            // Receiver Details
            SizedBox(height: Sizes.screenHeight * 0.01),
            const TextConst(   title: "Receiver Details:", fontWeight: FontWeight.bold),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Name     : ', fontWeight: FontWeight.bold),
                TextConst(   title:
                liveRideViewModel.liveOrderModel!.data!.reciverName ?? ""),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Phone     : ', fontWeight: FontWeight.bold),
                TextConst(   title: liveRideViewModel.liveOrderModel!.data!.reciverPhone
                        .toString() ??
                    ""),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.012),
            Row(
              children: [
                const TextConst(   title: 'Address  : ', fontWeight: FontWeight.bold),
                Container(
                    width: Sizes.screenWidth * 0.7,
                    child: TextConst(   title:
                    liveRideViewModel.liveOrderModel!.data!.dropAddress ??
                            "")),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.005),
            Divider(thickness: Sizes.screenWidth * 0.002, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    if (liveRideViewModel.liveOrderModel!.data!.rideStatus! <
                        5) {
                      updateRideStatusViewModel.updateRideApi(
                          context,
                          liveRideViewModel.liveOrderModel!.data!.id.toString(),
                          (int.parse(liveRideViewModel
                                      .liveOrderModel!.data!.rideStatus
                                      .toString()) +
                                  1)
                              .toString());
                    } else {}
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.012,
                        horizontal: Sizes.screenWidth * 0.053),
                    decoration: BoxDecoration(
                      color: PortColor.partner,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                        child: !updateRideStatusViewModel.loading
                      ?       TextConst(   title:
                        liveRideViewModel.liveOrderModel!.data!.rideStatus == 1
                              ? "Accepted by Driver"
                              : liveRideViewModel.liveOrderModel!.data!.rideStatus == 2
                              ? "Out for PickUp"
                              : liveRideViewModel
                              .liveOrderModel!.data!.rideStatus ==
                              3
                              ? "At Pickup Point"
                              : liveRideViewModel
                              .liveOrderModel!.data!.rideStatus ==
                              4
                              ? "Ride Started"
                              : "unknown Status",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          size: Sizes.fontSizeFive,
                        )
                            // ? TextConst(
                            //     'Start Ride',
                            //     color: Colors.white,
                            //     fontWeight: FontWeight.w600,
                            //     size: Sizes.fontSizeSix,
                            //   )
                            : const CircularProgressIndicator(
                                color: PortColor.white,
                              )),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.01,
                        horizontal: Sizes.screenWidth * 0.04),
                    decoration: BoxDecoration(
                      border: Border.all(color: PortColor.partner, width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.track_changes,
                            color: PortColor.partner, size: 20),
                        SizedBox(
                          width: Sizes.screenWidth * 0.015,
                        ),
                        TextConst(
                          title:
                          'Track',
                          color: PortColor.partner,
                          size: Sizes.fontSizeFive,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Sizes.screenHeight * 0.01,
                        horizontal: Sizes.screenWidth * 0.06),
                    decoration: BoxDecoration(
                      border: Border.all(color: PortColor.red, width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextConst(
                      title:
                      'Cancel',
                      color: PortColor.red,
                      size: Sizes.fontSizeFive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.017),
            Row(
              children: [
                const TextConst(   title: 'Status :', fontWeight: FontWeight.bold),
                SizedBox(
                  width: Sizes.screenWidth * 0.002,
                ),
                TextConst(
                  title:
                  liveRideViewModel.liveOrderModel!.data!.rideStatus == 1
                      ? "Accepted by Driver"
                      : liveRideViewModel.liveOrderModel!.data!.rideStatus == 2
                          ? "Out for PickUp"
                          : liveRideViewModel
                                      .liveOrderModel!.data!.rideStatus ==
                                  3
                              ? "At Pickup Point"
                              : liveRideViewModel
                                          .liveOrderModel!.data!.rideStatus ==
                                      4
                                  ? "Ride Started"
                                  : "unknown Status",
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
