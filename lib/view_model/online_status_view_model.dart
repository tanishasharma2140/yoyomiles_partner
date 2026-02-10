import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/repo/online_status_repo.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
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

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// 🔥 SUCCESS true/false return karega
  Future<bool> onlineStatusApi(BuildContext context, int status) async {
    setLoading(true);

    try {
      final userViewModel = UserViewModel();
      final int? userId = await userViewModel.getUser();

      final data = {
        "id": userId,
        "online_status": status,
      };

      final value = await _onlineStatusRepo.onlineStatusApi(data);

      setLoading(false);

      if (value['success'] == true) {

        // ❌ dues case
        if (value["dues_status"] == 1) {
          showDueDialog(context, value["dues_message"]);
          return false;
        }

        final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);

        await profileViewModel.profileApi(context);

        if (status == 1) {
          FirebaseServices().saveOrUpdateDocument(
            driverId: userId.toString(),
            data: profileViewModel.profileModel!.data!.toJson(),
          );

          Navigator.pushNamed(context, RoutesName.tripStatus);
          return true; // ✅ SUCCESS
        }

        // offline case
        FirebaseServices().saveOrUpdateDocument(
          driverId: userId.toString(),
          data: profileViewModel.profileModel!.data!.toJson(),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.register,
              (route) => false,
        );

        return false;
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
              Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 50),

              const SizedBox(height: 14),

              TextConst(
                title:
                "Pending Dues",
                size: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),

              const SizedBox(height: 10),

              TextConst(title:
                message,
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
