import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/cities_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';
import '../helper/helper/network/base_api_services.dart';

class CitiesRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<CitiesModel> citiesApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.citiesUrl,
      );
      return CitiesModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during CitiesApi: $e');
      }
      rethrow;
    }
  }
}
