import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/transaction_report_model.dart';
import 'package:get/get.dart';

class TransactionReportListView extends StatelessWidget {
  final int tabIndex;
  final List<TransactionReportData> transactionReportList;
  const TransactionReportListView({
    super.key,
    required this.tabIndex,
    required this.transactionReportList,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionReportController>(
      builder: (reportController) {
        return Column(
          children: [
            transactionReportList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      controller: reportController.scrollController,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Theme.of(context).cardColor.withValues(
                              alpha: Get.isDarkMode ? 0.5 : 1,
                            ),
                            border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: 7,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      transactionReportList[index].trxType
                                          .toString()
                                          .tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                    Expanded(
                                      child: Text(
                                        DateConverter.dateMonthYearTime(
                                          DateConverter.isoUtcStringToLocalDate(
                                            transactionReportList[index]
                                                    .createdAt ??
                                                "",
                                          ),
                                        ),
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${'transaction_to'.tr} : ',
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        transactionReportList[index]
                                                    .toUser
                                                    ?.userType ==
                                                "provider-admin"
                                            ? Get.find<UserProfileController>()
                                                      .providerModel
                                                      ?.content
                                                      ?.providerInfo
                                                      ?.companyName ??
                                                  ""
                                            : '${transactionReportList[index].toUser?.firstName ?? ''} ${transactionReportList[index].toUser?.lastName ?? ''}',
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color!
                                              .withValues(alpha: 0.8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Divider(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color!
                                    .withValues(alpha: 0.2),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'debit'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        transactionReportList[index].debit,
                                      ),
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'credit'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        transactionReportList[index].credit,
                                      ),
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                child: CustomDivider(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'balance'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    Text(
                                      PriceConverter.convertPrice(
                                        transactionReportList[index].balance,
                                      ),
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: transactionReportList.length,
                    ),
                  )
                : const SizedBox(),
            if (transactionReportList.isEmpty &&
                !Get.find<TransactionReportController>().loading)
              const Expanded(
                child: Center(
                  child: NoDataScreen(text: "", type: NoDataType.others),
                ),
              ),
            if (Get.find<TransactionReportController>().isLoading)
              const CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
