import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/help_topics_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class HelpTopicsRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<HelpTopicsModel> helpTopicApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.helpTopicsUrl,
      );
      return HelpTopicsModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during helpTopicApi: $e');
      }
      rethrow;
    }
  }
}
