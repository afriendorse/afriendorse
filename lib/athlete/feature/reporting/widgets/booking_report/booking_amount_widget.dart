import 'package:afriendorse/athlete/helper/price_converter.dart';
import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:afriendorse/athlete/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class BookingAmountWidget extends StatelessWidget {
  final String totalBookingAmount;
  final String dueAmount;
  final String settledAmount;
  final JustTheController dueTooltipController;
  final JustTheController settledTooltipController;

  const BookingAmountWidget({
    super.key,
    required this.totalBookingAmount,
    required this.dueAmount,
    required this.settledAmount,
    required this.dueTooltipController,
    required this.settledTooltipController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'booking_amount'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeEight),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.03),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.10),
                      ),
                      color: Get.isDarkMode
                          ? Colors.grey.withValues(alpha: 0.05)
                          : Theme.of(context).cardColor,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          PriceConverter.convertPrice(
                            double.tryParse(totalBookingAmount),
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          'total_amount'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.paddingSizeEight),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      AmountRowWidget(
                        tooltipMessage: "this_total_amount_due".tr,
                        label: '${'due_amount'.tr} : ',
                        amount: dueAmount,
                        tooltipController: dueTooltipController,
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      AmountRowWidget(
                        tooltipMessage: "this_total_amount_settled".tr,
                        label: '${'already_settled'.tr} : ',
                        amount: settledAmount,
                        textColor: Theme.of(context).primaryColor,
                        tooltipController: settledTooltipController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AmountRowWidget extends StatelessWidget {
  final String tooltipMessage;
  final String label;
  final String amount;
  final JustTheController tooltipController;
  final Color? textColor;
  const AmountRowWidget({
    super.key,
    required this.tooltipMessage,
    required this.label,
    required this.amount,
    required this.tooltipController,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeEight,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
              ),
              color: Get.isDarkMode
                  ? Colors.grey.withValues(alpha: 0.05)
                  : Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: tooltipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      tooltipMessage,
                      style: robotoRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => tooltipController.showTooltip(),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).hintColor,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.paddingSizeTini),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: label,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: PriceConverter.convertPrice(
                            double.tryParse(amount),
                          ),
                          style: robotoBold.copyWith(
                            color:
                                textColor ??
                                Theme.of(context).colorScheme.error,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
