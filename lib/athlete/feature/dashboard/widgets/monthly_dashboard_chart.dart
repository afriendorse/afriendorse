import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class MonthlyDashBoardChart extends StatelessWidget {
  const MonthlyDashBoardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return AspectRatio(
          aspectRatio: ResponsiveHelper.isTab(context) ? 5 : 1.8,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8, top: 10),
            child: LineChart(_mainData(dashboardController)),
          ),
        );
      },
    );
  }

  LineChartData _mainData(DashboardController controller) {
    final maxY = controller.mmM <= 0 ? 10.0 : controller.mmM;

    return LineChartData(
      minX: 0,
      maxX: controller.monthlyChartList.isEmpty
          ? 31
          : controller.monthlyChartList.length.toDouble() - 1,
      minY: 0,
      maxY: maxY + (maxY * 0.1),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          getTooltipColor: (_) => AthleteDashboardColors.primary,
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY <= 4 ? 1 : maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AthleteDashboardColors.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: maxY <= 4 ? 1 : maxY / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatAxisValue(value),
                style: robotoRegular.copyWith(
                  fontSize: 10,
                  color: AthleteDashboardColors.textSecondary,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: _bottomInterval(controller.monthlyChartList.length),
            getTitlesWidget: (value, meta) {
              final day = value.toInt();

              if (day <= 0) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '$day',
                  style: robotoRegular.copyWith(
                    fontSize: 9,
                    color: AthleteDashboardColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AthleteDashboardColors.border),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: controller.monthlyChartList,
          isCurved: true,
          curveSmoothness: 0.22,
          gradient: const LinearGradient(
            colors: [Color(0xFF0A7A31), Color(0xFF045F25)],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: controller.monthlyChartList.length <= 12),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AthleteDashboardColors.primary.withOpacity(0.20),
                AthleteDashboardColors.primary.withOpacity(0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _bottomInterval(int length) {
    if (length >= 31) return 5;
    if (length >= 28) return 4;
    return 3;
  }

  String _formatAxisValue(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
