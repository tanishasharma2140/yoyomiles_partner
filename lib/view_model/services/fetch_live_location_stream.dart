import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yoyomiles_partner/view_model/services/firebase_dao.dart';

class LiveLocationService {
  StreamSubscription<Position>? _positionStream;

  bool _updating = false;
  bool get updating => _updating;

  /// Start listening to live location & update Firestore in real-time
  Future<void> startLiveLocationUpdates(String userId) async {

    try {
      // 1️⃣ Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("❌ Location service is disabled.");
      }

      // 2️⃣ Start listening to position stream
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20, // update every 5 meters
        ),
      ).listen((Position position) async {
        await FirebaseServices().updateUserLocation(userId, position);
      });
    } catch (e) {
      debugPrint("❌ Error starting live location updates: $e");
    }
  }


  /// 🔹 Stop listening when user logs out or app closes
  void stopLiveLocationUpdates() {
    _positionStream?.cancel();
    debugPrint("🛑 Live location updates stopped");
  }
}
