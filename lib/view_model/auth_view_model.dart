import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/auth_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/otp_page.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class AuthViewModel with ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();


  final _authRepo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  bool _sendingOtp = false;
  bool get sendingOtp => _sendingOtp;

  bool _verifyingOtp = false;
  bool get verifyingOtp => _verifyingOtp;


  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  setSendingOtp(bool value) {
    _sendingOtp = value;
    notifyListeners();
  }

  setVerifyingOtp(bool value) {
    _verifyingOtp = value;
    notifyListeners();
  }

  Future<void> loginApi(BuildContext context) async {
    if (_loading) return;
    setLoading(true);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    try {
      final Map<String, dynamic> data = {
        "phone": phoneController.text.trim(),
        "fcm": fcmToken,
      };

      final value = await _authRepo.loginApi(data);
      setLoading(false);

      if (value['success'] == true) {

        final int userId = value['user_id'];
        await UserViewModel().saveUser(userId);

        Utils.showSuccessMessage(
          context,
          value['message'] ?? 'Login successful',
        );

        Navigator.pushReplacementNamed(
          context,
          RoutesName.register,
        );
        return;
      }

      if (value['success'] == false) {

        Utils.showErrorMessage(
          context,
          value['message'] ?? 'User details required',
        );

        Navigator.pushReplacementNamed(
          context,
          RoutesName.owner,
          arguments: {
            "phone": phoneController.text.trim(),
          },
        );
        return;
      }

    } catch (error) {
      setLoading(false);

      if (kDebugMode) {
        print("Login technical error: $error");
      }

      Utils.showErrorMessage(
        context,
        "Unable to connect. Please try again.",
      );

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            error.toString(),
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      );
    }
  }



  Future<void> otpSentApi(String mobile, BuildContext context) async {
    setLoading(true);
    try {
      final value = await _authRepo.sendOtpApi(mobile.toString());

      setLoading(false);
      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context, value['msg']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(mobile: mobile),
          ),
        );
        Utils.showSuccessMessage(context, value['msg'] ?? 'OTP sent successfully');
      } else {
        Utils.showErrorMessage(context, value['msg']);
      }
    } catch (error, stackTrace) {
      setSendingOtp(false);
      if (kDebugMode) {
        print('Send OTP error: $error');
      }
    }
  }


  Future<void> verifyOtpApi(dynamic phone, dynamic otp, BuildContext context) async {
    if (_verifyingOtp) return;
    try {
      setVerifyingOtp(true);
      final value = await _authRepo.verifyOtpApi(phone, otp);
      setVerifyingOtp(false);

      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context,  value['msg'] ?? 'OTP verified');
        loginApi(context);
      } else {
        Utils.showErrorMessage(context, value['msg']);
      }
    } catch (error, stackTrace) {
      setVerifyingOtp(false);
      if (kDebugMode) {
        print('Verify OTP error: $error');
      }
    }
  }

  Future<void> otpReSentApi(String phoneNumber, BuildContext context) async {
    setLoading(true);
    try {
      final value = await _authRepo.sendOtpApi(phoneNumber);

      setLoading(false);
      if (value['error'].toString() == "200") {
        Utils.showSuccessMessage(context, value['msg'] ?? 'OTP resent successfully');
      }  else {
        Utils.showErrorMessage(value['msg'], 'Failed to resend OTP');
      }
    } catch (e) {
      setLoading(false);
      if (kDebugMode) print('otpReSentApi error: $e');
      Utils.showErrorMessage(context,'Something went wrong',);
    }
  }

  @override
  void dispose() {
    phoneController.clear();
    super.dispose();
  }

}