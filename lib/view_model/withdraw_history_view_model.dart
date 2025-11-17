import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/withdraw_history_model.dart';
import 'package:yoyomiles_partner/repo/withdraw_history_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class WithdrawHistoryViewModel with ChangeNotifier {
  final _withdrawHistoryRepo = WithdrawHistoryRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  WithdrawHistoryModel? _withdrawHistoryModel;
  WithdrawHistoryModel? get withdrawHistoryModel => _withdrawHistoryModel;

  void setWithdrawData(WithdrawHistoryModel value) {
    _withdrawHistoryModel = value;
    notifyListeners();
  }

  Future<void> withDrawHistoryApi(dynamic status, context) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());
    Map data = {"user_id": userId,
      "status": status // type = 1 daily, type = 2 weekly
    };

    _withdrawHistoryRepo
        .dailyWeeklyApi(data)
        .then((value) {
      setLoading(false); // ✅ Stop loader
      if (value.success == true) {
        setWithdrawData(value);
      } else {
        if (kDebugMode) {
          Utils.showErrorMessage(context, "$value.message");
          print('value: ${value.message}');
        }
      }
    })
        .onError((error, stackTrace) {
      setLoading(false); // ✅ Stop loader on error
      if (kDebugMode) {
        print('error: $error');
        Utils.showErrorMessage(context, "error: $error");
      }
    });
  }
}
