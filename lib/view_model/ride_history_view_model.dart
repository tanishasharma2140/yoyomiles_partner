import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/ride_history_model.dart';
import 'package:yoyomiles_partner/repo/ride_history_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class RideHistoryViewModel with ChangeNotifier {
  final _rideHistoryRepo= RideHistoryRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  RideHistoryModel? _rideHistoryModel;
  RideHistoryModel? get rideHistoryModel => _rideHistoryModel;

  setModelData(RideHistoryModel value) {
    _rideHistoryModel = value;
    notifyListeners();
  }
  Future<void> rideHistoryApi() async {
    print("objective");
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    int? userId = await userViewModel.getUser();
    _rideHistoryRepo.rideHistoryApi(userId).then((value){
      print("hlooooo");
      print(userId);
      print('value:$value');
      if (value.success == true) {
        setModelData(value);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}

