// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:yoyomiles_partner/repo/auth_repo.dart';
// import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
// import 'package:yoyomiles_partner/utils/utils.dart';
// import 'package:yoyomiles_partner/view_model/user_view_model.dart';
//
// class AuthViewModel with ChangeNotifier {
//   final _authRepo = AuthRepository();
//   bool _loading = false;
//   bool get loading => _loading;
//
//   setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   Future<void> loginApi(dynamic mobile, dynamic fcm, BuildContext context) async {
//     setLoading(true);
//
//     try {
//       Map<String, dynamic> data = {
//         "phone": mobile,
//         "fcm": fcm,
//       };
//
//       final value = await _authRepo.loginApi(data); // ✅ wait for API response
//       setLoading(false); // ✅ stop loader after success
//
//       // ✅ Navigate safely
//       Navigator.pushNamed(
//         context,
//         RoutesName.otp,
//         arguments: {
//           "mobileNumber": mobile,
//           "user_id": value["user_id"] ?? 0,
//         },
//       );
//     } catch (error) {
//       setLoading(false); // ✅ stop loader even on error
//
//       if (kDebugMode) print("Login error: $error");
//
//       // ✅ Show popup dialog on error
//       showGeneralDialog(
//         context: context,
//         barrierDismissible: true,
//         barrierLabel: '',
//         transitionDuration: const Duration(milliseconds: 400),
//         pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24),
//           ),
//           backgroundColor: Colors.white,
//           title: Row(
//             children: const [
//               Icon(Icons.error_outline, color: Colors.red, size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Error',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                   fontSize: 20,
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             error.toString(),
//             style: const TextStyle(fontSize: 15, height: 1.4),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.blue,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               ),
//               child: const Text(
//                 'OK',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         transitionBuilder: (context, animation, secondaryAnimation, child) {
//           return ScaleTransition(
//             scale: animation,
//             child: FadeTransition(
//               opacity: animation,
//               child: child,
//             ),
//           );
//         },
//       );
//     }
//   }
//
//
//
//   Future<void> sendOtpApi(dynamic mobile, context) async {
//     setLoading(true);
//     _authRepo.sendOtpApi(mobile.toString()).then((value) {
//       if (value['error'] == 200) {
//         Utils.showSuccessMessage(context, value['msg']);
//       } else {
//         Utils.showSuccessMessage(context, value['msg']);
//       }
//     }).onError((error, stackTrace) {
//       setLoading(false);
//       if (kDebugMode) {
//         print('error: $error');
//       }
//     });
//   }
//
//   bool _otpLoading = false;
//   bool get otpLoading => _otpLoading;
//
//   setOtpLoading(bool value) {
//     _otpLoading = value;
//     notifyListeners();
//   }
//
//   Future<void> verifyOtpApi(
//       dynamic phone, dynamic otp, dynamic userId, BuildContext context) async {
//     setOtpLoading(true);
//
//     _authRepo.verifyOtpApi(phone, otp).then((value) {
//       setOtpLoading(false);
//
//       if (value['error'] == "200") {
//         if (userId != 0) {
//           UserViewModel userViewModel = UserViewModel();
//           userViewModel.saveUser(userId);
//           Navigator.pushNamed(context, RoutesName.register);
//         } else {
//           Navigator.pushNamed(context, RoutesName.owner,
//               arguments: {'mobileNumber': phone});
//         }
//       } else {
//         Utils.showErrorMessage(context, value['message'] ?? "Something went wrong");
//       }
//     }).onError((error, stackTrace) {
//       setOtpLoading(false);
//       Utils.showErrorMessage(context, error.toString());
//       if (kDebugMode) {
//         print('error: $error');
//       }
//     });
//   }
//
//
//   // bool _regLoading = false;
//   // bool get regLoading => _regLoading;
//   //
//   // setRegLoading(bool value) {
//   //   _regLoading = value;
//   //   notifyListeners();
//   // }
//   //
//   // Future<void> registerApi(
//   //   String name,
//   //   String email,
//   //   String phone,
//   //   String vehicleNo,
//   //   String vehicleType,
//   //   String vehicleName,
//   //   String brand,
//   //   String year,
//   //   String aadhaarImage,
//   //   String panCard,
//   //   String ownerSelfie,
//   //   String drivingLicence,
//   //   String deviceId,
//   //   context,
//   // ) async {
//   //   setRegLoading(true);
//   //
//   //   Map data = {
//   //     "vehicle_no": vehicleNo,
//   //     "rc_front": rcFront,
//   //     "rc_back": rcBack,
//   //     "city_id": cityId,
//   //     "vehicle_type": vehicleType,
//   //     "vehicle_body_details_type": vehicleBodyDetailType,
//   //     "vehicle_body_type": vehicleBodyType,
//   //     "fuel_type": FuelType,
//   //     "owner_name": ownerName,
//   //     "owner_aadhaar_back": ownerAadharBack,
//   //     "owner_aadhaar_front": ,
//   //     "owner_pan_fornt": "iVBORw0KGgoAAAANSUhEUgAA...",
//   //     "owner_pan_back": "iVBORw0KGgoAAAANSUhEUgAA...",
//   //     "owner_selfie": "iVBORw0KGgoAAAANSUhEUgAA...",
//   //     "driver_name": "Suresh Yadav",
//   //     "driving_licence_back": "iVBORw0KGgoAAAANSUhEUgAA...",
//   //     "driving_licence_front": "iVBORw0KGgoAAAANSUhEUgAA...",
//   //     "phone": "9876543210",
//   //     "fcm": "fcm_token_here",
//   //     "drive_operator": 1
//   //   };
//   //   print(data);
//   //   print("hello");
//   //   _authRepo.registerApi(data).then((value) async {
//   //     setRegLoading(false);
//   //     if (value['success'] == true) {
//   //       print("hiiii ${value['user_id']}");
//   //       UserViewModel userViewModel = UserViewModel();
//   //       await userViewModel.saveUser(value['user_id']);
//   //       Navigator.pushNamed(context, RoutesName.register);
//   //     } else {
//   //       Utils.showSuccessMessage(context, value["message"]);
//   //     }
//   //   }).onError((error, stackTrace) {
//   //     setRegLoading(false);
//   //     if (kDebugMode) {
//   //       print('error: $error');
//   //     }
//   //   });
//   // }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/repo/auth_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/auth/otp_page.dart';
import 'package:yoyomiles_partner/view_model/otp_count_view_model.dart';
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
    setLoading(true);

    try {
      final Map<String, dynamic> data = {
        "phone": phoneController.text.trim(),
        "fcm": fcmToken,
      };

      final value = await _authRepo.loginApi(data);
      setLoading(false);

      /// 🟢 SUCCESS = TRUE → HOME PAGE
      if (value['success'] == true) {

        // ✅ SAVE USER ID (FIXED)
        final int userId = value['user_id'];
        await UserViewModel().saveUser(userId);

        Utils.showSuccessMessage(
          context,
          value['message'] ?? 'Login successful',
        );

        Navigator.pushReplacementNamed(
          context,
          RoutesName.register, // ✅ HOME PAGE
        );
        return;
      }

      /// 🔴 SUCCESS = FALSE → OWNER DETAIL PAGE
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
          },// ✅ OWNER DETAIL PAGE
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

      // ✅ Show popup dialog on error
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
        Provider.of<OtpCountViewModel>(context,listen: false).otpCountApi(context);
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
        Provider.of<OtpCountViewModel>(context,listen: false).otpCountApi(context);
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


