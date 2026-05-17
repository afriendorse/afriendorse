import 'package:afriendorse/athlete/helper/route_helper.dart';
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showCustomDialog({
  required Widget child,
  bool barrierDismissible = false,
  useSafeArea = true,
}) {
  Future.delayed(const Duration(milliseconds: 10), () {
    Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
  });

  Get.dialog(
    child,
    barrierDismissible: barrierDismissible,
    useSafeArea: useSafeArea,
  ).then((value) {
    Get.find<UserProfileController>().trialWidgetShow(
      route: Get.currentRoute.contains(RouteHelper.businessPlan)
          ? "show-dialog"
          : "",
    );
  });
}
