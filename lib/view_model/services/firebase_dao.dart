import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yoyomiles_partner/view_model/services/fetch_live_location_stream.dart';

class FirebaseServices {
  final _firestore = FirebaseFirestore.instance.collection('driver');
  Future<void> saveOrUpdateDocument({
    required String driverId,
    required Map<String, dynamic> data,
  }) async {
    try {
      DocumentReference docRef = _firestore.doc(driverId);
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        await docRef.update(data);
        debugPrint("Document updated successfully → ID: $driverId");
        LiveLocationService().startLiveLocationUpdates(driverId);
      } else {
        // Create new document
        await docRef.set(data);
        debugPrint("New document created successfully → ID: $driverId");
        LiveLocationService().startLiveLocationUpdates(driverId);
      }
    } catch (e) {
      debugPrint("Error saving/updating document: $e");
    } finally {}
  }

  Future<void> updateUserLocation(String driverId, Position position) async {
    try {
      await _firestore.doc(driverId).set({
        'driver-location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updated_at': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      debugPrint(
        "📍 Live Location Updated: "
        "Lat: ${position.latitude}, Lng: ${position.longitude}",
      );
    } catch (e) {
      debugPrint("❌ Error updating Firestore: $e");
    }
  }
}
