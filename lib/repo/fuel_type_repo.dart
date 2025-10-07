import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/model/fuel_type_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';
import '../helper/helper/network/network_api_services.dart';

class FuelTypeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<FuelTypeModel> fuelTypeApi(String vehicleId) async {
    String? url = "${ApiUrl.fuelTypeUrl}vehicle_id=$vehicleId";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return FuelTypeModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during FuelTypeApi: $e');
      }
      rethrow;
    }
  }
}
