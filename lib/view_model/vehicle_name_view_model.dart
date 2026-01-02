import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/model/vehicle_name_model.dart';
import 'package:yoyomiles_partner/repo/vehicle_name_repo.dart';

class VehicleNameViewModel with ChangeNotifier {
  final _vehicleNameRepo = VehicleNameRepo();
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  VehicleNameModel? _vehicleNameModel;
  VehicleNameModel? get vehicleNameModel =>_vehicleNameModel;

  setModelData(VehicleNameModel value) {
    _vehicleNameModel = value;
    notifyListeners();
  }
  Future<void> vehicleNameApi(String vehicleId) async {
    setLoading(true);
    try {
      final response = await _vehicleNameRepo.vehicleNameApi(vehicleId);
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

