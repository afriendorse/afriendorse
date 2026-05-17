import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class GraphSection extends GetView<DashboardController> {
  const GraphSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> previousYearsList = [];
    for (int i = 0; i <= 4; i++) {
      previousYearsList.add((DateTime.now().year - i).toString());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault + 3,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            children: [
              Image.asset(Images.dashboardEarning, height: 15, width: 15),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                "earning_statistics".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: context.width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.cardBottomShadow,
          ),
          padding: const EdgeInsets.only(
            right: Dimensions.paddingSizeSmall,
            top: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GetBuilder<DashboardController>(
                builder: (dashboardController) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          dashboardController.getMonthlyBookingsDataForChart(
                            DateConverter.stringYear(DateTime.now()),
                            DateTime.now().month.toString(),
                          );
                          dashboardController.changeGraph(EarningType.monthly);
                        },
                        child: GraphCustomButton(
                          buttonText: "monthly".tr,
                          isSelectedButton:
                              dashboardController.getChartType ==
                                  EarningType.monthly
                              ? true
                              : false,
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      GestureDetector(
                        onTap: () {
                          dashboardController.getYearlyBookingsDataForChart(
                            DateConverter.stringYear(DateTime.now()),
                          );
                          dashboardController.changeGraph(EarningType.yearly);
                        },
                        child: GraphCustomButton(
                          buttonText: "yearly".tr,
                          isSelectedButton:
                              dashboardController.getChartType ==
                                  EarningType.yearly
                              ? true
                              : false,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              GetBuilder<DashboardController>(
                builder: (dashboardController) {
                  return dashboardController.getChartType == EarningType.monthly
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomDropDownButton(
                              title: "year".tr,
                              type: "Year",
                              itemList: previousYearsList,
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            CustomDropDownButton(
                              title: "month".tr,
                              type: "Month",
                              itemList: const [
                                'january',
                                'february',
                                'march',
                                'april',
                                'may',
                                'june',
                                'july',
                                'august',
                                'september',
                                'october',
                                'november',
                                'december',
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomDropDownButton(
                              title: "year".tr,
                              type: "Year",
                              itemList: previousYearsList,
                            ),
                          ],
                        );
                },
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              GetBuilder<DashboardController>(
                builder: (controller) {
                  return SizedBox(
                    width: context.width,
                    child: controller.getChartType == EarningType.monthly
                        ? const MonthlyDashBoardChart()
                        : const YearlyDashBoardChart(),
                  );
                },
              ),
              Text(
                "total_earning".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
