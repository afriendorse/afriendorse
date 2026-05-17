import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart';
import 'package:afriendorse/athlete/feature/tutorial/repo/tutorial_repo.dart';
import 'package:get/get.dart';

class TutorialController extends GetxController implements GetxService {
  final TutorialRepo tutorialRepo;
  TutorialController({required this.tutorialRepo});

  bool _isVisible = true;
  bool get isVisible => _isVisible;

  bool _isBottomSheetOpen = false;

  bool get isBottomSheetOpen => _isBottomSheetOpen;

  void setVisibility(bool isVisible) {
    _isVisible = isVisible;
    update();
  }

  void onChangeBottomSheetStatus(bool status, {bool isUpdate = true}) {
    _isBottomSheetOpen = status;

    if (isUpdate) {
      update();
    }
  }

  Future<void> updateTutorial({required String key}) async {
    final options = Get.find<UserProfileController>()
        .providerModel
        ?.content
        ?.providerInfo
        ?.tutorialData;
    options?[key] = '1';

    Response response = await tutorialRepo.updateTutorial(options: options);

    if (response.statusCode == 200 &&
        response.body["response_code"] == 'default_update_200') {
      await Get.find<UserProfileController>().getProviderInfo(reload: true);
    }
  }
}
