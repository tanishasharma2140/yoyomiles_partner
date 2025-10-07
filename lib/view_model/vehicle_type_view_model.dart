import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/vehicle_type_model.dart';
import 'package:yoyomiles_partner/repo/vehicle_type_repo.dart';


class VehicleTypeViewModel with ChangeNotifier {
  final _vehicleTypeRepo = VehicleTypeRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  VehicleTypeModel? _vehicleTypeModel;
  VehicleTypeModel? get vehicleTypeModel =>_vehicleTypeModel;

  setModelData(VehicleTypeModel value) {
    _vehicleTypeModel = value;
    notifyListeners();
  }
  Future<void> vehicleTypeApi() async {
    setLoading(true);
    try {
      final response = await _vehicleTypeRepo.vehicleTypeApi();
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

