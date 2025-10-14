import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/repo/online_status_repo.dart';
import 'package:yoyomiles_partner/repo/update_ride_status_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

import 'live_ride_view_model.dart';

class UpdateRideStatusViewModel with ChangeNotifier {
  final _updateRideStatusRepo = UpdateRideStatusRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> updateRideApi(context, String id, String rideStatus) async {
    setLoading(true);

    Map data = {"id": id, "ride_status": rideStatus};

    _updateRideStatusRepo.updateRideApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.register,
              (route) => false,
        );
        Utils.showSuccessMessage(context, "Ride status updated successfully!");
      } else {
        Utils.showSuccessMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
