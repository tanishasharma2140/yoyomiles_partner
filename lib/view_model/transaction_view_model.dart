import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/model/transaction_model.dart';
import 'package:yoyomiles_partner/repo/transaction_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class TransactionViewModel with ChangeNotifier {
  final _transactionRepo = TransactionRepo();

  TransactionsModel? _transactionsModel;
  TransactionsModel? get transactionsModel => _transactionsModel;

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setTransactionData(TransactionsModel value) {
    _transactionsModel = value;
    notifyListeners();
  }

  Future<void> transactionApi(BuildContext context) async {
    try {
      setLoading(true);

      UserViewModel userViewModel = UserViewModel();
      int? userId = await userViewModel.getUser();

      Map data = {
        "user_id": userId,
      };

      final value = await _transactionRepo.transactionApi(data);

      if (value.status == true) {
        setTransactionData(value);
      } else {
        if (kDebugMode) {
          print('API returned false: ${value.message}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in transactionApi: $error');
      }
    } finally {
      setLoading(false);
    }
  }
}
