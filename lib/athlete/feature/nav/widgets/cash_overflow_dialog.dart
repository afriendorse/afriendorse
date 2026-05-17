import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CashOverflowDialog extends StatelessWidget {
  final double payablePercent;
  final double amount;
  const CashOverflowDialog({
    super.key,
    required this.payablePercent,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Stack(
            children: [
              Container(
                height: 120,
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                ),
              ),

              Container(
                height: 120,
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            userProfileController.hideOverflowDialog();
                          },
                          child: Image.asset(
                            Images.crossIcon,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Text(
                          "attention_please".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      (payablePercent >= 100)
                          ? 'your_limit_to_hold'.tr
                          : "looks_like_your".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),

                    payablePercent >= 100
                        ? InkWell(
                            onTap: () {
                              Get.find<DashboardController>().updateIndex(
                                -1,
                                isUpdate: false,
                              );
                              userProfileController.hideOverflowDialog();
                              showModalBottomSheet(
                                context: Get.context!,
                                useRootNavigator: true,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    PaymentMethodDialog(amount: amount),
                              );
                            },
                            child: Text(
                              "pay_the_due".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.9),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
