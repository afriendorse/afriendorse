import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestRepo {
  final ApiClient apiClient;

  BookingRequestRepo({required this.apiClient});

  Future<Response> getBookingRequestData(
    String requestType,
    int offset,
    ServiceType serviceType,
  ) async {
    return await apiClient.postData(AppConstants.bookingListUrl, {
      "limit": 10,
      "offset": offset,
      "booking_status": requestType,
      "service_type": serviceType.name,
    });
  }
}
