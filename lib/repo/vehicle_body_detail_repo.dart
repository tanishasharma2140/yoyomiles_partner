import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/model/vehicle_body_detail_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

import '../helper/helper/network/network_api_services.dart';

class VehicleBodyDetailRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<VehicleBodyDetailModel> vehicleBodyDetailApi(String vehicleId) async {
    String? url = "${ApiUrl.vehicleBodyDetailUrl}vehicle_id=$vehicleId";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return VehicleBodyDetailModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during VehicleBodyDetailApi: $e');
      }
      rethrow;
    }
  }
}
