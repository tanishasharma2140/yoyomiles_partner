import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/repo/bank_detail_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/bank_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class BankDetailViewModel with ChangeNotifier {
  final _bankDetailRepo = BankDetailRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> bankDetailApi(dynamic accountNumber,dynamic bankName, dynamic reEnterNumber,
      dynamic name, dynamic ifscCode, context) async {
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());
    setLoading(true);


    Map data = {
      "driver_id": userId,
      "bank_name": bankName,
      "account_number": accountNumber,
      "re_account_number": reEnterNumber,
      "account_holder_name": name,
      "ifsc_code": ifscCode,
    };
    print("Add bank:${data}");

    _bankDetailRepo.bankDetailApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        final bankViewModel = Provider.of<BankViewModel>(context, listen: false);
        bankViewModel.bankDetailViewApi();
        Utils.showSuccessMessage(context, "Added Successful");
        Navigator.pushNamed(context, RoutesName.bankDetail);
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
