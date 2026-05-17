import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RecentActivityGraph extends StatelessWidget {
  const RecentActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final pendingCustomisedPost =
            dashboardController.additionalInfoCount?.customizedPostCount ?? 0;
        final pendingBookingRequest =
            dashboardController.additionalInfoCount?.pendingBookingCount ?? 0;
        final totalCount = pendingBookingRequest + pendingCustomisedPost;

        return SizedBox(
          height: 310,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 4,
                    centerSpaceRadius: 56,
                    sections: showingSections(dashboardController, context),
                  ),
                ),
              ),
              if (totalCount > 0)
                Text(
                  '$totalCount',
                  style: robotoBold.copyWith(
                    fontSize: 22,
                    color: AthleteDashboardColors.textPrimary,
                  ),
                ),
              if (totalCount > 0)
                Text(
                  'Total Open Activities',
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: AthleteDashboardColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _LegendItem(
                    color: AthleteDashboardColors.primary,
                    label: "total_normal_booking".tr,
                  ),
                  _LegendItem(
                    color: AthleteDashboardColors.info,
                    label: "total_customized_booking".tr,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
    DashboardController dashboardController,
    BuildContext context,
  ) {
    final pendingCustomisedPost =
        dashboardController.additionalInfoCount?.customizedPostCount ?? 0;
    final pendingBookingRequest =
        dashboardController.additionalInfoCount?.pendingBookingCount ?? 0;
    final totalCount = pendingBookingRequest + pendingCustomisedPost;

    if (totalCount <= 0) {
      return [
        PieChartSectionData(
          color: AthleteDashboardColors.border,
          value: 1,
          title: "",
          radius: 40,
        ),
      ];
    }

    final pendingCustomisedPostPercentage =
        (pendingCustomisedPost * 100) / totalCount;
    final pendingBookingRequestPercentage =
        (pendingBookingRequest * 100) / totalCount;

    return [
      PieChartSectionData(
        color: AthleteDashboardColors.info,
        value: pendingCustomisedPostPercentage,
        title: pendingCustomisedPost.toString(),
        radius: 42,
        titleStyle: robotoBold.copyWith(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        color: AthleteDashboardColors.primary,
        value: pendingBookingRequestPercentage,
        title: pendingBookingRequest.toString(),
        radius: 42,
        titleStyle: robotoBold.copyWith(color: Colors.white, fontSize: 12),
      ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 12,
            color: AthleteDashboardColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
