import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/auth_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class AuthViewModel with ChangeNotifier {
  final _authRepo = AuthRepository();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> loginApi(dynamic mobile, context) async {
    setLoading(true);
    Map data = {
      "phone": mobile,
    };
    _authRepo.loginApi(data).then((value) {
      setLoading(false);
      Navigator.pushNamed(context, RoutesName.otp, arguments: {
        "mobileNumber": mobile,
        "user_id": value["user_id"] ?? 0
      });
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }

  Future<void> sendOtpApi(dynamic mobile, context) async {
    setLoading(true);
    _authRepo.sendOtpApi(mobile.toString()).then((value) {
      if (value['error'] == 200) {
        Utils.showSuccessMessage(context, value['msg']);
      } else {
        Utils.showSuccessMessage(context, value['msg']);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }

  bool _otpLoading = false;
  bool get otpLoading => _otpLoading;

  setOtpLoading(bool value) {
    _otpLoading = value;
    notifyListeners();
  }

  Future<void> verifyOtpApi(
      dynamic phone, dynamic otp, dynamic userId, context) async {
    setLoading(true);
    _authRepo.verifyOtpApi(phone, otp).then((value) {
      if (value['error'] == "200") {
        if (userId != 0) {
          UserViewModel userViewModel = UserViewModel();
          userViewModel.saveUser(userId);
          Navigator.pushNamed(context, RoutesName.register);
        } else {
          Navigator.pushNamed(context, RoutesName.owner,
              arguments: {'mobileNumber': phone});
        }
      }
    }).onError((error, stackTrace) {
      setOtpLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
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
