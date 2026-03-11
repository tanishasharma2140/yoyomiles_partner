// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:yoyomiles_partner/view/auth/register.dart';
// import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
//
// class RideViewModel extends ChangeNotifier {
//
//
//
//   List<Map<String, dynamic>>? _allRideData = [];
//   Map<String, dynamic>? _activeRideData = {};
//   bool _isListen = false;
//
//   List<Map<String, dynamic>>? get allRideData => _allRideData;
//   Map<String, dynamic>? get activeRideData => _activeRideData;
//   bool get isListen => _isListen;
//
//   bool _showRideCancelledDialog = false;
//
//   setAllRideData(List<Map<String, dynamic>>? data) {
//     _allRideData = data;
//     notifyListeners();
//   }
//
//   setActiveRideData(Map<String, dynamic>? data) {
//     log('setting ride data: $data');
//     _activeRideData = data;
//     notifyListeners();
//   }
//
//   setIsListen(bool value) {
//     _isListen = value;
//   }
//
//   void handleRideUpdate(String driverVehicleType, context) {
//     final profileViewModel = Provider.of<ProfileViewModel>(
//       context,
//       listen: false,
//     );
//     final driverId = profileViewModel.profileModel!.data!.id;
//     listenBookings(driverVehicleType, context, (bookings) {
//       print("setting Booking data$bookings");
//       setAllRideData([]);
//       final isActiveRideForMe = bookings.any(
//         (e) =>
//             e['accepted_driver_id'].toString() == driverId.toString() &&
//             (e['rideStatus'] > 0 && e['rideStatus'] < 6),
//       );
//       print("jgjgkgkjgjgkj $isActiveRideForMe");
//       if (isActiveRideForMe) {
//         print("hgvgfhgfg ");
//         setAllRideData(null);
//         final activeRide = bookings
//             .where(
//               (e) =>
//                   e['accepted_driver_id'].toString() == driverId.toString() &&
//                   (e['rideStatus'] > 0 && e['rideStatus'] < 6),
//             )
//             .firstOrNull;
//
//         print("jkbhj $activeRide |");
//         if (activeRide != null) {
//           print("jbhbhgyfygfyf ${activeRide['rideStatus']}");
//           setActiveRideData(activeRide);
//           enable78();
//         } else {
//           final isRideCompleted = bookings.any(
//             (e) =>
//                 e['accepted_driver_id'].toString() == driverId.toString() &&
//                 e['rideStatus'] == 6,
//           );
//           if (isRideCompleted && activeRide != null) {
//             log(
//               "here it is geting to the case//"
//               "",
//             );
//             setActiveRideData(activeRide);
//           }
//           log('active ride data found as null');
//         }
//       } else {
//         final reqBookings = bookings
//             .where(
//               (e) =>
//                   (e['accepted_driver_id'] == null ||
//                       e['accepted_driver_id'] == 0) &&
//                   e['rideStatus'] == 0,
//             )
//             .toList();
//         print("uhbhhjhh");
//         setAllRideData(reqBookings);
//       }
//     });
//   }
//
//   bool _handle78Enabled = false;
//
//   // --- CONTROL ---
//   void enable78() {
//     _handle78Enabled = true;
//   }
//
//   void disable78() {
//     _handle78Enabled = false;
//   }
//
//   bool get is78Enabled => _handle78Enabled;
//
//   void listenBookings(
//     String driverVehicleType,
//     BuildContext context,
//     void Function(List<Map<String, dynamic>>) onUpdate,
//   ) {
//     if (_isListen) return;
//
//     final profileViewModel = Provider.of<ProfileViewModel>(
//       context,
//       listen: false,
//     );
//     final driverIdStr = profileViewModel.profileModel!.data!.id.toString();
//
//     FirebaseFirestore.instance.collection('order').snapshots().listen((
//       snapshot,
//     ) {
//       setIsListen(true);
//
//       final activeList = <Map<String, dynamic>>[];
//       final status78List = <Map<String, dynamic>>[];
//
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final rideStatus = data['ride_status'] ?? 0;
//
//         if (rideStatus < 0 || rideStatus > 8) continue;
//
//         List<dynamic> ids = [];
//         final raw = data['available_driver_id'];
//
//         if (raw is List) {
//           ids = raw;
//         } else if (raw != null) {
//           ids = [raw];
//         }
//
//         final idStrings = ids.map((e) => e.toString()).toList();
//         if (!idStrings.contains(driverIdStr)) continue;
//
//         final mapped = {
//           'id': data['id']?.toString() ?? '',
//           'sender_name': data['sender_name']?.toString() ?? 'N/A',
//           'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
//           'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
//           'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
//           'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
//           'drop_address': data['drop_address']?.toString() ?? 'N/A',
//           'available_driver_id': data['available_driver_id'],
//           'document_id': doc.id,
//           'order_type': data['order_type'] ?? 1,
//           'amount': data['amount'] ?? 0,
//           'distance': data['distance'] ?? 0,
//           'accepted_driver_id': data['accepted_driver_id'] ?? 0,
//           'rideStatus': data['ride_status'] ?? 0,
//           'payMode': data['paymode'] ?? 1,
//           'otp': data['otp'] ?? 1,
//           'pickup_latitute': data['pickup_latitute']?.toString(),
//           'pick_longitude': data['pick_longitude']?.toString(),
//           'drop_latitude': data['drop_latitute']?.toString(),
//           'drop_longitude': data['drop_logitute']?.toString(),
//         };
//
//         // if (rideStatus == 6 && data['accepted_driver_id'].toString() == driverIdStr) {
//         //   notifyListeners();
//         //   status78List.add(mapped);  // same as 7,8
//         //   continue;
//         // }
//
//         if (rideStatus == 7 ||
//             rideStatus == 8 || rideStatus == 6 &&
//                 data['accepted_driver_id'].toString() ==
//                     driverIdStr.toString()) {
//           status78List.add(mapped);
//         } else {
//           activeList.add(mapped);
//         }
//       }
//
//       // HANDLE STATUS 7-8 SEPARATELY
//       if (_handle78Enabled && status78List.isNotEmpty) {
//         handleStatus78(status78List, context);
//       }
//
//       // RETURN ONLY ACTIVE 0-6 TO ORIGINAL HANDLER
//       onUpdate(activeList);
//     });
//   }
//
//   // --- SEPARATE HANDLER FOR STATUS 7 & 8 ---
//   void handleStatus78(List<Map<String, dynamic>> list, BuildContext context) {
//     for (var ride in list) {
//       final status = ride['rideStatus'];
//       if (_activeRideData!['id'] == ride['id']) {
//         if(status==6 && activeRideData != null){
//           activeRideData!['rideStatus']=status;
//         }
//         if (status == 7) {
//           // CANCELLED
//           _showRideCancelledDialogMethod(ride['sender_name'], context);
//         }
//
//         if (status == 8) {
//           // COMPLETED
//           _showRideCancelledDialogMethod(ride['sender_name'], context);
//         }
//       }
//     }
//   }
//
//   void _showRideCancelledDialogMethod(String userName, BuildContext context) {
//     if (_showRideCancelledDialog) {
//       print("⚠️ Ride cancelled dialog already showing");
//       return;
//     }
//
//     print("❌ Showing RIDE CANCELLED dialog by user: $userName");
//
//     _showRideCancelledDialog = true;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return _buildRideCancelledDialog(userName, context);
//       },
//     ).then((_) {
//       print("🔒 Ride cancelled dialog closed");
//
//       _showRideCancelledDialog = false;
//
//       // ✅ Register screen par navigate karo
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => Register()),
//         (route) => false,
//       );
//     });
//   }
//
//   Future<void> updateRideStatus(int status) async {
//     await FirebaseFirestore.instance
//         .collection('order')
//         .doc(_activeRideData?['id'].toString())
//         .update({'ride_status': status});
//   }
// }
//
// Widget _buildRideCancelledDialog(String userName, BuildContext context) {
//   return WillPopScope(
//     onWillPop: () async => false,
//     child: Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.cancel, color: Colors.red, size: 50),
//             const SizedBox(height: 15),
//             Text(
//               "Ride Cancelled!",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Ride has been cancelled by $userName",
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 minimumSize: const Size(120, 45),
//               ),
//               onPressed: () {
//                 print("🏠 OK pressed from cancelled - Navigating to Register");
//                 Navigator.pop(context);
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (context) => Register()),
//                   (route) => false,
//                 );
//               },
//               child: const Text(
//                 "OK",
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

