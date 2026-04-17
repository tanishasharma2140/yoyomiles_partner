import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/repo/driver_transfer_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/driver_referral_history_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class DriverTransferViewModel with ChangeNotifier {
  final _driverTransferRepo = DriverTransferRepo();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> transferApi(dynamic type, BuildContext context) async {
    final userViewModel = UserViewModel();
    final driverId = await userViewModel.getUser();

    setLoading(true);

    try {
      Map data = {
        "driver_id": driverId,
        "type": type,
      };

      print("Add transfer: $data");

      final value = await _driverTransferRepo.transferApi(data);

      setLoading(false);

      final int status = value['status'] ?? 0;
      final String message = value['message'] ?? "Something went wrong";

      /// ✅ SUCCESS CASE
      if (status == 200) {
        Navigator.pop(context);

        Future.delayed(const Duration(milliseconds: 300), () {
          Utils.showSuccessMessage(context, message);
        });

        final driverRefHist =
        Provider.of<DriverReferralHistoryViewModel>(
          context,
          listen: false,
        );

        driverRefHist.driverRefHistApi(1, context);
      }

      /// ⚠️ BUSINESS ERROR (400)
      else if (status == 400) {
        Utils.showErrorMessage(context, message);
      }

      /// ❌ OTHER ERRORS
      else {
        Utils.showErrorMessage(context, "Unexpected error: $message");
      }
    } catch (e) {
      setLoading(false);

      if (kDebugMode) {
        print('error: $e');
      }

      Utils.showErrorMessage(context, "Something went wrong");
    }
  }}
