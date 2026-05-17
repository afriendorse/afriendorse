import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentFailedDialog extends StatelessWidget {
  const PaymentFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Image.asset(Images.warning, width: 70, height: 70),
        ),
        Text(
          'are_you_agree_with_this_payment_fail'.tr,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        TextButton(
          onPressed: () {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: const Size(Dimensions.webMaxWidth, 45),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          child: Text(
            'continue_with_payment_fail'.tr,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
