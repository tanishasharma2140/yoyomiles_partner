import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/repo/online_status_repo.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/services/firebase_dao.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
class OnlineStatusViewModel with ChangeNotifier {
  final _onlineStatusRepo = OnlineStatusRepo();
  bool _loading = false;
  bool get loading => _loading;
  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> onlineStatusApi(
    context,
      int status,
  ) async {
    setLoading(true);
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());

    Map data = {
      "id": userId,
      "online_status": status,
    };

    _onlineStatusRepo.onlineStatusApi(data).then((value) async {
      setLoading(false);
      if (value['success'] == true) {
        final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);

        print("🟢 Calling profileApi()...");
        await profileViewModel.profileApi(context); // make sure profileApi() is async
        print("✅ profileApi() completed");

        // 🟢 Print the received data
        print("📦 Profile Data Received:");
        print(profileViewModel.profileModel!.data!.toJson());

        if (status ==1){
          print("✅ Status = 1 → Navigating to Map and saving driver data to Firebase...");

          print("📦 Driver ID: $userId");
          print("🧾 Driver Data (to be saved): ${profileViewModel.profileModel!.data!.toJson()}");

          FirebaseServices().saveOrUpdateDocument(
            driverId: userId.toString(),
            data: profileViewModel.profileModel!.data!.toJson(),
          );

          print("🔥 Firebase saveOrUpdateDocument() called successfully!");
          Navigator.pushNamed(context, RoutesName.tripStatus);
        } else if (status == 0){
          print("aman");
          FirebaseServices().saveOrUpdateDocument(
            driverId: userId.toString(),
            data: profileViewModel.profileModel!.data!.toJson(),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.register,
                (Route<dynamic> route) => false, // removes all previous routes
          );
          // Navigator.of(context).pop();
          // Navigator.pushReplacementNamed(context, RoutesName.register);
        }
      } else {
        Utils.showSuccessMessage(context, value["message"]);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
