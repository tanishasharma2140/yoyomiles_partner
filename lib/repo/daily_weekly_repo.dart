import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/daily_weekly_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class DailyWeeklyRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<DailyWeeklyModel> dailyWeeklyApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.dailyWeeklyUrl , data);
      return DailyWeeklyModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during dailyWeeklyApi : $e');
      }
      rethrow;
    }
  }
}
