import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TrialEndBottomSheet extends StatelessWidget {
  final bool? isFreeTrail;
  final bool isPaid;
  const TrialEndBottomSheet({
    super.key,
    this.isFreeTrail,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
          topRight: Radius.circular(Dimensions.paddingSizeExtraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeExtraSmall,
                ),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(Images.trial, width: 150),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    isFreeTrail == true
                        ? 'your_free_trial_has_been_ended'.tr
                        : !isPaid
                        ? "your_payment_has_not_been_completed".tr
                        : "your_subscription_has_been_expired".tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Text(
                      isPaid
                          ? 'purchase_subscription_message'.tr
                          : "unpaid_subscription_message".tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButton(
                    btnTxt: isPaid ? 'choose_plan'.tr : "pay_now".tr,
                    width: 200,
                    height: 55,
                    radius: Dimensions.radiusLarge,
                    onPressed: () {
                      Get.back();
                      if (!isPaid) {
                        showCustomBottomSheet(
                          child: const ChangeBusinessPlanBottomSheet(),
                        );
                      } else {
                        Get.toNamed(RouteHelper.getBusinessPlanScreen());
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_octagon,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Flexible(
                          child: Text(
                            !isPaid
                                ? 'all_access_to_service_has_been_blocked_due_to_incomplete_payment'
                                      .tr
                                : 'all_access_to_service_has_been_blocked_due_to_no_active_subscription'
                                      .tr,
                            textAlign: TextAlign.start,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
