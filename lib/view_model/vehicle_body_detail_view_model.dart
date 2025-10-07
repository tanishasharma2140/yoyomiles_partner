import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/vehicle_body_detail_model.dart';
import 'package:yoyomiles_partner/repo/vehicle_body_detail_repo.dart';

class VehicleBodyDetailViewModel with ChangeNotifier {
  final _vehicleBodyDetailRepo = VehicleBodyDetailRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  VehicleBodyDetailModel? _vehicleBodyDetailModel;
  VehicleBodyDetailModel? get vehicleBodyDetailModel => _vehicleBodyDetailModel;

  setModelData(VehicleBodyDetailModel value) {
    _vehicleBodyDetailModel = value;
    notifyListeners();
  }

  Future<void> vehicleBodyDetailApi(String vehicleId) async {
    setLoading(true);

    _vehicleBodyDetailRepo.vehicleBodyDetailApi(vehicleId).then((value) {
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
