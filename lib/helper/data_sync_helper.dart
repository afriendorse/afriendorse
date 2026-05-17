import 'dart:convert';
import 'package:afriendorse/api/local/cache_response.dart';
import 'package:afriendorse/common/models/api_response_model.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function()
    fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
  }) async {
    // Step 1: Try to load from the local source
    final localResponse = await fetchFromLocal();

    if (localResponse.isSuccess && localResponse.response != null) {
      try {
        final dynamic cachedData = localResponse.response!.response;
        // Handle both String (needs jsonDecode) and already decoded objects
        final decodedData = cachedData is String
            ? jsonDecode(cachedData)
            : cachedData;
        onResponse(decodedData, DataSourceEnum.local);
      } catch (e) {
        debugPrint('Error decoding local response: $e');
      }
    }

    // Step 2: Try to load from the client (remote) source and update if successful
    final clientResponse = await fetchFromClient();

    if (clientResponse.isSuccess &&
        clientResponse.response != null &&
        clientResponse.response!.statusCode == 200) {
      final dynamic clientData = clientResponse.response!.body;
      final decodedClientData = clientData is String
          ? jsonDecode(clientData)
          : clientData;

      onResponse(decodedClientData, DataSourceEnum.client);
    } else {
      // Only show error if it's not a rate limit (429) and not a cache hit scenario
      final statusCode = clientResponse.response?.statusCode;
      if (statusCode != 429 && statusCode != null) {
        // Use statusText from the Response object, or a default message
        final errorText =
            clientResponse.response?.statusText ??
            'Request failed with status $statusCode';

        // Ensure we have a valid Response object with proper body
        final responseToCheck = Response(
          statusCode: statusCode,
          statusText: errorText,
          body: clientResponse.response?.body,
        );

        ApiChecker.checkApi(responseToCheck);
      }
    }
  }
}
