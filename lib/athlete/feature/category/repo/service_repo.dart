import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceRepo {
  final ApiClient apiClient;

  ServiceRepo({required this.apiClient});

  Future<Response> getCategoryList() async {
    return await apiClient.getData(
      "${AppConstants.serviceCategoryUrl}?limit=100&offset=1",
    );
  }

  Future<Response> getSubCategoryList(String id, int offset) async {
    return await apiClient.getData(
      "${AppConstants.serviceSubcategoryUrl}?limit=10&offset=$offset&id=$id",
    );
  }

  Future<Response> getServiceListBasedOnSubcategory(
    String subCategoryId, {
    String queryText = "",
  }) async {
    return await apiClient.getData(
      "${AppConstants.serviceListBasedOnSubCategory}?limit=100&offset=1&sub_category_id=$subCategoryId&search=$queryText",
    );
  }

  Future<Response> changeSubscriptionStatus(String id) async {
    return await apiClient.postData(AppConstants.changeSubscriptionStatusUrl, {
      'sub_category_id': [id],
    });
  }
}
