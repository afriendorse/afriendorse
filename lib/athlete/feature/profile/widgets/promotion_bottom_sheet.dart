import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/widgets/cost_percentage_widget.dart';
import 'package:get/get.dart';

class PromotionBottomSheet extends StatelessWidget {
  const PromotionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    Get.context!,
                  ).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault * 2,
                ),
              ),

              Image.asset(Images.promotionIcon, height: 80, width: 100),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text(
                "promotional_cost".tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Text(
                  "default_promotion_text".tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CostPercentageWidget(
                title: "discount_cost_percentage",
                amount:
                    userProfileController
                        .providerModel
                        ?.content
                        ?.promotionalCostPercentage
                        ?.discount ??
                    "0",
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CostPercentageWidget(
                title: "campaign_cost_percentage",
                amount:
                    userProfileController
                        .providerModel
                        ?.content
                        ?.promotionalCostPercentage
                        ?.campaign ??
                    "0",
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CostPercentageWidget(
                title: "coupon_cost_percentage",
                amount:
                    userProfileController
                        .providerModel
                        ?.content
                        ?.promotionalCostPercentage
                        ?.coupon ??
                    "0",
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButton(
                btnTxt: 'okay'.tr,
                width: 100,
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault * 2),
            ],
          ),
        );
      },
    );
  }
}
