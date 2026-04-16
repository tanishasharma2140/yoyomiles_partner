import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/driver_transaction_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class DriverReferralHistoryRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<DriverTransactionModel> driverRefHistApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.driverReferralHistoryUrl,
        data,
      );
      return DriverTransactionModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during DriverReferralHistoryApi : $e');
      }
      rethrow;
    }
  }
}