class RideViewModel extends ChangeNotifier {

  IO.Socket? _socket;

  List<Map<String, dynamic>>? _allRideData = [];
  Map<String, dynamic>? _activeRideData = {};
  bool _isListen = false;

  List<Map<String, dynamic>>? get allRideData => _allRideData;
  Map<String, dynamic>? get activeRideData => _activeRideData;

  bool get isListen => _isListen;

  bool _showRideCancelledDialog = false;

  static const String _baseUrl = "https://yoyo.codescarts.com/";

  // ─── Setters (same as before) ──────────────────────────────
  setAllRideData(List<Map<String, dynamic>>? data) {
    _allRideData = data;
    notifyListeners();
  }

  setActiveRideData(Map<String, dynamic>? data) {
    log('setting ride data: $data');
    _activeRideData = data;
    notifyListeners();
  }

  setIsListen(bool value) {
    _isListen = value;
  }

  // ─── enable78 / disable78 (same as before) ─────────────────
  bool _handle78Enabled = false;

  void enable78() => _handle78Enabled = true;
  void disable78() => _handle78Enabled = false;
  bool get is78Enabled => _handle78Enabled;

  // ─── Entry Point (same signature as before) ────────────────
  void handleRideUpdate(String driverVehicleType, BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    final driverId = profileViewModel.profileModel!.data!.id;

    listenBookings(driverVehicleType, context, (bookings) {
      print("setting Booking data $bookings");
      setAllRideData([]);

      // ── Same logic as Firebase version ──
      final isActiveRideForMe = bookings.any(
            (e) =>
        e['accepted_driver_id'].toString() == driverId.toString() &&
            (e['rideStatus'] > 0 && e['rideStatus'] < 6),
      );

      print("jgjgkgkjgjgkj $isActiveRideForMe");

      if (isActiveRideForMe) {
        print("hgvgfhgfg ");
        setAllRideData(null);

        final activeRide = bookings
            .where(
              (e) =>
          e['accepted_driver_id'].toString() == driverId.toString() &&
              (e['rideStatus'] > 0 && e['rideStatus'] < 6),
        )
            .firstOrNull;

        print("jkbhj $activeRide |");

        if (activeRide != null) {
          print("jbhbhgyfygfyf ${activeRide['rideStatus']}");
          setActiveRideData(activeRide);
          enable78();
        } else {
          final isRideCompleted = bookings.any(
                (e) =>
            e['accepted_driver_id'].toString() == driverId.toString() &&
                e['rideStatus'] == 6,
          );
          if (isRideCompleted && activeRide != null) {
            log("here it is geting to the case//");
            setActiveRideData(activeRide);
            print("✅ ActiveRideData set — id: ${_activeRideData?['id']}");
          }
          log('active ride data found as null');
        }
      } else {
        final reqBookings = bookings
            .where(
              (e) =>
          (e['accepted_driver_id'] == null ||
              e['accepted_driver_id'] == 0) &&
              e['rideStatus'] == 0,
        )
            .toList();
        print("uhbhhjhh");
        setAllRideData(reqBookings);
      }
    });
  }



