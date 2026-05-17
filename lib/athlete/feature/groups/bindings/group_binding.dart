// lib/athlete/feature/groups/bindings/group_binding.dart

import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_payment_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupPaymentController>(() => GroupPaymentController());
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
