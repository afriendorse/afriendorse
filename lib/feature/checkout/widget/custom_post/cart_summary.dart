import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class CustomPostCartSummary extends StatelessWidget {
  final PostDetailsContent? postDetails;
  final String amount;
  const CustomPostCartSummary({
    super.key,
    required this.postDetails,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    ConfigModel configModel = Get.find<SplashController>().configModel;
    double additionalCharge = CheckoutHelper.getAdditionalCharge();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "price_breakdown".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                context,
                postDetails?.service?.name ?? "Service",
                amount,
                isMain: true,
              ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              const SizedBox(height: 16),

              GetBuilder<CheckOutController>(
                builder: (controller) {
                  return _buildPriceRow(
                    context,
                    "vat".tr,
                    PriceConverter.convertPrice(
                      controller.totalVat,
                      isShowLongPrice: true,
                    ),
                    prefix: "+",
                    iconData: Icons.account_balance_wallet_outlined,
                  );
                },
              ),

              if (configModel.content?.additionalChargeLabelName != "" &&
                  configModel.content?.additionalCharge == 1) ...[
                const SizedBox(height: 12),
                GetBuilder<CheckOutController>(
                  builder: (controller) {
                    return _buildPriceRow(
                      context,
                      configModel.content?.additionalChargeLabelName ?? "",
                      PriceConverter.convertPrice(
                        additionalCharge,
                        isShowLongPrice: true,
                      ),
                      prefix: "+",
                      iconData: Icons.add_circle_outline,
                    );
                  },
                ),
              ],

              if (Get.find<CheckOutController>().referralDiscountAmount >
                  0) ...[
                const SizedBox(height: 12),
                GetBuilder<CheckOutController>(
                  builder: (controller) {
                    return _buildPriceRow(
                      context,
                      "referral_discount".tr,
                      PriceConverter.convertPrice(
                        controller.referralDiscountAmount,
                        isShowLongPrice: true,
                      ),
                      prefix: "-",
                      iconData: Icons.discount_rounded,
                      isDiscount: true,
                    );
                  },
                ),
              ],

              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1.5,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              const SizedBox(height: 16),

              GetBuilder<CheckOutController>(
                builder: (controller) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.payments_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                "total_payable".tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          PriceConverter.convertPrice(
                            controller.totalAmount,
                            isShowLongPrice: true,
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    String? prefix,
    IconData? iconData,
    bool isMain = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 16,
                  color: isDiscount
                      ? Colors.green
                      : Theme.of(context).hintColor.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: isMain
                      ? robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        )
                      : robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          prefix != null ? "$prefix $value" : value,
          style: robotoMedium.copyWith(
            fontSize: isMain
                ? Dimensions.fontSizeDefault
                : Dimensions.fontSizeSmall,
            color: isDiscount
                ? Colors.green
                : Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ],
    );
  }
}
