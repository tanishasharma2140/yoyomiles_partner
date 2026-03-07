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
          // ❌ REMOVED: FirebaseServices().saveOrUpdateDocument()
          // ✅ Socket se JOIN_DRIVER emit karo profile data ke saath
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

  // ✅ JOIN_DRIVER — profile data ke saath emit karo
  Future<void> _joinDriverWithProfile(
      BuildContext context,
      String driverId,
      ProfileViewModel profileViewModel,
      ) async {
    try {
      final rideViewModel = Provider.of<RideViewModel>(
        context,
        listen: false,
      );

      final profileData = profileViewModel.profileModel?.data;

      // ── Profile data map banao — Firebase mein jo save hota tha
      final Map<String, dynamic> driverPayload = {
        'driverId': driverId,
        'driver_name': profileData?.driverName ?? '',
        'phone': profileData?.phone?.toString() ?? '',
        'vehicle_no': profileData?.vehicleNo ?? '',
        'vehicle_type': profileData?.vehicleType?.toString() ?? '',
        // 'vehicle_name': profileData?.vehicleName ?? '',
        'owner_selfie': profileData?.ownerSelfie ?? '',
        'online_status': 1,
      };

      print("📤 Emitting JOIN_DRIVER with profile: $driverPayload");

      // ✅ RideViewModel ke socket se emit karo
      rideViewModel.joinDriverWithProfile(driverPayload);

      // ── Location bhi saath update karo (20m check)
      await _checkAndUpdateLocationIfNeeded(
        context,
        driverId,
        profileViewModel,
        rideViewModel,
      );

    } catch (e) {
      print("❌ _joinDriverWithProfile error: $e");
    }
  }

  // ✅ Profile location vs GPS — 20m se zyada ho toh socket update
// ✅ Profile location vs GPS — 20m se zyada ho toh socket update
  Future<void> _checkAndUpdateLocationIfNeeded(
      BuildContext context,
      String driverId,
      ProfileViewModel profileViewModel,
      RideViewModel rideViewModel,
      ) async {
    try {
      final profileData = profileViewModel.profileModel?.data;

      // ── toJson() se direct key access karo — getter naam ki zarurat nahi
      final profileJson = profileData?.toJson();

      final profileLat = double.tryParse(
        profileJson?['current_latitude']?.toString() ?? '',
      );
      final profileLng = double.tryParse(
        profileJson?['current_longitude']?.toString() ?? '',
      );

      print("📍 Profile location: lat=$profileLat, lng=$profileLng");

      if (profileLat == null || profileLng == null) {
        print("⚠️ Profile location null — skipping distance check");
        return;
      }

      final Position currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("📱 Current GPS: lat=${currentPos.latitude}, lng=${currentPos.longitude}");

      final double distanceInMeters = Geolocator.distanceBetween(
        profileLat,
        profileLng,
        currentPos.latitude,
        currentPos.longitude,
      );

      print("📏 Distance: ${distanceInMeters.toStringAsFixed(1)}m");

      if (distanceInMeters > 20) {
        print("✅ > 20m — Socket location update");
        rideViewModel.updateDriverLocation(
          driverId,
          currentPos.latitude,
          currentPos.longitude,
        );
      } else {
        print("ℹ️ <= 20m — No update needed");
      }
    } catch (e) {
      print("❌ _checkAndUpdateLocationIfNeeded error: $e");
    }
  }
}

// ── Dialog same as before ────────────────────────────────────────
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