import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/assign_ride_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
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

  Future<void> assignRideApi(context, dynamic rideStatus,String rideId,
      Map<String, dynamic> bookingData) async {
    setLoading(true);
final userId = await UserViewModel().getUser();
    Map data =
    {
      "driver_id":userId,
      "ride_status":rideStatus,
      "ride_id":rideId,
    };
    debugPrint(jsonEncode(data));
    _assignRideRepo.assignRideApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        await FirebaseFirestore.instance
            .collection('order')
            .doc(rideId)
            .update({
          'accepted_driver_id': userId, // driver ki user ID
          'ride_started': true,
        });
        Utils.showSuccessMessage(context, value["message"]);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LiveRideScreen(booking : bookingData)));
        // Navigator.pushNamed(context, RoutesName.liveRide,arguments: bookingData);
      } else {
        Utils.showErrorMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
