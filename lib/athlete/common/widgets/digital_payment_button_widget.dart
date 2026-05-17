import 'package:afriendorse/athlete/utils/core_export.dart';

class DigitalPaymentButtonWidget extends StatelessWidget {
  final DigitalPaymentMethod paymentMethod;
  final bool isSelected;
  const DigitalPaymentButtonWidget({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: Theme.of(
              context,
            ).secondaryHeaderColor.withValues(alpha: 0.10),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.green
                                : Theme.of(context).cardColor,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Text(
                          paymentMethod.label ?? "",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                      ],
                    ),
                  ],
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    height: Dimensions.paddingSizeLarge,
                    fit: BoxFit.contain,
                    image: '${paymentMethod.gatewayImageFullPath}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
