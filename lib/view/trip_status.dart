import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

import '../view_model/update_ride_status_view_model.dart';

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

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRinging = false;
  bool forceStop = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  // Future<void> expireBooking(String documentId) async {
  //   try {
  //     print("⏳ Expiring booking after 1.5 minutes: $documentId");
  //
  //     // 🔥 1️⃣ Firebase status update
  //     await FirebaseFirestore.instance
  //         .collection('order')
  //         .doc(documentId)
  //         .update({'ride_status': 9});
  //
  //     // 🔥 2️⃣ Update Ride Status API (status 8 = cancelled by system)
  //     final updateRideStatusVm =
  //     Provider.of<UpdateRideStatusViewModel>(context, listen: false);
  //
  //     await updateRideStatusVm.updateRideApi(
  //       context,
  //       documentId,
  //
  //       "9", // Cancelled by driver/system
  //     );
  //
  //     print("🚫 UpdateRideAPI fired (Status 8)");
  //
  //     // 🔥 3️⃣ Stop ringtone
  //     stopRingtone();
  //
  //     print("✅ Booking $documentId expired successfully!");
  //   } catch (e) {
  //     print("❌ Error expiring booking: $e");
  //   }
  // }



  @override
  void dispose() {
    // Ensure ringtone stopped and player released
    try {
      bookingTimers.forEach((key, timer) => timer.cancel());
      _audioPlayer.stop();
      _audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }

  void getCurrentLocation() async {
    try {
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

  // --- AUDIO: play ringtone (fixed path + audio context) ---
  Future<void> playRingtone() async {
    print("🔔 playRingtone called");

    if (isRinging) {
      print("⛔ Already ringing - skip");
      return;
    }

    try {
      isRinging = true;

      // Set AudioContext for Android (improves reliability on 12/13)
      await _audioPlayer.setAudioContext(
        const AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            usageType: AndroidUsageType.alarm,
            contentType: AndroidContentType.music,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(),
        ),
      );
      print("🎧 AudioContext set");

      // IMPORTANT: AssetSource should NOT include folder prefix when asset declared in pubspec with folder
      await _audioPlayer.play(
        AssetSource("driver_ringtone.mp3"),
        volume: 1.0,
      );
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      print("✅ Play command sent and looping enabled");
    } catch (e) {
      print("❌ Error in playRingtone: $e");
      // Ensure flag reset on error
      isRinging = false;
    }
  }

  Future<void> stopRingtone() async {
    print("🛑 stopRingtone called");

    forceStop = true; // 🔥 Prevents ringtone from starting again

    if (!isRinging) return;

    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("⚠️ error stopping audio: $e");
    }

    isRinging = false;
    print("🔕 Ringtone fully stopped");
  }


  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // stop ringtone when leaving screen
              stopRingtone();
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
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fetchBookings("", context),
          builder: (context, snapshot) {
            print(
              "📡 StreamBuilder update: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}",
            );

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
            }

            final bookingList = snapshot.data ?? [];
            print("📦 bookingList.length = ${bookingList.length}");

            for (var booking in bookingList) {
              String id = booking['document_id'];

              // if (!bookingTimers.containsKey(id)) {
              //   print("⏳ Timer started for booking: $id");
              //
              //   bookingTimers[id] = Timer(Duration(seconds: 90), () {
              //     expireBooking(id);
              //   });
              // }
            }

// CLEAR TIMER FOR BOOKINGS THAT ARE REMOVED FROM FIREBASE
            bookingTimers.removeWhere((key, timer) {
              bool exists = bookingList.any((b) => b['document_id'] == key);
              if (!exists) {
                print("🗑 Timer removed for expired/removed booking: $key");
                timer.cancel();
                return true;
              }
              return false;
            });

            // --- real-time ringtone trigger ---
            if (!forceStop && bookingList.isNotEmpty) {
              playRingtone();
            } else {
              stopRingtone();
            }

            // NO BOOKINGS UI
            if (bookingList.isEmpty) {
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLat, currentLng),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    onMapCreated: (controller) {},
                  ),
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
                                "Stay online and you’ll receive a booking as soon as a customer requests a ride.",
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
                ],
              );
            }

            // BOOKINGS UI
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
                            if (mounted) {
                              setState(() {
                                _currentAddress = address;
                              });
                            }
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

                          // Booking List
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: bookingList.length,
                              itemBuilder: (context, index) {
                                return BookingCard(
                                  bookingData: bookingList[index],
                                  stopRingtoneCallback:
                                      stopRingtone, // pass callback so accept button can stop ringtone
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
}

/// ✅ CORRECTED Stream for matching bookings with ride_status filter
Stream<List<Map<String, dynamic>>> fetchBookings(
  String driverVehicleType,
  context,
) {
  final profileViewModel = Provider.of<ProfileViewModel>(
    context,
    listen: false,
  );

  final driverId = profileViewModel.profileModel!.data!.id;
  final driverIdStr = driverId.toString();

  print("👤 DRIVER ID => $driverIdStr");

  final bookings = FirebaseFirestore.instance.collection('order');

  return bookings.snapshots().map((snapshot) {
    print("----------------------------------------------------");
    print("📡 SNAPSHOT RECEIVED: ${snapshot.docs.length} documents");

    final filtered = snapshot.docs
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          print("\n📄 Document: ${doc.id}");
          print("RAW DATA => $data");

          final rideStatus = data['ride_status'] ?? 0;
          print("➡️ ride_status: $rideStatus");

          final isActiveStatus =
              rideStatus == 0 ||
              rideStatus == 1 ||
              rideStatus == 2 ||
              rideStatus == 3;
          print("✔️ isActiveStatus = $isActiveStatus");

          if (!isActiveStatus) {
            print("❌ SKIPPED (Ride status invalid)");
            return false;
          }

          final raw = data['available_driver_id'];
          print("➡️ RAW available_driver_id = $raw (${raw.runtimeType})");

          List<dynamic> ids = [];
          if (raw is List) {
            ids = raw;
          } else if (raw is String && raw.isNotEmpty) {
            ids = [raw];
          } else if (raw is int) {
            ids = [raw];
          }

          print("➡️ Converted driver list: $ids");

          final idStrings = ids.map((e) => e.toString()).toList();
          print("➡️ Converted to String list: $idStrings");

          final isDriverAvailable = idStrings.contains(driverIdStr);
          print("✔️ isDriverAvailable = $isDriverAvailable");

          if (!isDriverAvailable) {
            print("❌ SKIPPED (Driver ID not found in list)");
          }

          return isDriverAvailable;
        })
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print("\n🎯 ADDING FILTERED DATA => ${doc.id}");

          return {
            'id': data['id']?.toString() ?? '',
            'sender_name': data['sender_name']?.toString() ?? 'N/A',
            'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
            'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
            'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
            'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
            'drop_address': data['drop_address']?.toString() ?? 'N/A',
            'available_driver_id': data['available_driver_id'],
            'document_id': doc.id,
            'order_type': data['order_type'] ?? 1,
            'amount': data['amount'] ?? 0,
            'distance': data['distance'] ?? 0,
          };
        })
        .toList();

    print("\n📦 FINAL FILTERED BOOKINGS: ${filtered.length}");

    for (var booking in filtered) {
      print("👉 Booking ID: ${booking['id']} (Doc: ${booking['document_id']})");
    }

    print("----------------------------------------------------");

    return filtered;
  });
}

/// BookingCard modified to accept a stopRingtone callback
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final VoidCallback? stopRingtoneCallback;

  const BookingCard({
    super.key,
    required this.bookingData,
    this.stopRingtoneCallback,
  });

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
            // header row
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
            SizedBox(height: Sizes.screenHeight * 0.01),

            // sender/receiver and addresses (reuse your helper if you have it)
            // For brevity reuse your existing row builder if available (we assume _buildDetailRow exists in same file)
            // If not, you can paste the helper from previous code.
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
                    onTap: () async {
                      if (stopRingtoneCallback != null) {
                        stopRingtoneCallback!();   // ❌ no await
                      }

                      String bookingId = bookingData['id'].toString();
                      print("🚗 ACCEPT pressed for bookingId: $bookingId");

                      assignRideViewModel.assignRideApi(
                        context,
                        1,
                        bookingId,
                        bookingData,
                      );
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

  // Note: keep the same helper function implementation as in your project
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