  // ─── listenBookings — Firebase ki jagah Socket ─────────────
  void listenBookings(
      String driverVehicleType,
      BuildContext context,
      void Function(List<Map<String, dynamic>>) onUpdate,
      ) {
    if (_isListen) return;

    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    final driverIdStr = profileViewModel.profileModel!.data!.id.toString();

    // ── Socket connect ──────────────────────────────────────
    _socket?.disconnect();
    _socket?.dispose();

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setTimeout(20000)
          .build(),
    );

    _socket!.onConnect((_) {
      print("✅ Driver socket connected: ${_socket!.id}");
      // JOIN_DRIVER emit — HTML test mein driverId se join tha
      _socket!.emit('JOIN_DRIVER', driverIdStr);
      print("📤 Emitted JOIN_DRIVER: $driverIdStr");
    });

    _socket!.on('JOIN_CONFIRMED', (data) {
      print("✅ Driver Join Confirmed: $data");
      setIsListen(true);
    });

    // ── SYNC_RIDES — initial available orders (Firebase snapshot jaisa) ──
    _socket!.on('SYNC_RIDES', (data) {
      print("📋 SYNC_RIDES received: $data");
      _processBookings(data, driverIdStr, context, onUpdate);
    });

    // ── NEW_RIDE — naya order aaya ──
    _socket!.on('NEW_RIDE', (data) {
      print("🔥 NEW_RIDE received: $data");

      // NEW_RIDE single object aata hai, list mein wrap karo
      final List<dynamic> incoming = data is List ? data : [data];

      // Existing list ke saath merge karo
      final existing = List<Map<String, dynamic>>.from(
        _allRideData ?? [],
      );

      for (var ride in incoming) {
        final mapped = _mapRideData(ride, driverIdStr);
        if (mapped == null) continue;

        // Duplicate check — same order_id already hai toh skip
        final alreadyExists = existing.any(
              (e) => e['id'].toString() == mapped['id'].toString(),
        );
        if (!alreadyExists) {
          existing.add(mapped);
          print("➕ New ride added: ${mapped['id']}");
        }
      }

      // Sirf available rides dikhao (accepted_driver_id null/0 && status 0)
      final reqBookings = existing
          .where(
            (e) =>
        (e['accepted_driver_id'] == null ||
            e['accepted_driver_id'] == 0) &&
            e['rideStatus'] == 0,
      )
          .toList();

      setAllRideData(reqBookings);
    });

