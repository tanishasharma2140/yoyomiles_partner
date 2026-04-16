import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/driver_transaction_model.dart';
import 'package:yoyomiles_partner/repo/driver_referral_history_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class DriverReferralHistoryViewModel with ChangeNotifier {
  final _driverReferralHistoryRepo = DriverReferralHistoryRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  DriverTransactionModel? _driverTransactionModel;
  DriverTransactionModel? get driverTransactionModel => _driverTransactionModel;

  void setDriverRefHistoryData(DriverTransactionModel value) {
    _driverTransactionModel = value;
    notifyListeners();
  }

  Future<void> driverRefHistApi(dynamic type ,context) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());
    Map data = {"driver_id": userId,
    "type" : type,
    };

    _driverReferralHistoryRepo
        .driverRefHistApi(data)
        .then((value) {
          setLoading(false); // ✅ Stop loader
          if (value.status == 200) {
            setDriverRefHistoryData(value);
          } else {
            if (kDebugMode) {
              Utils.showErrorMessage(context, "$value.message");
              print('value: ${value.message}');
            }
          }
        })
        .onError((error, stackTrace) {
          setLoading(false);
          if (kDebugMode) {
            print('error: $error');
            Utils.showErrorMessage(context, "error: $error");
          }
        });
  }
}
