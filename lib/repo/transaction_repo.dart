import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/transaction_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

import '../helper/helper/network/base_api_services.dart';

class TransactionRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<TransactionsModel> transactionApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getPostApiResponse(ApiUrl.transactionUrl , data);
      return TransactionsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during profileApi: $e');
      }
      rethrow;
    }
  }
}
