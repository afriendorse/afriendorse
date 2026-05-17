import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/chart_model.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BusinessReportLineChart extends StatefulWidget {
  final String fromPage;
  const BusinessReportLineChart({super.key, required this.fromPage});

  @override
  BusinessReportLineChartState createState() => BusinessReportLineChartState();
}

class BusinessReportLineChartState extends State<BusinessReportLineChart> {
  late TooltipBehavior _tooltipBehavior;
  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (widget.fromPage == 'overview')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'earning'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'expense'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          if (widget.fromPage == 'earning')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, size: 12, color: Colors.green),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'net_profit'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'total_earning'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'total_expense'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 200,
            child: Center(
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                onDataLabelTapped: (DataLabelTapDetails data) {},
                tooltipBehavior: _tooltipBehavior,
                enableMultiSelection: true,

                series: <CartesianSeries>[
                  if (widget.fromPage == 'overview')
                    SplineSeries<ChartDataModel, String>(
                      color: Theme.of(context).colorScheme.error,
                      width: 3,
                      enableTooltip: true,
                      name: "expense".tr,
                      dataSource: Get.find<BusinessReportController>()
                          .overviewExpenseChart,
                      xValueMapper: (ChartDataModel data, _) => data.x,
                      yValueMapper: (ChartDataModel data, _) => data.y,
                    ),
                  if (widget.fromPage == 'overview')
                    SplineSeries<ChartDataModel, String>(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                      enableTooltip: true,
                      name: "earning".tr,
                      dataSource: Get.find<BusinessReportController>()
                          .overviewEarningChart,
                      xValueMapper: (ChartDataModel data, _) => data.x,
                      yValueMapper: (ChartDataModel data, _) => data.y,
                    ),

                  if (widget.fromPage == 'earning')
                    SplineSeries<ChartDataModel, String>(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                      enableTooltip: true,
                      name: "total_earning".tr,
                      dataSource: Get.find<BusinessReportController>()
                          .earningTotalEarningChart,
                      xValueMapper: (ChartDataModel data, _) => data.x,
                      yValueMapper: (ChartDataModel data, _) => data.y,
                    ),

                  if (widget.fromPage == 'earning')
                    SplineSeries<ChartDataModel, String>(
                      color: Theme.of(context).colorScheme.error,
                      width: 3,
                      enableTooltip: true,
                      name: "total_expense".tr,
                      dataSource: Get.find<BusinessReportController>()
                          .earningExpenseChart,
                      xValueMapper: (ChartDataModel data, _) => data.x,
                      yValueMapper: (ChartDataModel data, _) => data.y,
                    ),

                  if (widget.fromPage == 'earning')
                    SplineSeries<ChartDataModel, String>(
                      color: Colors.green,
                      width: 3,
                      enableTooltip: true,
                      name: "net_profit".tr,
                      dataSource: Get.find<BusinessReportController>()
                          .earningNetProfitChart,
                      xValueMapper: (ChartDataModel data, _) => data.x,
                      yValueMapper: (ChartDataModel data, _) => data.y,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final double x;
  final int? y;
}
