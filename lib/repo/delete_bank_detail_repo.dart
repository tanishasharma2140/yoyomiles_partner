import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class DeleteBankDetailRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> deleteBankDetailApi(String userId) async {
    try {
      // API call
      dynamic response = await _apiServices.getGetApiResponse(
        "${ApiUrl.deleteBankDetailUrl}$userId",
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during deleteBankDetailApi: $e');
      }
      rethrow;
    }
  }
}
