import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/cancel_reason_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class CabCancelReasonRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<CancelReasonModel> cancelReasonApi(String type) async {
    String? url = "${ApiUrl.cancelReasonUrl}type=$type";
    try {
      dynamic response = await _apiServices.getGetApiResponse(url);
      return CancelReasonModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during cancelReasonApi: $e');
      }
      rethrow;
    }
  }
}

