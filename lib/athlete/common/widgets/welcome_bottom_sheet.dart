import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class WelcomeBottomSheet extends StatelessWidget {
  final bool fromSignup;
  final bool isFromTransactionFailed;
  const WelcomeBottomSheet({
    super.key,
    required this.fromSignup,
    this.isFromTransactionFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 5,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).hintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          margin: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault * 2,
          ),
        ),

        Image.asset(Images.welcomeIcon, height: 130, fit: BoxFit.fitHeight),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        isFromTransactionFailed
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault * 2,
                ),
                child: Text(
                  "${'transaction_failed'.tr} !! ${Get.find<SplashController>().configModel.content?.subscriptionFreeTrail == 1 ? "due_to_transaction_failed_your_registration_has_been_done_as_free_trail".tr : "you_can_pay_the_due_in_later".tr}",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Text(
                fromSignup
                    ? "${"welcome_to".tr} ${AppConstants.appName}!"
                    : "thank_you_for_your_suggestion".tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault * 2,
          ),
          child: Text(
            fromSignup
                ? "welcome_message_for_sign_up".tr
                : "welcome_message_for_suggest_service".tr,
            maxLines: 3,
            style: robotoRegular.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge * 1.3),

        CustomButton(
          btnTxt: 'okay'.tr,
          width: 100,
          onPressed: () => Get.back(),
        ),

        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }
}
