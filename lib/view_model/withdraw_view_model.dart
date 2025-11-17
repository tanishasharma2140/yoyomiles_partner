import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/repo/withdraw_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class WithdrawViewModel with ChangeNotifier {
  final _withdrawRepo = WithdrawRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> withDrawApi(dynamic amount, context) async {
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());
    setLoading(true);


    Map data = {
      "user_id": userId,
      "amount": amount,
    }
    ;
    print("Add withDraw:${data}");

    _withdrawRepo.withDrawApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        Navigator.pop(context);
        Utils.showSuccessMessage(context, value["message"]);
        final profileVm = Provider.of<ProfileViewModel>(context,listen: false);
        profileVm.profileApi(context);
      } else {
        Utils.showErrorMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
        Utils.showErrorMessage(context, "error: $error");
      }
    });
  }
}
