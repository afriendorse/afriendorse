import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<UserProfileController>().clearUserProfileData();
      if (Get.currentRoute != RouteHelper.getSignInRoute('splash')) {
        Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
        Get.find<AuthController>().clearSharedData();
        showCustomSnackBar(response.statusText);
      }
    } else if (response.statusCode == 500) {
      showCustomSnackBar(response.statusText);
    } else {
      if (response.body != null && response.body['message'] != null) {
        showCustomSnackBar(response.body['message']);
      } else {
        showCustomSnackBar(response.statusText);
      }
    }
  }
}
