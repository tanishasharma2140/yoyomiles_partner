import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/driver_vehicle_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class DriverVehicleRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<DriverVehicleModel> driverVehicleApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.driverVehicleUrl,
      );
      return DriverVehicleModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during DriverVehicleApi: $e');
      }
      rethrow;
    }
  }
}
