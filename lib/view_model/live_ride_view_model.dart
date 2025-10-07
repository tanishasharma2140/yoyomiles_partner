import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/live_ride_model.dart';
import 'package:yoyomiles_partner/repo/live_ride_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class LiveRideViewModel with ChangeNotifier {
  final _liveRideRepo = LiveRideRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  LiveOrderModel? _liveOrderModel;
  LiveOrderModel? get liveOrderModel => _liveOrderModel;

  setModelData(LiveOrderModel value) {
    _liveOrderModel = value;
    notifyListeners();
  }
  Future<void> liveRideApi() async {
    setLoading(true);
    try {
      UserViewModel userViewModel = UserViewModel();
      int? userId = (await userViewModel.getUser());
      print(userId);
      final response = await _liveRideRepo.liveRideApi(userId.toString());
      if (response.success == true) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in liveRideApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}

