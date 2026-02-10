import 'package:flutter/foundation.dart';
import 'package:yoyomiles_partner/helper/helper/network/base_api_services.dart';
import 'package:yoyomiles_partner/helper/helper/network/network_api_services.dart';
import 'package:yoyomiles_partner/model/video_model.dart';
import 'package:yoyomiles_partner/res/api_url.dart';

class VideoRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<VideoModel> videoApi() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.videoUrl,
      );
      return VideoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during contactListApi: $e');
      }
      rethrow;
    }
  }
}
