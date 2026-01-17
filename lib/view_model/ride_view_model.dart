import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

class RideViewModel extends ChangeNotifier {
  List<Map<String, dynamic>>? _allRideData = [];
  Map<String, dynamic>? _activeRideData = {};
  bool _isListen = false;

  List<Map<String, dynamic>>? get allRideData => _allRideData;
  Map<String, dynamic>? get activeRideData => _activeRideData;
  bool get isListen => _isListen;

  bool _showRideCancelledDialog = false;

  setAllRideData(List<Map<String, dynamic>>? data) {
    _allRideData = data;
    notifyListeners();
  }

  setActiveRideData(Map<String, dynamic>? data) {
    _activeRideData = data;
    notifyListeners();
  }

  setIsListen(bool value) {
    _isListen = value;
  }

  void handleRideUpdate(String driverVehicleType, context) {
    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    final driverId = profileViewModel.profileModel!.data!.id;
    listenBookings(driverVehicleType, context, (bookings) {
      print("setting Booking data${bookings}");
      setAllRideData([]);
      final isActiveRideForMe = bookings.any(
        (e) => e['accepted_driver_id'].toString() == driverId.toString() && (e['rideStatus']>0 && e['rideStatus']<6)
      );
      print("jgjgkgkjgjgkj $isActiveRideForMe");
      if (isActiveRideForMe) {
        print("hgvgfhgfg");
        setAllRideData(null);
        final activeRide = bookings
            .where(
                (e) =>
            e['accepted_driver_id'].toString() == driverId.toString() &&
                (e['rideStatus'] > 0 && e['rideStatus'] < 6)
        )
            .firstOrNull;

        print("jkbhj $activeRide");
        if (activeRide != null) {
          print("jbhbhgyfygfyf");
          setActiveRideData(activeRide);
          enable78();
        } else {
          log('active ride data found as null');
        }
      } else {
        final reqBookings= bookings.where((e)=>(e['accepted_driver_id']==null || e['accepted_driver_id']==0) && e['rideStatus']==0).toList();
        print("uhbhhjhh");
        setAllRideData(reqBookings);
      }
    });
  }
  bool _handle78Enabled = false;

  // --- CONTROL ---
  void enable78() {
    _handle78Enabled = true;
  }

  void disable78() {
    _handle78Enabled = false;
  }

  bool get is78Enabled => _handle78Enabled;

