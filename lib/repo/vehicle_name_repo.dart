import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/vehicle_name_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class VehicleNameRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<VehicleNameModel> vehicleNameApi(data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.vehicleNameUrl +data);
      return VehicleNameModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during vehicleName: $e');
      }
      rethrow;
    }
  }
}
