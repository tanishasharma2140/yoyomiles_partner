import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/profile_model.dart';
import 'package:yoyomiles_partner/repo/profile_repo.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class ProfileViewModel with ChangeNotifier {
  final _profileRepo = ProfileRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  setModelData(ProfileModel value) {
    _profileModel = value;
    notifyListeners();
  }
  Future<void> profileApi(context) async {
    print("kjfnnfneofoefionieo");
    setLoading(true);
    try {
      UserViewModel userViewModel = UserViewModel();
      int? userId = (await userViewModel.getUser());
      print(userId);
      final response = await _profileRepo.profileApi(userId.toString());
      if (response.success == true) {
        setModelData(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in profileApi: $e');
      }
    } finally {
      setLoading(false);
    }
  }
}

