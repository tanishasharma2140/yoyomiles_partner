import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/daily_weekly_model.dart';
import 'package:yoyomiles_partner/repo/daily_weekly_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class DailyWeeklyViewModel with ChangeNotifier {
  final _dailyWeeklyRepo = DailyWeeklyRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  DailyWeeklyModel? _dailyWeeklyModel;
  DailyWeeklyModel? get dailyWeeklyModel => _dailyWeeklyModel;

  void setProfileData(DailyWeeklyModel value) {
    _dailyWeeklyModel = value;
    notifyListeners();
  }

  Future<void> dailyWeeklyApi(dynamic type, context) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    int? driverId = (await userViewModel.getUser());
    Map data = {"driver_id": driverId,
      "type": type // type = 1 daily, type = 2 weekly
    };

    _dailyWeeklyRepo
        .dailyWeeklyApi(data)
        .then((value) {
          setLoading(false); // ✅ Stop loader
          if (value.status == 200) {
            setProfileData(value);
          } else {
            if (kDebugMode) {
              print('value: ${value.message}');
            }
          }
        })
        .onError((error, stackTrace) {
          setLoading(false); // ✅ Stop loader on error
          if (kDebugMode) {
            print('error: $error');
          }
        });
  }
}
