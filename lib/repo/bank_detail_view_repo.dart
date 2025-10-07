import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/bank_detail_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class BankDetailViewRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<BankDetailModel> bankDetailViewApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.bankDetailViewUrl+ data);
      return BankDetailModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during BankView: $e');
      }
      rethrow;
    }
  }
}