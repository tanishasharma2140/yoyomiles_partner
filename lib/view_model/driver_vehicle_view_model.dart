import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/driver_vehicle_model.dart';
import 'package:yoyomiles_partner/repo/driver_vehicle_repo.dart';

class DriverVehicleViewModel with ChangeNotifier {
  final _driverVehicleRepo = DriverVehicleRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  DriverVehicleModel? _driverVehicleModel;
  DriverVehicleModel? get driverVehicleModel => _driverVehicleModel;

  setModelData(DriverVehicleModel value) {
    _driverVehicleModel = value;
    notifyListeners();
  }

  Future<void> driverVehicleApi() async {
    setLoading(true);

    _driverVehicleRepo.driverVehicleApi().then((value) {
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
