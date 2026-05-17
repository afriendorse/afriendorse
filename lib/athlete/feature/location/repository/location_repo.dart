import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class LocationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LocationRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getAddressFromGeocode(LatLng? latLng) async {
    return await apiClient.getData(
      '${AppConstants.geocodeUri}?lat=${latLng!.latitude}&lng=${latLng.longitude}',
      headers: AppConstants.configHeader,
    );
  }

  Future<Response> searchLocation(String text) async {
    return await apiClient.getData(
      '${AppConstants.searchLocationUri}?search_text=$text',
    );
  }

  Future<Response> getPlaceDetails(String placeID) async {
    return await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$placeID',
    );
  }
}
