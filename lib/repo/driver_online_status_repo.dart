import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class DriverOnlineStatusRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> driverOnlineStatusApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.driverOnlineStatusUrl,data );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during driverOnlineStatusApi: $e');
      }
      rethrow;
    }
  }
}