import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/vehicle_type_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class VehicleTypeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<VehicleTypeModel> vehicleTypeApi() async {
    try {
      dynamic response =
          await _apiServices.getGetApiResponse(ApiUrl.vehicleTypeUrl);
      return VehicleTypeModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during vehicleType: $e');
      }
      rethrow;
    }
  }
}
