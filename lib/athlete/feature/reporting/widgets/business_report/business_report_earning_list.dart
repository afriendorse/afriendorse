import 'package:afriendorse/athlete/feature/reporting/model/business_report_earning_model.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BusinessReportEarningListView extends StatelessWidget {
  final List<BusinessReportEarningFilterData> filterData;
  const BusinessReportEarningListView({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterData.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  bottom: Dimensions.paddingSizeDefault,
                ),
                itemBuilder: (context, index) {
                  double netProfit =
                      filterData[index]
                          .bookingDetailsAmounts
                          ?.providerEarning ??
                      0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        color: Theme.of(
                          context,
                        ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                topRight: Radius.circular(
                                  Dimensions.radiusSmall,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'booking_id'.tr,
                                      style: robotoMedium.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      " #${filterData[index].readableId.toString()}",
                                      style: robotoMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'booking_amount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index].totalBookingAmount,
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'total_service_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index].totalDiscountAmount,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'provider_paid_service_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                                .bookingDetailsAmounts
                                                ?.discountByProvider ??
                                            0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'total_coupon_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                            .totalCouponDiscountAmount,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'provider_paid_coupon_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                                .bookingDetailsAmounts
                                                ?.couponDiscountByProvider ??
                                            0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'total_campaign_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                            .totalCampaignDiscountAmount,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'provider_paid_campaign_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                                .bookingDetailsAmounts
                                                ?.campaignDiscountByProvider ??
                                            0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                CustomDivider(
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                  width: 3.0,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'sub_total'.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index].totalBookingAmount,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'admin_commission'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index]
                                                .bookingDetailsAmounts
                                                ?.adminCommission ??
                                            0,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${'vat/tax'.tr} : ",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        filterData[index].totalTaxAmount,
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                CustomDivider(
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                  width: 3.0,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'provider_net_income'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(netProfit),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: filterData.length,
              )
            : SizedBox(
                height: Get.height * 0.33,
                child: const Center(
                  child: NoDataScreen(text: "", type: NoDataType.others),
                ),
              ),
        if (Get.find<BusinessReportController>().isLoading)
          const CircularProgressIndicator(),
      ],
    );
  }
}
