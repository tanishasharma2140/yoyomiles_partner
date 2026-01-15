import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/driver_ignored_ride_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class DriverIgnoredRideViewModel with ChangeNotifier {
  final _driverIgnoredRepo = DriverIgnoredRideRepo();
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> driverIgnoredRideApi({
    required BuildContext context,
    required String orderId,
  }) async {
    UserViewModel userViewModel = UserViewModel();
    int? driverId = (await userViewModel.getUser());
    setLoading(true);

    final Map data = {
      "order_id": orderId,
      "driver_id": driverId
    };
    print("jnhbgyujbgyhujbg");
    print(data);

    final response = await _driverIgnoredRepo.driverIgnoredRideApi(data);
    setLoading(false);

    if (response != null && response['status'] == 200) {
      debugPrint("Ignored Successfully..!!");
    } else {
      Utils.showErrorMessage(context,response['message']);
    }
  }


}
