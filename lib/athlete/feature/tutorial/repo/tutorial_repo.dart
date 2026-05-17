import 'package:afriendorse/athlete/api/api_client.dart';
import 'package:afriendorse/athlete/utils/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class TutorialRepo {
  final ApiClient apiClient;
  TutorialRepo({required this.apiClient});

  Future<Response> updateTutorial({Map<String, String>? options}) async {
    return await apiClient.postData(AppConstants.updateTutorialUrl, options);
  }
}
