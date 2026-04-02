import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/update_stop_status_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';

class UpdateStopStatusViewModel with ChangeNotifier {
  final _updateStopStatusRepo = UpdateStopStatusRepo();
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> updateStopStatusApi({
    required BuildContext context,
    required String orderId,
    required String stopIndex,
  }) async {
    setLoading(true);

    final Map data = {
      "orderId": orderId,
      "stopIndex": stopIndex
    };
    print("jnhbgyujbgyhujbg");
    print(data);

    final response = await _updateStopStatusRepo.updateStopStatusApi(data);
    setLoading(false);

    if (response != null && response['status'] == 200) {
      debugPrint("Ignored Successfully..!!");
    } else {
      Utils.showErrorMessage(context,response['message']);
    }
  }


}