  void listenBookings(
      String driverVehicleType,
      BuildContext context,
      void Function(List<Map<String, dynamic>>) onUpdate,
      ) {
    if (_isListen) return;

    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final driverIdStr = profileViewModel.profileModel!.data!.id.toString();

    FirebaseFirestore.instance.collection('order').snapshots().listen((snapshot) {
      setIsListen(true);

      final activeList = <Map<String, dynamic>>[];
      final status78List = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rideStatus = data['ride_status'] ?? 0;

        if (rideStatus < 0 || rideStatus > 8) continue;

        List<dynamic> ids = [];
        final raw = data['available_driver_id'];

        if (raw is List) {
          ids = raw;
        } else if (raw != null) {
          ids = [raw];
        }

        final idStrings = ids.map((e) => e.toString()).toList();
        if (!idStrings.contains(driverIdStr)) continue;

        final mapped = {
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
          'accepted_driver_id': data['accepted_driver_id'] ?? 0,
          'rideStatus': data['ride_status'] ?? 0,
          'payMode': data['paymode'] ?? 1,
          'otp': data['otp'] ?? 1,
        };

        if (rideStatus == 6 && data['accepted_driver_id'].toString() == driverIdStr) {
          status78List.add(mapped);  // same as 7,8
          continue;
        }

        if (rideStatus == 7 || rideStatus == 8 && data['accepted_driver_id'].toString() == driverIdStr.toString() ) {
          status78List.add(mapped);
        } else {
          activeList.add(mapped);
        }
      }

      // HANDLE STATUS 7-8 SEPARATELY
      if (_handle78Enabled && status78List.isNotEmpty ) {
        handleStatus78(status78List, context);
      }

      // RETURN ONLY ACTIVE 0-6 TO ORIGINAL HANDLER
      onUpdate(activeList);
    });
  }

  // --- SEPARATE HANDLER FOR STATUS 7 & 8 ---
  void handleStatus78(List<Map<String, dynamic>> list, BuildContext context) {
    for (var ride in list) {
      final status = ride['rideStatus'];
      if(_activeRideData!['id']==ride['id']){
        if (status == 7) {
          // CANCELLED
          _showRideCancelledDialogMethod(ride['sender_name'], context);
        }

        if (status == 8) {
          // COMPLETED
          _showRideCancelledDialogMethod(ride['sender_name'], context);
        }
      }

    }
  }
  //========================

  // void listenBookings(
  //   String driverVehicleType,
  //   context,
  //   void Function(List<Map<String, dynamic>>) onUpdate,
  // )
  // {
  //   if (_isListen == true) return;
  //   final profileViewModel = Provider.of<ProfileViewModel>(
  //     context,
  //     listen: false,
  //   );
  //   final driverId = profileViewModel.profileModel!.data!.id;
  //   final driverIdStr = driverId.toString();
  //
  //   print("👤 DRIVER ID => $driverIdStr");
  //
  //   final bookings = FirebaseFirestore.instance.collection('order');
  //
  //   bookings.snapshots().listen((snapshot) {
  //     setIsListen(true);
  //     print("----------------------------------------------------");
  //     print("📡 SNAPSHOT RECEIVED: ${snapshot.docs.length} documents");
  //
  //     final filtered = snapshot.docs
  //         .where((doc) {
  //           final data = doc.data();
  //           final rideStatus = data['ride_status'] ?? 0;
  //
  //           // if ((rideStatus == 7 || rideStatus == 8) && data['accepted_driver_id'].toString() == driverId.toString() ) {
  //           //   print("lklklkloikloi");
  //           //   _showRideCancelledDialogMethod(data['sender_name'] ,context);
  //           // }
  //
  //           final isActiveStatus =
  //               rideStatus == 0 ||
  //               rideStatus == 1 ||
  //               rideStatus == 2 ||
  //               rideStatus == 3 ||
  //               rideStatus == 4 ||
  //               rideStatus == 5 ||
  //               rideStatus == 6 ||
  //               rideStatus == 7 ||
  //               rideStatus == 8;
  //           if (!isActiveStatus) return false;
  //
  //           final raw = data['available_driver_id'];
  //           List<dynamic> ids = [];
  //
  //           if (raw is List) {
  //             ids = raw;
  //           } else if (raw is String && raw.isNotEmpty) {
  //             ids = [raw];
  //           } else if (raw is int) {
  //             ids = [raw];
  //           }
  //
  //           final idStrings = ids.map((e) => e.toString()).toList();
  //           return idStrings.contains(driverIdStr);
  //         })
  //         .map((doc) {
  //           final data = doc.data();
  //           return {
  //             'id': data['id']?.toString() ?? '',
  //             'sender_name': data['sender_name']?.toString() ?? 'N/A',
  //             'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
  //             'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
  //             'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
  //             'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
  //             'drop_address': data['drop_address']?.toString() ?? 'N/A',
  //             'available_driver_id': data['available_driver_id'],
  //             'document_id': doc.id,
  //             'order_type': data['order_type'] ?? 1,
  //             'amount': data['amount'] ?? 0,
  //             'distance': data['distance'] ?? 0,
  //             'accepted_driver_id': data['accepted_driver_id'] ?? 0,
  //             'rideStatus': data['ride_status'] ?? 0,
  //             'payMode': data['paymode'] ?? 1,
  //             'otp': data['otp'] ?? 1,
  //           };
  //         })
  //         .toList();
  //
  //     print("📦 FINAL: ${filtered.length} bookings");
  //
  //     // 🔔 send result back to UI or ViewModel
  //     onUpdate(filtered);
  //   });
  // }
  //

  void _showRideCancelledDialogMethod(String userName, BuildContext context) {
    if (_showRideCancelledDialog) {
      print("⚠️ Ride cancelled dialog already showing");
      return;
    }

    print("❌ Showing RIDE CANCELLED dialog by user: $userName");

    _showRideCancelledDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildRideCancelledDialog(userName, context);
      },
    ).then((_) {
      print("🔒 Ride cancelled dialog closed");

      _showRideCancelledDialog = false;

      // ✅ Register screen par navigate karo
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Register()),
            (route) => false,
      );
    });
  }

  Future<void> updateRideStatus(int status) async {
    await FirebaseFirestore.instance
        .collection('order')
        .doc(_activeRideData?['id'].toString())
        .update({'ride_status': status});
  }
}



Widget _buildRideCancelledDialog(String userName, BuildContext context) {
  return WillPopScope(
    onWillPop: () async => false,
    child: Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 50),
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
