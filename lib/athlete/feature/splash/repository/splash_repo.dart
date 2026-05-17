import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SplashRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  SplashRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getConfigData() async {
    Response response = await apiClient.getData(AppConstants.configUri);
    return response;
  }

  Future<bool> initSharedData() {
    if (!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if (!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(
        AppConstants.countryCode,
        AppConstants.languages[0].countryCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(
        AppConstants.languageCode,
        AppConstants.languages[0].languageCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if (!sharedPreferences.containsKey(AppConstants.initialLanguage)) {
      sharedPreferences.setBool(AppConstants.initialLanguage, true);
    }

    return Future.value(true);
  }

  void disableShowInitialLanguageScreen() {
    sharedPreferences.setBool(AppConstants.initialLanguage, false);
  }

  bool showInitialLanguageScreen() {
    return (sharedPreferences.getBool(AppConstants.initialLanguage) ?? false) &&
        (AppConstants.languages.length > 1);
  }

  Future<Response> updateLanguage() async {
    Response response = await apiClient.postData(
      AppConstants.changeLanguage,
      {},
    );
    return response;
  }
}
