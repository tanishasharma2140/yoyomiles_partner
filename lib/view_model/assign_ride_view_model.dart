import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/assign_ride_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/live_ride_screen.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
class AssignRideViewModel with ChangeNotifier {
  final _assignRideRepo = AssignRideRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> assignRideApi(
      context,
      dynamic rideStatus,
      String rideDocId,
      Map<String, dynamic> bookingData,
      ) async {

    print("\n================ ACCEPT RIDE START ================");
    setLoading(true);

    final userId = await UserViewModel().getUser();

    Map data = {
      "driver_id": userId,
      "ride_status": rideStatus,
      "ride_id": bookingData['id'],  // API wale ride ID
    };

    print("📤 Sending API Request: $data");

    _assignRideRepo.assignRideApi(data).then((value) async {
      setLoading(false);

      print("📥 API Response: $value");

      if (value['success'] == true) {
        print("✅ API SUCCESS");

        try {
          print("📌 Updating Firestore Document: $rideDocId");

          await FirebaseFirestore.instance
              .collection('order')
              .doc(rideDocId)
              .update({
            'accepted_driver_id': userId,
            'ride_status': 1,
            'ride_started': true,
          });

          print("🔥 Firestore Updated Successfully");

        } catch (e) {
          print("❌ FIRESTORE UPDATE FAILED: $e");
        }

        // Utils.showSuccessMessage(context, value["message"]);

        print("➡ Navigating to LiveRideScreen");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveRideScreen(booking: bookingData),
          ),
        );
      }

      else if (value['status'] == 400) {
        print("⚠️ RIDE ALREADY ASSIGNED TO SOMEONE ELSE");
      }

      else {
        print("❌ API FAILED: ${value["message"]}");
      }

    }).onError((error, stackTrace) {
      setLoading(false);
      print("💥 API ERROR: $error");
    });

    print("================ ACCEPT RIDE END ================\n");
  }



}
