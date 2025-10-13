import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/model/active_ride_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

import '../helper/helper/network/network_api_services.dart';

class ActiveRideRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<ActiveRideModel> activeRideApi(String driverId) async {
    String? url = "${ApiUrl.activeRideUrl}driver_id=$driverId";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return ActiveRideModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during ActiveBodyTypeUrl: $e');
      }
      rethrow;
    }
  }
}
