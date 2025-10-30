import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/call_back_repo.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/register.dart';

class CallBackViewModel with ChangeNotifier {
  final _callBackRepo = CallBackRepo();
  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> callBackApi({
    required String orderID,
    required int status,
    required BuildContext context,
  }) async {
    print("callBackApi started");
    setLoading(true);

    try {
      Map<String, dynamic> data = {"order_id": orderID, "status": status};
      print("Sending data: $data");

      final response = await _callBackRepo.callBackApi(data);
      print("Raw API response: $response");

      if (response['success'] == true) {
        print("Callback success: ${response['message']}");

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Register()),
                (route) => false,
          );
        });
      } else {
        print("Callback failed: ${response['message']}");
        Utils.showErrorMessage(context, response['message'] ?? 'Callback failed');
      }
    } catch (e, st) {
      print("Error caught ❌ $e\n$st");
      Utils.showErrorMessage(context, 'An error occurred: $e');
    } finally {
      print("🔚 finally block: stopping loader");
      setLoading(false);
    }
  }



}
