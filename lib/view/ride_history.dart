import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/launcher.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/ride_history_view_model.dart';
import 'package:provider/provider.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideHistoryViewModel =
          Provider.of<RideHistoryViewModel>(context, listen: false);
      rideHistoryViewModel.rideHistoryApi();
      print("helokokfio");
    });
  }
  @override
  Widget build(BuildContext context) {
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);
    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      body: Column(
        children: [
          SizedBox(height: Sizes.screenHeight*0.025,),
          Container(
            height: Sizes.screenHeight * 0.08,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PortColor.partner,
                  PortColor.porterPartner,
                  PortColor.purple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: PortColor.white,
                  ),
                ),
                TextConst(
                  title:
                  "Ride History",
                  size: Sizes.fontSizeEight,
                  fontWeight: FontWeight.bold,
                  color: PortColor.white,
                ),
              ],
            ),
          ),
          // remove expand container
          rideHistoryViewModel.rideHistoryModel!= null
              ? dataContainer()
              : pendingContainer()],
      ),
    );
  }
  Widget pendingContainer(){
    return Container(
      height: Sizes.screenHeight*0.76,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/no_data.gif",height: Sizes.screenHeight*0.6,width: Sizes.screenWidth*0.8,)),
        ],
      ),
    );

  }
  Widget dataContainer(){
    final rideHistoryViewModel = Provider.of<RideHistoryViewModel>(context);

    return  Expanded(
      child:
      // rideHistoryViewModel.loading
      //     ? const Center(
      //         child: CircularProgressIndicator(
      //         color: PortColor.porterPartner,
      //       ))
      //     : rideHistoryViewModel.rideHistoryModel?.data?.isNotEmpty ==
      //             true
      //         ?
      ListView.builder(
        itemCount: rideHistoryViewModel
            .rideHistoryModel!.data!.length,
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.screenWidth * 0.02,
          vertical: Sizes.screenHeight * 0.02,
        ),
        itemBuilder: (context, index) {
          final ride = rideHistoryViewModel
              .rideHistoryModel!.data![index];
          return Padding(
            padding: EdgeInsets.only(
                bottom: Sizes.screenHeight * 0.02),
            child: Container(
              decoration: BoxDecoration(
                color: PortColor.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PortColor.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        TextConst(
                          title:
                          'Booking Id: ${ride.id.toString()}',
                          fontWeight: FontWeight.bold,
                          size: Sizes.fontSizeSix,
                        ),
                        GestureDetector(
                          onTap: () => Launcher.launchDialPad(context, '8709890987'),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                              Sizes.screenHeight * 0.005,
                              horizontal:
                              Sizes.screenWidth * 0.03,
                            ),
                            decoration: BoxDecoration(
                              color: PortColor.partner,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.call,
                                    color: Colors.white),
                                SizedBox(
                                    width: Sizes.screenWidth *
                                        0.01),
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
                    SizedBox(
                        height: Sizes.screenHeight * 0.005),
                    Divider(
                      thickness: Sizes.screenWidth * 0.002,
                      color: Colors.grey,
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.005),
                    const TextConst(title: "Sender Details",
                        fontWeight: FontWeight.bold),
                    SizedBox(
                        height: Sizes.screenHeight * 0.008),
                    Row(
                      children: [
                        const TextConst(title: 'Name       : ',
                            fontWeight: FontWeight.bold),
                        TextConst(title: ride.senderName ?? ""),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.012),
                    Row(
                      children: [
                        const TextConst(title: 'Phone      : ',
                            fontWeight: FontWeight.bold),
                        TextConst(title:
                        ride.senderPhone.toString() ??
                                ""),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.012),
                    Row(
                      children: [
                        const TextConst(title: 'Distance  : ',
                            fontWeight: FontWeight.bold),
                        TextConst(title:
                        ride.distance.toString() ?? ""),
                      ],
                    ),
                    Divider(
                      thickness: Sizes.screenWidth * 0.002,
                      color: Colors.grey,
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.01),
                    const TextConst(title: "Receiver Details",
                        fontWeight: FontWeight.bold),
                    SizedBox(
                        height: Sizes.screenHeight * 0.005),
                    Row(
                      children: [
                        const TextConst(title: 'Name       : ',
                            fontWeight: FontWeight.bold),
                        TextConst(title: ride.reciverName ?? ""),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.012),
                    Row(
                      children: [
                        const TextConst(title: 'Phone      : ',
                            fontWeight: FontWeight.bold),
                        TextConst(title:
                        ride.reciverPhone.toString() ??
                                ""),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.012),
                    Row(
                      children: [
                        const Icon(Icons.circle_outlined,
                            color: Colors.orange),
                        SizedBox(
                            width: Sizes.screenWidth * 0.02),
                        Container(
                          width: Sizes.screenWidth*0.75,
                          child: TextConst(title:
                          ride.pickupAddress ?? "",
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.012),
                    Row(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.red),
                        SizedBox(
                            width: Sizes.screenWidth * 0.02),
                        Container(
                          width: Sizes.screenWidth*0.75,
                          child: TextConst(
                            title:
                            ride.dropAddress ?? "",
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.017),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {},
                          borderRadius:
                          BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                              Sizes.screenHeight * 0.012,
                              horizontal:
                              Sizes.screenWidth * 0.053,
                            ),
                            decoration: BoxDecoration(
                              color: PortColor.partner,
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: TextConst(
                                title:
                                'Completed',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                size: Sizes.fontSizeSix,
                              ),
                            ),
                          ),
                        ),
                        // Track Button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                              Sizes.screenHeight * 0.01,
                              horizontal:
                              Sizes.screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: PortColor.partner,
                                  width: 1.0),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                    Icons.track_changes,
                                    color: PortColor.partner,
                                    size: 20),
                                SizedBox(
                                    width: Sizes.screenWidth *
                                        0.015),
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
                              vertical:
                              Sizes.screenHeight * 0.01,
                              horizontal:
                              Sizes.screenWidth * 0.06,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: PortColor.partner,
                                  width: 1.0),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: TextConst(
                              title:
                              'Help',
                              color: PortColor.partner,
                              size: Sizes.fontSizeFive,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.017),
                    TextConst(
                      title:
                      'Status: ${ride.rideStatus}',
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                        height: Sizes.screenHeight * 0.017),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.green),
                        Icon(Icons.star, color: Colors.green),
                        Icon(Icons.star, color: Colors.green),
                        Icon(Icons.star, color: Colors.green),
                        Icon(Icons.star, color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // : Center(
      //     child: TextConst("No Data Found "),
      //   ),
    );
  }
}
