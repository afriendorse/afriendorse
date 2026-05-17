import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CommissionInfoWidget extends StatelessWidget {
  const CommissionInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        int? commissionStatus = userProfileController
            .providerModel
            ?.content
            ?.providerInfo
            ?.commissionStatus;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      Get.find<UserProfileController>().getProviderInfo(
                        reload: true,
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "commission_base".tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${commissionStatus == 1 ? userProfileController.providerModel?.content?.providerInfo?.commissionPercentage ?? "" : Get.find<SplashController>().configModel.content?.defaultCommission ?? ""} %  ",
                                  style: robotoBold.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                ),
                                TextSpan(
                                  text: 'commission_per_booking_order'.tr,
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            "${'provider_will_pay'.tr} ${commissionStatus == 1 ? userProfileController.providerModel?.content?.providerInfo?.commissionPercentage ?? "" : Get.find<SplashController>().configModel.content?.defaultCommission ?? ""}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel.content?.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeDefault * 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Expanded(child: SizedBox()),

                CustomButton(
                  btnTxt: "change_business_plan".tr,
                  fontSize: Dimensions.fontSizeDefault,
                  onPressed: () {
                    showCustomBottomSheet(
                      child: const ChangeBusinessPlanBottomSheet(
                        showCommissionCard: false,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
