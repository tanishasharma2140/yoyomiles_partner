import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/withdraw_history_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class WithdrawHistoryRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<WithdrawHistoryModel> dailyWeeklyApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.withdrawHistoryUrl,
        data,
      );
      return WithdrawHistoryModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during withdrawHistoryApi : $e');
      }
      rethrow;
    }
  }
}
