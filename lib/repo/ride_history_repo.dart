import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/ride_history_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class RideHistoryRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<RideHistoryModel> rideHistoryApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.rideHistoryUrl+ data.toString());
      return RideHistoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during rideApi: $e');
      }
      rethrow;
    }
  }
}