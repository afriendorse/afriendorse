import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementSection extends StatelessWidget {
  const AdvertisementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return GetBuilder<DashboardController>(
          builder: (dashboardController) {
            return AthleteGlassCard(
              padding: const EdgeInsets.all(18),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AthleteDashboardColors.primary.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AthleteDashboardColors.softBg,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 74,
                        width: 74,
                        decoration: BoxDecoration(
                          color: AthleteDashboardColors.softBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Image.asset(
                            Images.dashboardAdsIcon,
                            height: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "want_to_get_highlighted".tr,
                        textAlign: TextAlign.center,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: AthleteDashboardColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "create_ads_to_get_highlighted_on_the_app_and_web_browser"
                              .tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall + 1,
                            color: AthleteDashboardColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 180,
                        child: CustomButton(
                          btnTxt: "create_ads".tr,
                          color: AthleteDashboardColors.primary,
                          onPressed: () {
                            Get.find<BusinessSubscriptionController>()
                                .openTrialEndBottomSheet()
                                .then((isTrial) {
                                  if (isTrial) {
                                    if (Get.find<UserProfileController>()
                                        .checkAvailableFeatureInSubscriptionPlan(
                                          featureType: "advertisement",
                                        )) {
                                      Get.find<AdvertisementController>()
                                          .resetAllValues();
                                      Get.to(
                                        () => const CreateAdvertisementScreen(
                                          isEditScreen: false,
                                        ),
                                      );
                                    }
                                  }
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
