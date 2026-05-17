import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ReportRepo {
  final ApiClient apiClient;
  ReportRepo({required this.apiClient});

  Future<Response> getTransactionReportData(
    int offset,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      "${AppConstants.getTransactionReportList}?limit=10&offset=$offset",
      body,
    );
  }

  Future<Response> getBusinessReportOverviewData(
    int offset,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      "${AppConstants.getBusinessOverviewList}?limit=20&offset=$offset",
      body,
    );
  }

  Future<Response> getBusinessReportEarningData(
    int offset,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      "${AppConstants.getBusinessEarningList}?limit=10&offset=$offset",
      body,
    );
  }

  Future<Response> getBusinessReportExpenseData(
    int offset,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      "${AppConstants.getBusinessExpenseList}?limit=10&offset=$offset",
      body,
    );
  }

  Future<Response> getBookingReportData(
    int offset,
    Map<String, dynamic> body,
  ) async {
    return await apiClient.postData(
      "${AppConstants.getBookingReportList}?limit=10&offset=$offset",
      body,
    );
  }
}
