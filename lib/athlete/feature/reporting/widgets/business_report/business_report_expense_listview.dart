import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/business_report_expense_model.dart';
import 'package:get/get.dart';

class BusinessReportExpenseListView extends StatelessWidget {
  final List<BusinessReportFilterData> filterData;
  const BusinessReportExpenseListView({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterData.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  double normalDiscount =
                      filterData[index].discountByProvider ?? 0;
                  double couponDiscount =
                      filterData[index].couponDiscountByProvider ?? 0;
                  double campaignDiscount =
                      filterData[index].campaignDiscountByProvider ?? 0;

                  double totalExpense =
                      normalDiscount + couponDiscount + campaignDiscount;

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
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),

                                Text(
                                  'booking_id'.tr,
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                Text(
                                  " #${filterData[index].booking?.readableId.toString() ?? ""}",
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'normal_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        double.tryParse(
                                          filterData[index].discountByProvider
                                              .toString(),
                                        ),
                                      ),
                                      style: robotoRegular.copyWith(
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
                                      'coupon_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        double.tryParse(
                                          filterData[index]
                                              .couponDiscountByProvider
                                              .toString(),
                                        ),
                                      ),
                                      style: robotoRegular.copyWith(
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
                                      'campaign_discount'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        double.tryParse(
                                          filterData[index]
                                              .campaignDiscountByProvider
                                              .toString(),
                                        ),
                                      ),
                                      style: robotoRegular.copyWith(
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
                                      'total_expense'.tr,
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
                                      PriceConverter.convertPrice(totalExpense),
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
