import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/model/body_type_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

import '../helper/helper/network/network_api_services.dart';

class BodyTypeRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<BodyTypeModel> bodyTypeApi(String vehicleId) async {
    String? url = "${ApiUrl.bodyTypeUrl}vehicle_id=$vehicleId";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return BodyTypeModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during BodyTypeApi: $e');
      }
      rethrow;
    }
  }
}
