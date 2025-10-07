import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/live_ride_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class LiveRideRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<LiveOrderModel> liveRideApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.liveRideUrl+ data);
      return LiveOrderModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during LiveRideApi: $e');
      }
      rethrow;
    }
  }
}