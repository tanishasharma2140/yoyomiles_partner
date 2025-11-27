import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/bank_detail_model.dart';
import 'package:yoyomiles_partner/repo/bank_detail_view_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class BankViewModel with ChangeNotifier {
  final _bankDetailViewRepo = BankDetailViewRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clearBankData() {
    _bankDetailModel = null;
    notifyListeners();
  }

  BankDetailModel? _bankDetailModel;
  BankDetailModel? get bankDetailModel => _bankDetailModel;

  setModelData(BankDetailModel value) {
    _bankDetailModel = value;
    notifyListeners();
  }
  Future<void> bankDetailViewApi() async {
    setLoading(true);
    try {
      UserViewModel userViewModel = UserViewModel();
      int? userId = (await userViewModel.getUser());
      print(userId);
      final response = await _bankDetailViewRepo.bankDetailViewApi(userId.toString());
      if (response.success == true) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in BankDetailViewApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}

