import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/delete_old_order_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class DeleteOldOrderRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<DeleteOldOrderModel> deleteOldOrderApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.deleteOldOrderUrl,
      );
      return DeleteOldOrderModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during contactListApi: $e');
      }
      rethrow;
    }
  }
}
