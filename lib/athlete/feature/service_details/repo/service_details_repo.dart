import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceDetailsRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ServiceDetailsRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<Response> getServiceDetailsData(String serviceId) async {
    return await apiClient.getData(
      '${AppConstants.serviceDetailsUrl}/$serviceId',
    );
  }

  Future<Response> getServiceFAQData(String serviceId) async {
    return await apiClient.getData(
      "${AppConstants.serviceFaqUrl}?limit=30&offset=1&service_id=$serviceId",
    );
  }
}
