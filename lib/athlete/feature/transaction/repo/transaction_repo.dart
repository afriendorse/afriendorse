import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionRepo {
  final ApiClient apiClient;
  TransactionRepo({required this.apiClient});

  Future<Response> getTransactionsList(int offset) async {
    return await apiClient.getData(
      "${AppConstants.withdrawRequestUrl}?offset=$offset&limit=${Get.find<SplashController>().configModel.content?.paginationLimit ?? 10}",
    );
  }

  Future<Response> withdrawRequest({Map<String, String>? placeBody}) async {
    return await apiClient.postData(AppConstants.withdrawRequestUrl, placeBody);
  }

  Future<Response> getWithdrawMethods() async {
    return await apiClient.getData(
      "${AppConstants.withdrawMethodRequest}?limit=50&offset=1",
    );
  }

  Future<Response> adjustTransaction() async {
    return await apiClient.getData(AppConstants.adjustTransaction);
  }
}
