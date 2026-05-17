import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AthleteEarningsChartCard extends GetView<DashboardController> {
  const AthleteEarningsChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final previousYearsList = List.generate(
      5,
      (index) => (DateTime.now().year - index).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AthleteSectionTitle(
          title: 'Earnings Analytics',
          subtitle: 'Track your monthly and yearly earnings growth',
        ),
        AthleteGlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              GetBuilder<DashboardController>(
                builder: (dashboardController) {
                  final totalEarning = PriceConverter.convertPrice(
                    dashboardController.dashboardTopCards?.totalEarning ?? 0,
                    isShowLongPrice: true,
                  );

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Earnings',
                              style: robotoRegular.copyWith(
                                color: AthleteDashboardColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalEarning,
                              style: robotoBold.copyWith(
                                color: AthleteDashboardColors.textPrimary,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ChartToggleButton(
                        title: 'Monthly',
                        isActive:
                            dashboardController.getChartType ==
                            EarningType.monthly,
                        onTap: () {
                          dashboardController.getMonthlyBookingsDataForChart(
                            DateConverter.stringYear(DateTime.now()),
                            DateTime.now().month.toString(),
                          );
                          dashboardController.changeGraph(EarningType.monthly);
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChartToggleButton(
                        title: 'Yearly',
                        isActive:
                            dashboardController.getChartType ==
                            EarningType.yearly,
                        onTap: () {
                          dashboardController.getYearlyBookingsDataForChart(
                            DateConverter.stringYear(DateTime.now()),
                          );
                          dashboardController.changeGraph(EarningType.yearly);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              GetBuilder<DashboardController>(
                builder: (dashboardController) {
                  return dashboardController.getChartType == EarningType.monthly
                      ? Row(
                          children: [
                            Expanded(
                              child: _DropdownContainer(
                                child: CustomDropDownButton(
                                  title: "year".tr,
                                  type: "Year",
                                  itemList: previousYearsList,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DropdownContainer(
                                child: CustomDropDownButton(
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
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _DropdownContainer(
                                child: CustomDropDownButton(
                                  title: "year".tr,
                                  type: "Year",
                                  itemList: previousYearsList,
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 18),
              Container(
                width: context.width,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                decoration: BoxDecoration(
                  color: AthleteDashboardColors.cardBg2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AthleteDashboardColors.border),
                ),
                child: GetBuilder<DashboardController>(
                  builder: (controller) {
                    return SizedBox(
                      width: context.width,
                      child: controller.getChartType == EarningType.monthly
                          ? const MonthlyDashBoardChart()
                          : const YearlyDashBoardChart(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your total earnings trend',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: AthleteDashboardColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartToggleButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartToggleButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AthleteDashboardColors.primary
              : AthleteDashboardColors.cardBg2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AthleteDashboardColors.primary
                : AthleteDashboardColors.border,
          ),
        ),
        child: Text(
          title,
          style: robotoMedium.copyWith(
            color: isActive ? Colors.white : AthleteDashboardColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;

  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AthleteDashboardColors.cardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AthleteDashboardColors.border),
      ),
      child: child,
    );
  }
}
