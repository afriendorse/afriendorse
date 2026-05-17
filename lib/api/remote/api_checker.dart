import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {
    if (response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData(response: response);
      if (Get.currentRoute != RouteHelper.getInitialRoute()) {
        Get.offAllNamed(RouteHelper.getInitialRoute());
        customSnackBar("${response.statusCode}".tr);
      }
    } else if (response.statusCode == 204) {
      customSnackBar(
        'information_not_found'.tr,
        showDefaultSnackBar: showDefaultToaster,
      );
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else if (response.statusCode == 500) {
      customSnackBar(
        "${response.statusCode}".tr,
        showDefaultSnackBar: showDefaultToaster,
      );
    } else if (response.statusCode == 400 &&
        response.body != null &&
        response.body is Map &&
        response.body['errors'] != null &&
        response.body['errors'] is List &&
        response.body['errors'].isNotEmpty) {
      customSnackBar(
        "${response.body['errors'][0]['message']}",
        showDefaultSnackBar: showDefaultToaster,
      );
    } else if (response.statusCode == 429) {
      customSnackBar(
        "too_many_request".tr,
        showDefaultSnackBar: showDefaultToaster,
      );
    } else {
      // Safe message extraction - handle null, List, or Map body
      String message = 'something_went_wrong'.tr;

      if (response.body != null && response.body is Map) {
        message =
            response.body['message']?.toString() ??
            response.statusText ??
            'something_went_wrong'.tr;
      } else if (response.statusText != null) {
        message = response.statusText!;
      }

      customSnackBar(message, showDefaultSnackBar: showDefaultToaster);
    }
  }
}
