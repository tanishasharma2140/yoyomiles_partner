import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/cash_free_gateway_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';


class PaymentRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<CashFreeGatewayModel> paymentApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.paymentUrl, data);
      return CashFreeGatewayModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during paymentApi: $e');
      }
      rethrow;
    }
  }
}