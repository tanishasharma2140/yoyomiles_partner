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
        profileViewModel.profileApi();

        if (status ==1){
          FirebaseServices().saveOrUpdateDocument(driverId: userId.toString(), data: profileViewModel.profileModel!.data!.toJson());
          Navigator.pushNamed(context, RoutesName.map);
        } else if (status == 0){
          Navigator.pushNamed(context, RoutesName.register);
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
