import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/repo/delete_bank_detail_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/bank_view_model.dart';

class DeleteBankDetailViewModel with ChangeNotifier {
  final _deleteBankDetailRepo = DeleteBankDetailRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }



  Future<void> deleteBankDetailApi(String userId, BuildContext context) async {
    setLoading(true);
    try {
      final value = await _deleteBankDetailRepo.deleteBankDetailApi(userId);
      debugPrint('Response: $value');

      if (value['success'] == true) {
        Utils.showSuccessMessage(context, "Deleted Successfully!!");

        final bankViewModel = Provider.of<BankViewModel>(context, listen: false);
        bankViewModel.clearBankData();

        await bankViewModel.bankDetailViewApi();

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(value['message'] ?? 'Bank details not found')),
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong! Please try again.')),
      );
    } finally {
      setLoading(false);
    }
  }
}
