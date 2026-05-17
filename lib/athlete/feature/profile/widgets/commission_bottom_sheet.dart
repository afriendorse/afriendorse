import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/widgets/cost_percentage_widget.dart';
import 'package:get/get.dart';

class CommissionBottomSheet extends StatelessWidget {
  const CommissionBottomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        int commissionStatus = userProfileController
            .providerModel!
            .content!
            .providerInfo!
            .commissionStatus!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Dimensions.paddingSizeDefault * 2),
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault * 2),

            Image.asset(Images.commissionIcon, height: 80, width: 100),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(
              "commission_information".tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            CostPercentageWidget(
              title: "commission_percentage",
              amount:
                  " ${commissionStatus == 1 ? userProfileController.providerModel!.content!.providerInfo!.commissionPercentage : Get.find<SplashController>().configModel.content!.defaultCommission}",
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Text(
                commissionStatus == 1
                    ? "custom_commission_text".tr
                    : "default_commission_text".tr,
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomButton(
              btnTxt: 'okay'.tr,
              width: 100,
              onPressed: () {
                Get.back();
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault * 2),
          ],
        );
      },
    );
  }
}
