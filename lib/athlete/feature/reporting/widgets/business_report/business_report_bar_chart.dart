import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';

class BusinessReportBarChart extends StatelessWidget {
  const BusinessReportBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Image.asset(Images.dashboardEarning, height: 15, width: 15),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                "expense_statistics".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 250,
              color: Theme.of(context).cardColor,
              child: Chart(
                //data:basicData,
                data:
                    Get.find<BusinessReportController>().barChartData.isNotEmpty
                    ? Get.find<BusinessReportController>().barChartData
                    : basicData,
                variables: {
                  'Timeline': Variable(
                    accessor: (Map map) => map['timeline'] as String,
                  ),
                  'Amount': Variable(
                    accessor: (Map map) => map['Amount'] as num,
                  ),
                },
                axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
                selections: {'tap': PointSelection(dim: Dim.x)},
                tooltip: TooltipGuide(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                marks: [IntervalMark()],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}

const basicData = [
  {'timeline': '0', 'Amount': 0},
  {'timeline': '2', 'Amount': 0},
  {'timeline': '4', 'Amount': 0},
];