    // ── ORDER_UPDATE — ride status change ──
    _socket!.on('ORDER_UPDATE', (data) {
      print("📦 ORDER_UPDATE received: $data");
      _handleOrderUpdate(data, driverIdStr, context, onUpdate);
    });

    _socket!.on('LOCATION_UPDATED', (data) {
      print("📍 Location confirmed: $data");
    });

    _socket!.onDisconnect((_) {
      print("❌ Driver socket disconnected");
    });

    _socket!.onConnectError((err) {
      print("❌ Driver socket error: $err");
    });

    _socket!.connect();
  }

  // ─── SYNC_RIDES data process karo ──────────────────────────
  void _processBookings(
      dynamic data,
      String driverIdStr,
      BuildContext context,
      void Function(List<Map<String, dynamic>>) onUpdate,
      ) {
    try {
      final List<dynamic> rawList = data is List ? data : [data];

      final activeList = <Map<String, dynamic>>[];
      final status78List = <Map<String, dynamic>>[];

      for (var raw in rawList) {
        final mapped = _mapRideData(raw, driverIdStr);
        if (mapped == null) continue;

        final rideStatus = mapped['rideStatus'] as int;

        // ── Same filtering logic as Firebase ──
        if (rideStatus < 0 || rideStatus > 8) continue;
        // ✅ Agar ye mapped ride current active ride hai toh payMode preserve karo
        final existingPayMode = _activeRideData?['payMode'];
        if (_activeRideData?['id']?.toString() == mapped['id']?.toString() &&
            existingPayMode != null && existingPayMode != 0 &&
            (mapped['payMode'] == null || mapped['payMode'] == 0)) {
          mapped['payMode'] = existingPayMode;
        }

        if (rideStatus == 7 ||
            rideStatus == 8 ||
            (rideStatus == 6 &&
                mapped['accepted_driver_id'].toString() == driverIdStr)) {
          status78List.add(mapped);
        } else {
          activeList.add(mapped);
        }
      }

      // ── Same handler as Firebase ──
      if (_handle78Enabled && status78List.isNotEmpty) {
        handleStatus78(status78List, context);
      }

      onUpdate(activeList);
    } catch (e) {
      print("❌ _processBookings error: $e");
    }
  }

  // ─── ORDER_UPDATE handle karo ──────────────────────────────
  void _handleOrderUpdate(
      dynamic data,
      String driverIdStr,
      BuildContext context,
      void Function(List<Map<String, dynamic>>) onUpdate,
      ) {
    try {
      final mapped = _mapRideData(data, driverIdStr);
      if (mapped == null) return;

      final rideStatus = mapped['rideStatus'] as int;
      final mappedId = mapped['id']?.toString().trim();
      final activeId = _activeRideData?['id']?.toString().trim();

      print("📦 ORDER_UPDATE — mappedId: $mappedId | activeId: $activeId | status: $rideStatus");

      // ✅ Active ride sync
      if (activeId != null && activeId == mappedId) {
        final existingPayMode = _activeRideData?['payMode'];
        final incomingPayMode = mapped['payMode'];

        // Agar existing payMode valid (>0) aur incoming 0/null hai toh preserve karo
        if (existingPayMode != null &&
            existingPayMode != 0 &&
            (incomingPayMode == null || incomingPayMode == 0)) {
          mapped['payMode'] = existingPayMode;
          print("🔒 payMode preserved: $existingPayMode (incoming was: $incomingPayMode)");
        }

        _activeRideData = mapped;
        print("✅ activeRideData synced | payMode: ${mapped['payMode']}");
      }

      // ✅ Status 7/8 — DIRECTLY handle, flag check mat karo
      if (rideStatus == 7 || rideStatus == 8) {
        // ✅ ID match karo — agar match ho ya activeRideData empty/null ho
        final bool idMatches = activeId != null &&
            activeId.isNotEmpty &&
            activeId == mappedId;

        // ✅ Agar activeRideData mein koi data hai lekin id match nahi — skip karo
        // Agar activeRideData empty/null hai — show karo (status 1 pe bhi)
        final bool noActiveRide = activeId == null || activeId.isEmpty;

        print("🔍 Status 7/8 check — idMatches: $idMatches | noActiveRide: $noActiveRide");

        if (idMatches || noActiveRide) {
          final userName = mapped['sender_name']?.toString() ?? 'User';
          print("🚨 Showing cancel dialog for: $userName");
          _showRideCancelledDialogMethod(userName, context);
        } else {
          print("⚠️ ID mismatch — cancel dialog skip kiya");
          print("   activeId: '$activeId'");
          print("   mappedId: '$mappedId'");
        }
        return;
      }

      // Existing list update
      final existing = List<Map<String, dynamic>>.from(_allRideData ?? []);
      final idx = existing.indexWhere(
            (e) => e['id'].toString() == mappedId,
      );
      if (idx != -1) {
        existing[idx] = mapped;
      } else {
        existing.add(mapped);
      }

      final activeList = <Map<String, dynamic>>[];
      final status78List = <Map<String, dynamic>>[];

      for (var ride in existing) {
        final s = ride['rideStatus'] as int;
        if (s == 7 || s == 8 ||
            (s == 6 && ride['accepted_driver_id'].toString() == driverIdStr)) {
          status78List.add(ride);
        } else {
          activeList.add(ride);
        }
      }

      if (_handle78Enabled && status78List.isNotEmpty) {
        handleStatus78(status78List, context);
      }

      onUpdate(activeList);
    } catch (e) {
      print("❌ _handleOrderUpdate error: $e");
    }
  }

  // ── JOIN_DRIVER — server format ke hisaab se ──────────────────
  void joinDriverWithProfile(Map<String, dynamic> driverPayload) {
    final driverId = driverPayload['driverId'].toString();

    if (_socket == null || !(_socket!.connected)) {
      _socket = IO.io(
        _baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .build(),
      );

      _socket!.onConnect((_) {
        print("✅ Socket connected for JOIN_DRIVER");

        // ✅ Server sirf string driverId chahta hai
        _socket!.emit('JOIN_DRIVER', driverId);
        print("📤 JOIN_DRIVER emitted: $driverId");

        // ✅ Profile data alag event se bhejo agar server support kare
        // warna sirf location update enough hai
      });

      _socket!.connect();
    } else {
      // Already connected
      _socket!.emit('JOIN_DRIVER', driverId);
      print("📤 JOIN_DRIVER emitted: $driverId");
    }
  }

  // ─── Firebase mapped fields → Same map structure maintain ──
  Map<String, dynamic>? _mapRideData(dynamic raw, String driverIdStr) {
    try {
      final data = Map<String, dynamic>.from(raw);
      print("SERVER PAYMODE: ${data['paymode']}");

      final id = data['order_id']?.toString() ?? data['id']?.toString() ?? '';
      if (id.isEmpty) return null;

      return {
        'id': id,
        'sender_name': data['sender_name']?.toString() ?? 'N/A',
        'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
        'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
        'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
        'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
        'drop_address': data['drop_address']?.toString() ?? 'N/A',
        'available_driver_id': data['available_driver_id'],
        'document_id': id, // Firebase mein doc.id tha, ab same as id
        'order_type': int.tryParse(data['order_type']?.toString() ?? '1') ?? 1,
        'amount': data['amount'] ?? 0,
        'distance': data['distance'] ?? 0,
        'accepted_driver_id': data['accepted_driver_id'] ?? 0,
        'rideStatus': int.tryParse(data['ride_status']?.toString() ?? '0') ?? 0,
        'payMode': int.tryParse(data['paymode']?.toString() ?? '0') ?? 0,
        'otp': data['otp'] ?? 1,
        'pickup_latitute': data['pickup_latitute']?.toString(),
        'pick_longitude': data['pick_longitude']?.toString(),
        'drop_latitude': data['drop_latitute']?.toString(),
        'drop_longitude': data['drop_logitute']?.toString(),
      };
    } catch (e) {
      print("❌ _mapRideData error: $e");
      return null;
    }
  }

  // ─── handleStatus78 — same as Firebase version ─────────────
  void handleStatus78(
      List<Map<String, dynamic>> list,
      BuildContext context,
      ) {
    for (var ride in list) {
      final status = ride['rideStatus'];

      // ✅ activeRideData null/empty हो तो भी check करो
      final activeId = _activeRideData?['id']?.toString();
      final rideId = ride['id']?.toString();

      print("🔍 handleStatus78 — activeId: $activeId | rideId: $rideId | status: $status");

      // ✅ ID match karo — agar activeRideData empty hai toh bhi status 7/8 show karo
      final bool idMatches = activeId != null && activeId == rideId;
      final bool noActiveRide = activeId == null || activeId.isEmpty;

      if (idMatches || noActiveRide) {
        if (status == 6 && _activeRideData != null) {
          _activeRideData!['rideStatus'] = status;
          notifyListeners();
        }
        if (status == 7 || status == 8) {
          final userName = ride['sender_name']?.toString() ?? 'User';
          _showRideCancelledDialogMethod(userName, context);
        }
      }
    }
  }

  // ─── Dialog — same as Firebase version ────────────────────
  void _showRideCancelledDialogMethod(
      String userName,
      BuildContext context,
      ) {
    if (_showRideCancelledDialog) {
      print("⚠️ Ride cancelled dialog already showing");
      return;
    }

    // ✅ navigatorKey se valid context lo — socket callback mein original context invalid hota hai
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      print("❌ navigatorKey context null — dialog skip");
      return;
    }

    print("❌ Showing RIDE CANCELLED dialog by user: $userName");
    _showRideCancelledDialog = true;

    showDialog(
      context: ctx, // ✅ original context ki jagah navigatorKey context
      barrierDismissible: false,
      builder: (dialogContext) {
        return _buildRideCancelledDialog(userName, dialogContext);
      },
    ).then((_) {
      print("🔒 Ride cancelled dialog closed");
      _showRideCancelledDialog = false;

      final navCtx = navigatorKey.currentContext;
      if (navCtx != null) {
        Navigator.of(navCtx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Register()),
              (route) => false,
        );
      }
    });
  }

  // ─── updateRideStatus — Socket emit (Firebase direct update tha) ─
  Future<void> updateRideStatus(int status) async {
    final orderId = _activeRideData?['id']?.toString();
    if (orderId == null) return;

    // Socket se status update bhejo
    _socket?.emit('UPDATE_RIDE_STATUS', {
      'orderId': orderId,
      'status': status,
    });

    print("📤 Emitted UPDATE_RIDE_STATUS: orderId=$orderId status=$status");
  }

  // ─── Location update emit ───────────────────────────────────
  void updateDriverLocation(String driverId, double lat, double lng) {
    _socket?.emit('UPDATE_LOCATION', {
      'driverId': driverId,
      'latitude': lat.toString(),
      'longitude': lng.toString(),
    });
    print("📍 Location emitted: $lat, $lng");
  }

  // ─── Disconnect ─────────────────────────────────────────────
  void disconnect() {
    print("🛑 Disconnecting driver socket");
    _isListen = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

// ─── Dialog Widget — same as before ────────────────────────────
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
                Navigator.pop(context);
                final navCtx = navigatorKey.currentContext;
                if (navCtx != null) {
                  Navigator.of(navCtx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => Register()),
                        (route) => false,
                  );
                }
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