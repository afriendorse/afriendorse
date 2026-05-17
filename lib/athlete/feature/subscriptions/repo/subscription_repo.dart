import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SubscriptionRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SubscriptionRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getSubscriptionTransactionList(int offset) async {
    return await apiClient.getData(
      '${AppConstants.subscriptionTransactionListUri}?limit=10&offset=$offset',
    );
  }

  Future<Response> getSearchedSubscriptionTransactionList({
    String? queryText,
    String? startDate,
    String? endDate,
  }) async {
    return await apiClient.getData(
      '${AppConstants.subscriptionTransactionListUri}?limit=50&offset=1&search=$queryText&start_date=$startDate&end_date=$endDate',
    );
  }

  Future<Response> getSubcategorySubscriptionList(
    int offset, {
    String? categoryId,
  }) async {
    return await apiClient.getData(
      "${AppConstants.subscriptionListUrl}?limit=${Get.find<SplashController>().configModel.content?.paginationLimit}&offset=$offset&category_id=${categoryId ?? ""}",
    );
  }

  Future<Response> getSubscriptionPackageList() async {
    return await apiClient.getData(AppConstants.packageSubscriptionUri);
  }

  Future<Response> getSubscriptionDetails() async {
    return await apiClient.getData(AppConstants.subscriptionDetailsUri);
  }

  Future<Response> cancelSubscription({required String packageId}) async {
    return await apiClient.postData(
      "${AppConstants.changeSubscriptionStatus}cancel",
      {"package_id": packageId},
    );
  }

  Future<Response> renewOrShiftSubscription(
    Map<String, String> body, {
    required String packageStatus,
  }) async {
    return await apiClient.postData(
      "${AppConstants.changeSubscriptionStatus}$packageStatus",
      body,
    );
  }

  Future<Response> changeSubscriptionStatus(String id) async {
    return await apiClient.postData(AppConstants.changeSubscriptionStatusUrl, {
      'sub_category_id': [id],
    });
  }
}
