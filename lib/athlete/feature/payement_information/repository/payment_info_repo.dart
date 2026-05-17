import 'package:afriendorse/athlete/api/api_client.dart';
import 'package:afriendorse/athlete/utils/app_constants.dart';
import 'package:get/get.dart';

class PaymentInfoRepo {
  final ApiClient apiClient;

  PaymentInfoRepo({required this.apiClient});

  Future<Response> getPaymentMethods() async {
    return await apiClient.getData(AppConstants.getPaymentMethodList);
  }

  Future<Response> storePaymentInfo(
    Map<String, dynamic> paymentMethodBody,
  ) async {
    final response = await apiClient.postData(
      AppConstants.storePaymentMethod,
      paymentMethodBody,
    );
    return response;
  }

  Future<Response> updatePaymentInfo(
    Map<String, dynamic> paymentMethodBody,
    String? id,
  ) async {
    final response = await apiClient.postData(
      '${AppConstants.updatePaymentMethod}/$id',
      paymentMethodBody,
    );
    return response;
  }

  Future<Response> statusUpdatePaymentMethod(String? id) async {
    final response = await apiClient.getData(
      '${AppConstants.statusUpdatePaymentMethod}/$id',
    );
    return response;
  }

  Future<Response> markPaymentMethodAsDefault(String? id) async {
    final response = await apiClient.getData(
      '${AppConstants.markAsDefaultPaymentMethod}/$id',
    );
    return response;
  }

  Future<Response> deletePaymentMethod(String? id) async {
    final response = await apiClient.deleteData(
      '${AppConstants.deletePaymentMethod}/$id',
    );
    return response;
  }
}
