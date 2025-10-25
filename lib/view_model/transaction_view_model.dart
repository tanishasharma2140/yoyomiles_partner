import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/transaction_model.dart';
import 'package:yoyomiles_partner/repo/transaction_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class TransactionViewModel with ChangeNotifier {
  final _transactionRepo = TransactionRepo();


  TransactionsModel? _transactionsModel;
  TransactionsModel? get transactionsModel => _transactionsModel;

  void setProfileData(TransactionsModel value){
    _transactionsModel = value;
    notifyListeners();
  }

  Future<void> transactionApi(context) async {

    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());

    Map data = {
      "user_id":userId
    };
    _transactionRepo.transactionApi(data).then((value) {
      if (value.status == true) {
        setProfileData(value);
      } else {
        if (kDebugMode) {
          print('value: ${value.message}');
        }
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
