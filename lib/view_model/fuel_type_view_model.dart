import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/fuel_type_model.dart';
import 'package:yoyomiles_partner/repo/fuel_type_repo.dart';

class FuelTypeViewModel with ChangeNotifier {
  final _fuelTypeRepo = FuelTypeRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  FuelTypeModel? _fuelTypeModel;
  FuelTypeModel? get fuelTypeModel => _fuelTypeModel;

  setModelData(FuelTypeModel value) {
    _fuelTypeModel = value;
    notifyListeners();
  }

  Future<void> fuelTypeApi(String vehicleId) async {
    setLoading(true);

    _fuelTypeRepo.fuelTypeApi(vehicleId).then((value) {
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