// bool _regLoading = false;
// bool get regLoading => _regLoading;
//
// setRegLoading(bool value) {
//   _regLoading = value;
//   notifyListeners();
// }
//
// Future<void> registerApi(
//   String name,
//   String email,
//   String phone,
//   String vehicleNo,
//   String vehicleType,
//   String vehicleName,
//   String brand,
//   String year,
//   String aadhaarImage,
//   String panCard,
//   String ownerSelfie,
//   String drivingLicence,
//   String deviceId,
//   context,
// ) async {
//   setRegLoading(true);
//
//   Map data = {
//     "vehicle_no": vehicleNo,
//     "rc_front": rcFront,
//     "rc_back": rcBack,
//     "city_id": cityId,
//     "vehicle_type": vehicleType,
//     "vehicle_body_details_type": vehicleBodyDetailType,
//     "vehicle_body_type": vehicleBodyType,
//     "fuel_type": FuelType,
//     "owner_name": ownerName,
//     "owner_aadhaar_back": ownerAadharBack,
//     "owner_aadhaar_front": ,
//     "owner_pan_fornt": "iVBORw0KGgoAAAANSUhEUgAA...",
//     "owner_pan_back": "iVBORw0KGgoAAAANSUhEUgAA...",
//     "owner_selfie": "iVBORw0KGgoAAAANSUhEUgAA...",
//     "driver_name": "Suresh Yadav",
//     "driving_licence_back": "iVBORw0KGgoAAAANSUhEUgAA...",
//     "driving_licence_front": "iVBORw0KGgoAAAANSUhEUgAA...",
//     "phone": "9876543210",
//     "fcm": "fcm_token_here",
//     "drive_operator": 1
//   };
//   print(data);
//   print("hello");
//   _authRepo.registerApi(data).then((value) async {
//     setRegLoading(false);
//     if (value['success'] == true) {
//       print("hiiii ${value['user_id']}");
//       UserViewModel userViewModel = UserViewModel();
//       await userViewModel.saveUser(value['user_id']);
//       Navigator.pushNamed(context, RoutesName.register);
//     } else {
//       Utils.showSuccessMessage(context, value["message"]);
//     }
//   }).onError((error, stackTrace) {
//     setRegLoading(false);
//     if (kDebugMode) {
//       print('error: $error');
//     }
//   });
// }
}