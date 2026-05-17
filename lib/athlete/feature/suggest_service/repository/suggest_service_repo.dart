import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SuggestServiceRepo {
  final ApiClient apiClient;
  SuggestServiceRepo({required this.apiClient});

  Future<Response> getCategoryList() async {
    return await apiClient.getData(
      "${AppConstants.serviceCategoryUrl}?limit=100&offset=1",
    );
  }

  Future<Response> submitNewServiceRequest(Map<String, String> body) async {
    return await apiClient.postData(AppConstants.submitNewServiceRequest, body);
  }

  Future<Response> getSuggestedServiceList(int offset) async {
    return await apiClient.getData(
      '${AppConstants.getSuggestedServiceList}?limit=50&offset=$offset&status=all',
    );
  }
}
