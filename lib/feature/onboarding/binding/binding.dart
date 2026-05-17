import 'package:get/get.dart';
import 'package:afriendorse/feature/onboarding/controller/on_board_pager_controller.dart';

class OnBoardBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(() => OnBoardController());
  }
}
