import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/service/ride_notification_helper.dart';
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

  static const String _baseUrl = "https://dev.yoyomiles.com/";

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

  bool _handle78Enabled = false;
  void enable78() => _handle78Enabled = true;
  void disable78() => _handle78Enabled = false;
  bool get is78Enabled => _handle78Enabled;

  void stopRideRingtone() {
    FlutterBackgroundService().invoke('STOP_RINGTONE');
    RideNotificationHelper.clear();
    print("🔕 Ringtone stopped from RideViewModel");
  }

  void handleRideUpdate(String driverVehicleType, BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );
    final driverId = profileViewModel.profileModel!.data!.id;

    listenBookings(driverVehicleType, context, (bookings) {
      print("yaha ana ha — Total bookings: ${bookings.length}");
      
      final isActiveRideForMe = bookings.any(
        (e) {
          bool idMatch = e['accepted_driver_id'].toString() == driverId.toString();
          bool statusMatch = e['rideStatus'] > 0 && e['rideStatus'] <= 6;
          if (statusMatch) {
             print("🔍 Potential Active Ride: ID=${e['id']} | Status=${e['rideStatus']} | DriverMatch=$idMatch (Me=$driverId, Ride=${e['accepted_driver_id']})");
          }
          return idMatch && statusMatch;
        },
      );

      if (isActiveRideForMe) {
        FlutterBackgroundService().invoke('STOP_RINGTONE');
        RideNotificationHelper.clear();
        
        final activeRide = bookings
            .where(
              (e) =>
                  e['accepted_driver_id'].toString() == driverId.toString() &&
                  (e['rideStatus'] > 0 && e['rideStatus'] <= 6),
            ).firstOrNull;

        if (activeRide != null) {
          print("✅ Setting Active Ride Data: Status ${activeRide['rideStatus']}");
          setActiveRideData(activeRide);
          enable78();
        }
      } else {
        final reqBookings = bookings
            .where(
              (e) =>
                  (e['accepted_driver_id'] == null ||
                      e['accepted_driver_id'] == 0 ||
                      e['accepted_driver_id'].toString() == "0") &&
                  e['rideStatus'] == 0,
            )
            .toList();
        
        if (reqBookings.isNotEmpty) {
          FlutterBackgroundService().invoke('START_RINGTONE');
          RideNotificationHelper.showIncomingRide(reqBookings.first);
        } else {
          FlutterBackgroundService().invoke('STOP_RINGTONE');
          RideNotificationHelper.clear();
        }

        setAllRideData(reqBookings);
      }
    });
  }

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
      _socket!.emit('JOIN_DRIVER', driverIdStr);
    });

    _socket!.on('JOIN_CONFIRMED', (data) {
      print("✅ Driver Join Confirmed: $data");
      setIsListen(true);
    });

    _socket!.on('SYNC_RIDES', (data) {
      print("📋 SYNC_RIDES received");
      _processBookings(data, driverIdStr, context, onUpdate);
    });

    _socket!.on('NEW_RIDE', (data) {
      print("🔥 NEW_RIDE received");
      FlutterBackgroundService().invoke('START_RINGTONE');

      final List<dynamic> incoming = data is List ? data : [data];
      final existing = List<Map<String, dynamic>>.from(_allRideData ?? []);

      for (var ride in incoming) {
        final mapped = _mapRideData(ride, driverIdStr);
        if (mapped == null) continue;

        final alreadyExists = existing.any(
          (e) => e['id'].toString() == mapped['id'].toString(),
        );
        if (!alreadyExists) {
          existing.add(mapped);
        }
      }

      final reqBookings = existing
          .where(
            (e) =>
                (e['accepted_driver_id'] == null ||
                    e['accepted_driver_id'] == 0 ||
                    e['accepted_driver_id'].toString() == "0") &&
                e['rideStatus'] == 0,
          )
          .toList();

      if (reqBookings.isNotEmpty) {
        RideNotificationHelper.showIncomingRide(reqBookings.first);
      }
      setAllRideData(reqBookings);
    });

    _socket!.on('ORDER_UPDATE', (data) {
      print("📦 ORDER_UPDATE received: Status=${data['ride_status']}, Paymode=${data['paymode']}");
      _handleOrderUpdate(data, driverIdStr, context, onUpdate);
    });

    _socket!.onDisconnect((_) => print("❌ Driver socket disconnected"));
    _socket!.onConnectError((err) => print("❌ Driver socket error: $err"));
    _socket!.connect();
  }

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
        if (rideStatus < 0 || rideStatus > 8) continue;

        if (rideStatus == 7 || rideStatus == 8) {
          status78List.add(mapped);
        } else {
          activeList.add(mapped);
        }
      }

      if (_handle78Enabled && status78List.isNotEmpty) {
        handleStatus78(status78List, context);
      }
      onUpdate(activeList);
    } catch (e) {
      print("❌ _processBookings error: $e");
    }
  }

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

      bool isMyActiveRide = activeId != null && activeId == mappedId;

      // ✅ IMPROVED: Robust matching to update active ride data
      bool belongsToMe = mapped['accepted_driver_id'].toString() == driverIdStr &&
                         rideStatus > 0 && rideStatus <= 6;

      if (isMyActiveRide || belongsToMe) {
        if (isMyActiveRide) {
          // Merge to avoid losing data from partial updates
          final mergedData = Map<String, dynamic>.from(_activeRideData!);

          // Only update if the value is provided (non-zero/non-null)
          if (mapped['payMode'] != 0) {
            mergedData['payMode'] = mapped['payMode'];
          }
          if (mapped['rideStatus'] != 0) {
            mergedData['rideStatus'] = mapped['rideStatus'];
          }
          // Keep/update other fields selectively
          if (mapped['sender_name'] != 'N/A') mergedData['sender_name'] = mapped['sender_name'];
          if (mapped['sender_phone'] != 'N/A') mergedData['sender_phone'] = mapped['sender_phone'];

          _activeRideData = mergedData;
        } else {
          _activeRideData = mapped;
        }

        notifyListeners();
        print("✅ Active ride updated via ORDER_UPDATE: Status ${_activeRideData?['rideStatus']}, PayMode ${_activeRideData?['payMode']}");
      }

      if (rideStatus == 7 || rideStatus == 8) {
        if (activeId == null || activeId == mappedId) {
          FlutterBackgroundService().invoke('STOP_RINGTONE');
          RideNotificationHelper.clear();
          _showRideCancelledDialogMethod(mapped['sender_name']?.toString() ?? 'User', context);
        }
        return;
      }

      // Update the general list
      final existing = List<Map<String, dynamic>>.from(_allRideData ?? []);
      final idx = existing.indexWhere((e) => e['id'].toString() == mappedId);
      if (idx != -1) existing[idx] = mapped; else existing.add(mapped);

      final activeList = <Map<String, dynamic>>[];
      for (var ride in existing) {
        final s = ride['rideStatus'] as int;
        if (s != 7 && s != 8) activeList.add(ride);
      }
      onUpdate(activeList);
    } catch (e) {
      print("❌ _handleOrderUpdate error: $e");
    }
  }

  // ✅ ADDED BACK: joinDriverWithProfile method
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
        _socket!.emit('JOIN_DRIVER', driverPayload); // Pass full payload for initial join
        print("📤 JOIN_DRIVER emitted: $driverId");
      });

      _socket!.connect();
    } else {
      _socket!.emit('JOIN_DRIVER', driverPayload);
      print("📤 JOIN_DRIVER emitted: $driverId");
    }
  }

  Map<String, dynamic>? _mapRideData(dynamic raw, String driverIdStr) {
    try {
      final data = Map<String, dynamic>.from(raw);
      final id = data['order_id']?.toString() ?? data['id']?.toString() ?? '';
      if (id.isEmpty) return null;

      print("========== MAPPED RIDE DATA START ==========");
      print("🆔 ID: $id");
      print("📍 Pickup: ${data['pickup_address']}");
      print("📍 Drop: ${data['drop_address']}");

// 🔥 RAW stops
      print("🧾 RAW STOPS: ${data['stops']}");

// 🔥 PARSED stops
      final parsedStops = data['stops'] != null && data['stops'].toString().isNotEmpty
          ? List<Map<String, dynamic>>.from(jsonDecode(data['stops']))
          : [];

      print("✅ PARSED STOPS: $parsedStops");

// 🔍 each stop detail
      for (int i = 0; i < parsedStops.length; i++) {
        print("➡️ Stop $i:");
        parsedStops[i].forEach((key, value) {
          print("   $key : $value");
        });
      }

      print("========== MAPPED RIDE DATA END ==========");

      return {
        'id': id,
        'sender_name': data['sender_name']?.toString() ?? 'N/A',
        'sender_phone': data['sender_phone']?.toString() ?? 'N/A',
        'pickup_address': data['pickup_address']?.toString() ?? 'N/A',
        'stops': data['stops'] != null && data['stops'].toString().isNotEmpty
            ? List<Map<String, dynamic>>.from(jsonDecode(data['stops']))
            : [],
        'reciver_name': data['reciver_name']?.toString() ?? 'N/A',
        'reciver_phone': data['reciver_phone']?.toString() ?? 'N/A',
        'drop_address': data['drop_address']?.toString() ?? 'N/A',
        'available_driver_id': data['available_driver_id'],
        'document_id': id,
        'order_type': int.tryParse(data['order_type']?.toString() ?? '1') ?? 1,
        'amount': data['amount'] ?? 0,
        'distance': data['distance'] ?? 0,
        // ✅ Check both potential driver ID keys
        'accepted_driver_id': data['accepted_driver_id'] ?? data['driver_id'] ?? 0,
        'rideStatus': int.tryParse(data['ride_status']?.toString() ?? '0') ?? 0,
        'payMode': int.tryParse(data['paymode']?.toString() ?? '0') ?? 0,
        'otp': data['otp'] ?? 1,
        'pickup_latitute': data['pickup_latitute']?.toString(),
        'pick_longitude': data['pick_longitude']?.toString(),
        'drop_latitude': data['drop_latitute']?.toString(),
        'drop_longitude': data['drop_logitute']?.toString(),
      };
    } catch (e) {
      return null;
    }
  }

  void handleStatus78(List<Map<String, dynamic>> list, BuildContext context) {
    for (var ride in list) {
      final status = ride['rideStatus'];
      final activeId = _activeRideData?['id']?.toString();
      if (activeId == null || activeId == ride['id']?.toString()) {
        if (status == 7 || status == 8) {
          FlutterBackgroundService().invoke('STOP_RINGTONE');
          RideNotificationHelper.clear();
          _showRideCancelledDialogMethod(ride['sender_name']?.toString() ?? 'User', context);
        }
      }
    }
  }

  void _showRideCancelledDialogMethod(String userName, BuildContext context) {
    if (_showRideCancelledDialog) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    _showRideCancelledDialog = true;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) => _buildRideCancelledDialog(userName, dCtx),
    ).then((_) {
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

  Future<void> updateRideStatus(int status) async {
    final orderId = _activeRideData?['id']?.toString();
    if (orderId == null) return;
    _socket?.emit('UPDATE_RIDE_STATUS', {'orderId': orderId, 'status': status});
  }

  void updateDriverLocation(String driverId, double lat, double lng) {
    _socket?.emit('UPDATE_LOCATION', {
      'driverId': driverId,
      'latitude': lat.toString(),
      'longitude': lng.toString(),
    });
  }

  void disconnect() {
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
            const Text("Ride Cancelled!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            Text("Ride has been cancelled by $userName", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), minimumSize: const Size(120, 45)),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );
}
