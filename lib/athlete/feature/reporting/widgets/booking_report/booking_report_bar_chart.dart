import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';

class BookingReportBarChart extends StatelessWidget {
  const BookingReportBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                    "booking_statistics".tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Chart(
                    data:
                        Get.find<BookingReportController>()
                            .barChartData
                            .isNotEmpty
                        ? Get.find<BookingReportController>().barChartData
                        : basicData,
                    variables: {
                      'Timeline': Variable(
                        accessor: (Map map) => map['timeline'] as String,
                      ),
                      'Amount': Variable(
                        accessor: (Map map) => map['Amount'] as num,
                      ),
                      'Tax amount': Variable(
                        accessor: (Map map) => map['tax'] as String,
                      ),
                      'Admin commission': Variable(
                        accessor: (Map map) => map['commission'] as String,
                      ),
                    },
                    marks: [IntervalMark()],

                    axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
                    selections: {'tap': PointSelection(dim: Dim.x)},
                    tooltip: TooltipGuide(
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ),
        ),
      ],
    );
  }
}

const basicData = [
  {'timeline': '2022', 'Amount': 0, 'tax': '0', 'commission': "0"},
  {'timeline': '2024', 'Amount': 0, 'tax': '0', 'commission': "0"},
  {'timeline': '2026', 'Amount': 0, 'tax': '0', 'commission': "0"},
  {'timeline': '2028', 'Amount': 0, 'tax': '0', 'commission': "0"},
  {'timeline': '2030', 'Amount': 0, 'tax': '0', 'commission': "0"},
];
