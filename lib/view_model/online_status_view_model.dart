// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:yoyomiles_partner/repo/online_status_repo.dart';
// import 'package:yoyomiles_partner/res/app_fonts.dart';
// import 'package:yoyomiles_partner/res/constant_color.dart';
// import 'package:yoyomiles_partner/res/text_const.dart';
// import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
// import 'package:yoyomiles_partner/utils/utils.dart';
// import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
// import 'package:provider/provider.dart';
// import 'package:yoyomiles_partner/view_model/services/firebase_dao.dart';
// import 'package:yoyomiles_partner/view_model/user_view_model.dart';
//
// class OnlineStatusViewModel with ChangeNotifier {
//   final _onlineStatusRepo = OnlineStatusRepo();
//
//   bool _loading = false;
//   bool get loading => _loading;
//
//   void setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   /// 🔥 SUCCESS true/false return karega
//   Future<bool> onlineStatusApi(BuildContext context, int status) async {
//     setLoading(true);
//
//     try {
//       final userViewModel = UserViewModel();
//       final int? userId = await userViewModel.getUser();
//
//       final data = {"id": userId, "online_status": status};
//
//       final value = await _onlineStatusRepo.onlineStatusApi(data);
//
//       setLoading(false);
//
//       if (value['success'] == true) {
//         // ❌ dues case
//         if (value["dues_status"] == 1) {
//           showDueDialog(context, value["dues_message"]);
//           return false;
//         }
//
//         final profileViewModel = Provider.of<ProfileViewModel>(
//           context,
//           listen: false,
//         );
//
//         await profileViewModel.profileApi(context);
//         if (status == 1) {
//           FirebaseServices().saveOrUpdateDocument(
//             driverId: userId.toString(),
//             data: profileViewModel.profileModel!.data!.toJson(),
//           );
//
//           Navigator.pushNamed(context, RoutesName.tripStatus);
//           return true; // ✅ SUCCESS
//         } else {
//           // offline case
//           FirebaseServices().saveOrUpdateDocument(
//             driverId: userId.toString(),
//             data: profileViewModel.profileModel!.data!.toJson(),
//           );
//
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             RoutesName.register,
//             (route) => false,
//           );
//
//           return false;
//         }
//       } else {
//         Utils.showSuccessMessage(context, value["message"]);
//         return false;
//       }
//     } catch (e) {
//       setLoading(false);
//       if (kDebugMode) {
//         print("❌ onlineStatusApi error: $e");
//       }
//       return false;
//     }
//   }
// }
//
// void showDueDialog(BuildContext context, String message) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) {
//       return Dialog(
//         backgroundColor: PortColor.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.redAccent,
//                 size: 50,
//               ),
//
//               const SizedBox(height: 14),
//
//               TextConst(
//                 title: "Pending Dues",
//                 size: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//
//               const SizedBox(height: 10),
//
//               TextConst(
//                 title: message,
//                 textAlign: TextAlign.center,
//                 size: 13,
//                 color: Colors.black54,
//               ),
//
//               const SizedBox(height: 22),
//
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: PortColor.gold,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text(
//                     "OK",
//                     style: TextStyle(
//                       color: PortColor.black,
//                       fontSize: 16,
//                       fontFamily: AppFonts.kanitReg,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yoyomiles_partner/repo/online_status_repo.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/ride_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

// ❌ REMOVED: firebase_dao import

class OnlineStatusViewModel with ChangeNotifier {
  final _onlineStatusRepo = OnlineStatusRepo();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  StreamSubscription<Position>? _positionStream;

  Future<bool> onlineStatusApi(BuildContext context, int status) async {
    setLoading(true);

    try {
      final userViewModel = UserViewModel();
      final int? userId = await userViewModel.getUser();

      final data = {"id": userId, "online_status": status};

      final value = await _onlineStatusRepo.onlineStatusApi(data);

      setLoading(false);

      if (value['success'] == true) {
        // dues case
        if (value["dues_status"] == 1) {
          showDueDialog(context, value["dues_message"]);
          return false;
        }

        final profileViewModel = Provider.of<ProfileViewModel>(
          context,
          listen: false,
        );

        await profileViewModel.profileApi(context);

        if (status == 1) {
          await _joinDriverWithProfile(
            context,
            userId.toString(),
            profileViewModel,
          );

          Navigator.pushNamed(context, RoutesName.tripStatus);
          return true;

        } else {
          // offline case
          // ❌ REMOVED: FirebaseServices().saveOrUpdateDocument()
          // ✅ Socket se driver disconnect karo
          final rideViewModel = Provider.of<RideViewModel>(
            context,
            listen: false,
          );
          rideViewModel.disconnect();

          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.register,
                (route) => false,
          );

          return false;
        }
      } else {
        Utils.showSuccessMessage(context, value["message"]);
        return false;
      }
    } catch (e) {
      setLoading(false);
      if (kDebugMode) {
        print("❌ onlineStatusApi error: $e");
      }
      return false;
    }
  }

  Future<void> _joinDriverWithProfile(
      BuildContext context,
      String driverId,
      ProfileViewModel profileViewModel,
      ) async {
    try {
      final rideViewModel = Provider.of<RideViewModel>(context, listen: false);
      final profileData = profileViewModel.profileModel?.data;

      final Map<String, dynamic> driverPayload = {
        'driverId': driverId,
        'driver_name': profileData?.driverName ?? '',
        'phone': profileData?.phone?.toString() ?? '',
        'vehicle_no': profileData?.vehicleNo ?? '',
        'vehicle_type': profileData?.vehicleType?.toString() ?? '',
        'owner_selfie': profileData?.ownerSelfie ?? '',
        'online_status': 1,
      };

      print("📤 Emitting JOIN_DRIVER with profile: $driverPayload");

      rideViewModel.joinDriverWithProfile(driverPayload);

      /// Start live location tracking
      _startLocationTracking(driverId, rideViewModel);

    } catch (e) {
      print("❌ _joinDriverWithProfile error: $e");
    }
  }
  void _startLocationTracking(String driverId, RideViewModel rideViewModel) {

    print("🛰 Starting live location tracking...");

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // 👈 20 meter move hone par update
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {

          print("📍 New GPS location received");
          print("Latitude: ${position.latitude}");
          print("Longitude: ${position.longitude}");

          print("📤 Sending updated location to socket...");

          rideViewModel.updateDriverLocation(
            driverId,
            position.latitude,
            position.longitude,
          );

          print("✅ Location updated on server");

        });
  }

}

void showDueDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: PortColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 50),
              const SizedBox(height: 14),
              TextConst(
                title: "Pending Dues",
                size: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              const SizedBox(height: 10),
              TextConst(
                title: message,
                textAlign: TextAlign.center,
                size: 13,
                color: Colors.black54,
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PortColor.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: PortColor.black,
                      fontSize: 16,
                      fontFamily: AppFonts.kanitReg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}