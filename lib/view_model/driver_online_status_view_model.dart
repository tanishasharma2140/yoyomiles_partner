import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/repo/driver_online_status_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class DriverOnlineStatusViewModel with ChangeNotifier {
  final _driverOnlineStatusRepo = DriverOnlineStatusRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> driverOnlineStatusApi(dynamic onlineStatus, context) async {

    UserViewModel userViewModel = UserViewModel();
    int? driverId = (await userViewModel.getUser());
    setLoading(true);


    Map data = {
      "driver_id": driverId,
      "online_status": onlineStatus,
    }
    ;
    print("Add withDraw:${data}");

    _driverOnlineStatusRepo.driverOnlineStatusApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        if (context.mounted) {
          debugPrint(value["message"]);
        }
      } else {
        if (context.mounted) {
          debugPrint(value["message"]);
        }
      }
    }).onError((error, stackTrace) {
      setLoading(false);

      if (kDebugMode) {
        print('error: $error');
      }

      if (context.mounted) {
        Utils.showErrorMessage(context, "error: $error");
      }
    });
  }
}
