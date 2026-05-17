import 'package:afriendorse/athlete/common/widgets/custom_date_picker.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReportSearchFilter extends StatelessWidget {
  final String fromPage;
  const ReportSearchFilter({super.key, required this.fromPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "filter".tr),
      body: fromPage == "transaction"
          ? GetBuilder<TransactionReportController>(
              builder: (transactionReportController) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                        : Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      if (transactionReportController.zoneNameList.length > 1)
                        ReportCustomDropdownButton(
                          label: 'select_zone'.tr,
                          value: transactionReportController.selectedZoneName,
                          items: transactionReportController.zoneNameList,
                          onChanged: (newValue) {
                            transactionReportController
                                .setSelectedDropdownValue(
                                  newValue!,
                                  type: "zone",
                                );
                          },
                        ),
                      ReportCustomDropdownButton(
                        label: 'select_date'.tr,
                        value:
                            transactionReportController.dateRange ?? "all_time",
                        items:
                            transactionReportController.dateRangeDropdownValue,
                        onChanged: (newValue) {
                          transactionReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'date_range',
                          );
                        },
                      ),
                      if (transactionReportController.dateRange ==
                          "custom_date")
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CustomDatePicker(
                                  title: 'from'.tr,
                                  text:
                                      transactionReportController.startDate !=
                                          null
                                      ? transactionReportController.dateFormat
                                            .format(
                                              transactionReportController
                                                  .startDate!,
                                            )
                                            .toString()
                                      : 'from_date'.tr,
                                  image: Images.calender,
                                  requiredField: false,
                                  selectDate: () => transactionReportController
                                      .selectDate("start", context),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),
                              Expanded(
                                child: CustomDatePicker(
                                  title: 'to'.tr,
                                  text:
                                      transactionReportController.endDate !=
                                          null
                                      ? transactionReportController.dateFormat
                                            .format(
                                              transactionReportController
                                                  .endDate!,
                                            )
                                            .toString()
                                      : 'to_date'.tr,
                                  image: Images.calender,
                                  requiredField: false,
                                  selectDate: () => transactionReportController
                                      .selectDate("end", context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            btnTxt: 'clear'.tr,
                            height: 40,
                            width: 120,
                            onPressed: () async {
                              transactionReportController.resetFilterValue();
                              transactionReportController
                                  .updatedIsFilteredValue();

                              int tabIndex =
                                  transactionReportController
                                      .tabController
                                      ?.index ??
                                  0;

                              if (tabIndex == 0) {
                                await transactionReportController
                                    .getAllTransactionReportData(1);
                              } else if (tabIndex == 1) {
                                await transactionReportController
                                    .getDebitTransactionReportData(1);
                              } else {
                                await transactionReportController
                                    .getCreditTransactionReportData(1);
                              }
                            },
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          CustomButton(
                            btnTxt: 'filter'.tr,
                            height: 40,
                            width: 120,
                            isLoading: transactionReportController.isLoading,
                            onPressed: () async {
                              int tabIndex =
                                  transactionReportController
                                      .tabController
                                      ?.index ??
                                  0;

                              if (tabIndex == 0) {
                                await transactionReportController
                                    .getAllTransactionReportData(
                                      1,
                                      reload: true,
                                    );
                              } else if (tabIndex == 1) {
                                await transactionReportController
                                    .getDebitTransactionReportData(
                                      1,
                                      reload: true,
                                    );
                              } else {
                                await transactionReportController
                                    .getCreditTransactionReportData(
                                      1,
                                      reload: true,
                                    );
                              }
                              transactionReportController
                                  .updatedIsFilteredValue();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : fromPage == 'booking'
          ? GetBuilder<BookingReportController>(
              builder: (bookingReportController) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: Get.width * .04,
                  ),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                        : Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      if (bookingReportController.zoneNameList.length > 1)
                        ReportCustomDropdownButton(
                          label: 'select_zone'.tr,
                          value: bookingReportController.selectedZoneName,
                          items: bookingReportController.zoneNameList,
                          onChanged: (newValue) {
                            bookingReportController.setSelectedDropdownValue(
                              newValue!,
                              type: 'zone',
                            );
                          },
                        ),

                      ReportCustomDropdownButton(
                        label: 'category'.tr,
                        value: bookingReportController.selectedCategoryName,
                        items: bookingReportController.categoryNameList,
                        onChanged: (newValue) {
                          bookingReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'category',
                          );
                          //bookingReportController.getSubcategoryList();
                        },
                      ),
                      ReportCustomDropdownButton(
                        label: 'sub_category'.tr,
                        value: bookingReportController.selectedSubcategoryName,
                        items: bookingReportController.subcategoryNameList,
                        onChanged: (newValue) {
                          bookingReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'subcategory',
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      ReportCustomDropdownButton(
                        label: "select_date".tr,
                        value: bookingReportController.dateRange ?? "all_time",
                        items: bookingReportController.dateRangeDropdownValue,
                        onChanged: (newValue) {
                          bookingReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'date_range',
                          );
                        },
                      ),
                      if (bookingReportController.dateRange == "custom_date")
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CustomDatePicker(
                                  title: 'from'.tr,
                                  text:
                                      bookingReportController.startDate != null
                                      ? bookingReportController.dateFormat
                                            .format(
                                              bookingReportController
                                                  .startDate!,
                                            )
                                            .toString()
                                      : 'from_date'.tr,
                                  image: Images.calender,
                                  requiredField: false,
                                  selectDate: () => bookingReportController
                                      .selectDate("start", context),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),
                              Expanded(
                                child: CustomDatePicker(
                                  title: 'to'.tr,
                                  text: bookingReportController.endDate != null
                                      ? bookingReportController.dateFormat
                                            .format(
                                              bookingReportController.endDate!,
                                            )
                                            .toString()
                                      : 'to_date'.tr,
                                  image: Images.calender,
                                  requiredField: false,
                                  selectDate: () => bookingReportController
                                      .selectDate("end", context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            btnTxt: 'clear'.tr,
                            height: 40,
                            width: 110,
                            onPressed: () {
                              bookingReportController.resetValue();
                              bookingReportController.updatedIsFilteredValue();
                              bookingReportController.getBookingReportData(1);
                            },
                          ),

                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          CustomButton(
                            btnTxt: 'filter'.tr,
                            height: 40,
                            width: 110,
                            isLoading: bookingReportController.isLoading,
                            onPressed: () async {
                              if (bookingReportController.dateRange ==
                                      "custom_date" &&
                                  bookingReportController.startDate == null) {
                                showCustomSnackBar(
                                  "enter_from_date".tr,
                                  type: ToasterMessageType.info,
                                );
                              } else if (bookingReportController.dateRange ==
                                      "custom_date" &&
                                  bookingReportController.endDate == null) {
                                showCustomSnackBar(
                                  "enter_to_date".tr,
                                  type: ToasterMessageType.info,
                                );
                              } else {
                                await bookingReportController
                                    .getBookingReportData(1, reload: true);
                                bookingReportController
                                    .updatedIsFilteredValue();
                                Get.back();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : GetBuilder<BusinessReportController>(
              builder: (businessReportController) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: Get.width * .04,
                  ),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                        : Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      if (businessReportController.zoneNameList.length > 1)
                        ReportCustomDropdownButton(
                          label: 'select_zone'.tr,
                          value: businessReportController.selectedZoneName,
                          items: businessReportController.zoneNameList,
                          onChanged: (newValue) {
                            businessReportController.setSelectedDropdownValue(
                              newValue!,
                              type: 'zone',
                            );
                          },
                        ),

                      ReportCustomDropdownButton(
                        label: 'category'.tr,
                        value: businessReportController.selectedCategoryName,
                        items: businessReportController.categoryNameList,
                        onChanged: (newValue) {
                          businessReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'category',
                          );
                        },
                      ),
                      ReportCustomDropdownButton(
                        label: 'sub_category'.tr,
                        value: businessReportController.selectedSubcategoryName,
                        items: businessReportController.subcategoryNameList,
                        onChanged: (newValue) {
                          businessReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'subcategory',
                          );
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      ReportCustomDropdownButton(
                        label: "select_date".tr,
                        value: businessReportController.dateRange ?? "all_time",
                        items: businessReportController.dateRangeDropdownValue,
                        onChanged: (newValue) {
                          businessReportController.setSelectedDropdownValue(
                            newValue!,
                            type: 'date_range',
                          );
                        },
                      ),
                      if (businessReportController.dateRange == "custom_date")
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: CustomDatePicker(
                                title: 'from'.tr,
                                text: businessReportController.startDate != null
                                    ? businessReportController.dateFormat
                                          .format(
                                            businessReportController.startDate!,
                                          )
                                          .toString()
                                    : 'from_date'.tr,
                                image: Images.calender,
                                requiredField: false,
                                selectDate: () => businessReportController
                                    .selectDate("start", context),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Expanded(
                              child: CustomDatePicker(
                                title: 'to'.tr,
                                text: businessReportController.endDate != null
                                    ? businessReportController.dateFormat
                                          .format(
                                            businessReportController.endDate!,
                                          )
                                          .toString()
                                    : 'to_date'.tr,
                                image: Images.calender,
                                requiredField: false,
                                selectDate: () => businessReportController
                                    .selectDate("end", context),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            btnTxt: 'clear'.tr,
                            height: 35,
                            width: 100,
                            onPressed: () async {
                              businessReportController.resetValue();

                              int tabIndex =
                                  businessReportController
                                      .businessReportTabController
                                      ?.index ??
                                  0;

                              if (tabIndex == 1) {
                                await businessReportController
                                    .getBusinessReportEarningData(
                                      1,
                                      reload: false,
                                    );
                              } else if (tabIndex == 2) {
                                await businessReportController
                                    .getBusinessReportExpenseData(
                                      1,
                                      reload: false,
                                    );
                              } else {
                                await businessReportController
                                    .getBusinessReportOverviewData(
                                      1,
                                      reload: false,
                                    );
                              }

                              businessReportController.updatedIsFilteredValue();
                            },
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          CustomButton(
                            btnTxt: 'filter'.tr,
                            height: 35,
                            width: 100,
                            isLoading: businessReportController.isLoading,
                            onPressed: () async {
                              int tabIndex =
                                  businessReportController
                                      .businessReportTabController
                                      ?.index ??
                                  0;

                              if (tabIndex == 1) {
                                await businessReportController
                                    .getBusinessReportEarningData(
                                      1,
                                      reload: true,
                                    );
                                Get.back();
                              } else if (tabIndex == 2) {
                                await businessReportController
                                    .getBusinessReportExpenseData(
                                      1,
                                      reload: true,
                                    );
                                Get.back();
                              } else {
                                await businessReportController
                                    .getBusinessReportOverviewData(
                                      1,
                                      reload: true,
                                    );
                                Get.back();
                              }
                              businessReportController.updatedIsFilteredValue();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
