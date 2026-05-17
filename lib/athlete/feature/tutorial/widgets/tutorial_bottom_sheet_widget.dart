import 'package:afriendorse/athlete/feature/language/controller/localization_controller.dart';
import 'package:afriendorse/athlete/feature/nav/bottom_nav_screen.dart';
import 'package:afriendorse/athlete/feature/payement_information/view/payment_information_screen.dart';
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:afriendorse/athlete/feature/settings/business/view/business_settings_screen.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_item_widget.dart'
    show TutorialItemWidget;
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_progressbar_widget.dart'
    show TutorialProgressbarWidget;
import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:afriendorse/athlete/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TutorialBottomSheetWidget extends StatelessWidget {
  const TutorialBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(Dimensions.radiusLarge),
          topLeft: const Radius.circular(Dimensions.radiusLarge),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: GetBuilder<UserProfileController>(
        builder: (profileController) {
          final double completionPercentage = _getPercentage(
            profileController.providerModel?.content?.providerInfo,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radiusLarge),
                    topLeft: Radius.circular(Dimensions.radiusLarge),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'setup_and_take_bookings'.tr,
                              style: robotoBold.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Text(
                              'set_up_and_start_managing'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.headlineLarge?.color,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      TutorialProgressbarWidget(
                        progress: completionPercentage / 100,
                      ),
                    ],
                  ),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: profileController
                        .providerModel
                        ?.content
                        ?.providerInfo
                        ?.tutorialData
                        ?.length,
                    itemBuilder: (context, index) {
                      String? key = profileController
                          .providerModel
                          ?.content
                          ?.providerInfo
                          ?.tutorialData
                          ?.keys
                          .elementAt(index);
                      bool isCompleted =
                          profileController
                              .providerModel
                              ?.content
                              ?.providerInfo
                              ?.tutorialData?[key]
                              ?.contains('1') ??
                          false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall,
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: TutorialItemWidget(
                          keyName: key,
                          isActive: isCompleted,
                          onTap: () => onNavigation(key, isCompleted),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Align(
                  alignment: isLtr
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: InkWell(
                    onTap: () {
                      final MapEntry<String, String>? data =
                          (profileController
                                      .providerModel
                                      ?.content
                                      ?.providerInfo
                                      ?.tutorialData
                                      ?.entries ??
                                  [])
                              .where((entry) => entry.value.contains('0'))
                              .cast<MapEntry<String, String>?>()
                              .firstOrNull;

                      if (data != null) {
                        onNavigation(data.key, false);
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'lets_start'.tr,
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: Dimensions.paddingSizeDefault,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          );
        },
      ),
    );
  }

  void onNavigation(String? keyName, bool isActive) {
    Get.back();

    if (keyName == 'business_information') {
      if (Get.currentRoute == '/BusinessSettingScreen') {
        Get.back();
      }
      Get.to(() => BusinessSettingScreen());
    } else if (keyName == 'service_availability') {
      if (Get.currentRoute == '/BusinessSettingScreen') {
        Get.back();
      }
      Get.to(() => BusinessSettingScreen(tabIndex: 1));
    } else if (keyName == 'service_subscription') {
      Get.offAll(() => BottomNavScreen(formTutorial: true, pageIndex: 2));
    } else if (keyName == 'payment_information') {
      Get.to(() => PaymentInformationScreen());
    }

    if (!isActive) {
      Get.find<TutorialController>().updateTutorial(key: keyName!);
    }
  }

  double _getPercentage(ProviderInfo? providerInfo) =>
      ((providerInfo?.tutorialData?.values
                  .where((v) => v.contains('1'))
                  .length ??
              0) /
          (providerInfo?.tutorialData?.length ?? 0)) *
      100;
}
