import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/policy_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class PolicyRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<PolicyModel> policyApi(dynamic data) async {
    try {
      dynamic response =
      await _apiServices.getGetApiResponse(ApiUrl.policyUrl+ data);
      return PolicyModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during policyApi: $e');
      }
      rethrow;
    }
  }
}