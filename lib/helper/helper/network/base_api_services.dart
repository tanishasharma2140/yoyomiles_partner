

abstract class BaseApiServices{

  Future<dynamic> getGetApiResponse(String url);

  Future<dynamic> getPostApiResponse(String url,dynamic data);

  Future<dynamic> getPostApiResponseFormData(String url, Map<String, String> formData);

}