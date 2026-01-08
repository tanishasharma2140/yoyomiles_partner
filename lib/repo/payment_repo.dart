import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/payment_gateway_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';


class PaymentRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<PaytmGatewayModel> paymentApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.paymentUrl, data);
      return PaytmGatewayModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during paymentApi: $e');
      }
      rethrow;
    }
  }
}