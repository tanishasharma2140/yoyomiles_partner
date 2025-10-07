import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/repo/assign_ride_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
class AssignRideViewModel with ChangeNotifier {
  final _assignRideRepo = AssignRideRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> assignRideApi(context, dynamic rideStatus,String rideId) async {
    setLoading(true);
final userId = await UserViewModel().getUser();
    Map data =
    {
      "driver_id":userId,
      "ride_status":rideStatus,
      "ride_id":rideId,
    };
    print(jsonEncode(data));
    _assignRideRepo.assignRideApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        Utils.showSuccessMessage(context, value["message"]);
        Navigator.pushNamed(context, RoutesName.liveRide);
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
