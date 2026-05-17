import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubscriptionTransactionListview extends StatelessWidget {
  final List<SubscriptionTransactionModel> transactionList;
  const SubscriptionTransactionListview({
    super.key,
    required this.transactionList,
  });

  @override
  Widget build(BuildContext context) {
    List<PopupMenuModel> menuList = [
      PopupMenuModel(title: "download_invoice", icon: Icons.download),
    ];

    return GetBuilder<BusinessSubscriptionController>(
      builder: (businessSubscriptionController) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                businessSubscriptionController.clearSearchController();
                await businessSubscriptionController
                    .getSubscriptionTransactionList(1);
              },
              child: transactionList.isEmpty
                  ? NoDataScreen(
                      text:
                          businessSubscriptionController.isActiveSuffixIcon &&
                              businessSubscriptionController.isSearchComplete &&
                              businessSubscriptionController.dateTimeRange ==
                                  null
                          ? "no_transaction_history_found_to_your_related_search"
                          : businessSubscriptionController.dateTimeRange != null
                          ? "${"no_transaction_history_fount_between".tr.capitalizeFirst} : ${DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.start)} - ${DateConverter.dateStringMonthYear(businessSubscriptionController.dateTimeRange!.end)}"
                          : "no_transaction_history",
                      type: NoDataType.transaction,
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withValues(
                              alpha: Get.isDarkMode ? 0.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            boxShadow: context.customThemeColors.lightShadow,
                          ),
                          margin: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeExtraSmall + 3,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            "tx_id".tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .color!
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              " # ${transactionList[index].id ?? ""}",
                                              style: robotoBold.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.8),
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Get.isDarkMode
                                                  ? Colors.grey.withValues(
                                                      alpha: 0.2,
                                                    )
                                                  : context
                                                        .customThemeColors
                                                        .buttonBackgroundColorMap[transactionList[index]
                                                        .trxType],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${transactionList[index].trxType}'
                                                    .tr,
                                                style: robotoMedium.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color:
                                                      context
                                                          .customThemeColors
                                                          .buttonTextColorMap[transactionList[index]
                                                          .trxType],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    PopupMenuButton<PopupMenuModel>(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).hintColor.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      surfaceTintColor: Theme.of(
                                        context,
                                      ).cardColor,
                                      position: PopupMenuPosition.under,
                                      elevation: 8,
                                      shadowColor: Theme.of(
                                        context,
                                      ).hintColor.withValues(alpha: 0.3),
                                      itemBuilder: (BuildContext context) {
                                        return menuList.map((
                                          PopupMenuModel option,
                                        ) {
                                          return PopupMenuItem<PopupMenuModel>(
                                            onTap: () async {
                                              showCustomDialog(
                                                child: const CustomLoader(),
                                              );
                                              String languageCode =
                                                  Get.find<
                                                        LocalizationController
                                                      >()
                                                      .locale
                                                      .languageCode;
                                              String uri =
                                                  "${AppConstants.baseUrl}${AppConstants.subscriptionTransactionInvoice}${transactionList[index].id}/$languageCode";
                                              if (kDebugMode) {
                                                print("Uri : $uri");
                                              }
                                              await _launchUrl(Uri.parse(uri));
                                              Get.back();

                                              // var pdfFile = await SubscriptionInvoice.generateInvoice(
                                              //     transaction: transactionList[index],
                                              //     provider: Get.find<UserProfileController>().providerModel?.content?.providerInfo
                                              //
                                              // );
                                              // PdfApi.openFile(pdfFile);
                                            },
                                            value: option,
                                            height: 40,
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Icon(
                                                  option.icon,
                                                  size:
                                                      Dimensions.fontSizeLarge,
                                                  color: Theme.of(
                                                    context,
                                                  ).hintColor,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                Text(
                                                  option.title.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList();
                                      },
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Theme.of(
                                          context,
                                        ).hintColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 1,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeExtraSmall,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Text(
                                            DateConverter.dateMonthYearTime(
                                              DateConverter.isoUtcStringToLocalDate(
                                                transactionList[index]
                                                    .createdAt!,
                                              ),
                                            ),
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color
                                                  ?.withValues(alpha: 0.6),
                                            ),
                                            textDirection: TextDirection.ltr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${transactionList[index].trxType == "subscription_refund" ? '${'subscription_refund'.tr} ${'to'.tr.toLowerCase()}' : 'paid_by'.tr} -",
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color
                                                      ?.withValues(alpha: 0.6),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  transactionList[index]
                                                              .trxType ==
                                                          "subscription_refund"
                                                      ? "receivable_balance".tr
                                                      : transactionList[index]
                                                                .packageLog
                                                                ?.payment
                                                                ?.paymentMethod
                                                                ?.tr ??
                                                            "",
                                                  style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color:
                                                        transactionList[index]
                                                                .trxType ==
                                                            "subscription_refund"
                                                        ? context
                                                              .customThemeColors
                                                              .buttonTextColorMap['pending']
                                                        : context
                                                              .customThemeColors
                                                              .buttonTextColorMap['ongoing'],
                                                  ),
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            transactionList[index]
                                                    .packageLog
                                                    ?.packageName ??
                                                "",
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).secondaryHeaderColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Text(
                                            PriceConverter.convertPrice(
                                              transactionList[index].credit!,
                                            ),
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(
                                                context,
                                              ).primaryColorLight,
                                            ),
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
                      },
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      itemCount: transactionList.length,
                      shrinkWrap: true,
                      controller:
                          businessSubscriptionController.scrollController,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
