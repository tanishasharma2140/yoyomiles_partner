import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/body_type_model.dart';
import 'package:yoyomiles_partner/repo/body_type_repo.dart';

class BodyTypeViewModel with ChangeNotifier {
  final _bodyTypeRepo = BodyTypeRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  BodyTypeModel? _bodyTypeModel;
  BodyTypeModel? get bodyTypeModel => _bodyTypeModel;

  setModelData(BodyTypeModel value) {
    _bodyTypeModel = value;
    notifyListeners();
  }

  Future<void> bodyTypeApi(String vehicleId) async {
    setLoading(true);

    _bodyTypeRepo.bodyTypeApi(vehicleId).then((value) {
      debugPrint('value:$value');
      if (value.status == 200) {
        setModelData(value);
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      if (kDebugMode) {
        print('error: $error');
      }
    });
  }
}
