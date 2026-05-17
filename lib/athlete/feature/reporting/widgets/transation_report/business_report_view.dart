import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_bar_chart.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_earning_list.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_line_chart.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_expense_listview.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_overview_list.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_shimmer.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_statistics.dart';
import 'package:get/get.dart';

class BusinessReportView extends StatelessWidget {
  final String fromPage;
  const BusinessReportView({super.key, required this.fromPage});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      initState: (_) {
        if (fromPage == 'earning') {
          Get.find<BusinessReportController>().getBusinessReportEarningData(1);
        } else if (fromPage == 'expense') {
          Get.find<BusinessReportController>().getBusinessReportExpenseData(1);
        } else {
          Get.find<BusinessReportController>().getBusinessReportOverviewData(1);
        }
      },
      builder: (reportController) {
        return reportController.loading
            ? const BusinessReportShimmer()
            : CustomScrollView(
                controller: reportController.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: BusinessReportStatistics(
                      fromPage: fromPage,
                      reportController: reportController,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: fromPage == 'expense'
                        ? const BusinessReportBarChart()
                        : BusinessReportLineChart(fromPage: fromPage),
                  ),

                  if (fromPage == 'overview')
                    SliverToBoxAdapter(
                      child: BusinessReportOverviewListView(
                        filterData:
                            reportController.businessReportFilterOverviewData,
                      ),
                    ),
                  if (fromPage == 'earning')
                    SliverToBoxAdapter(
                      child: BusinessReportEarningListView(
                        filterData:
                            reportController.businessReportFilterEarningData,
                      ),
                    ),
                  if (fromPage == 'expense')
                    SliverToBoxAdapter(
                      child: BusinessReportExpenseListView(
                        filterData:
                            reportController.businessReportFilterExpenseData,
                      ),
                    ),
                ],
              );
      },
    );
  }
}
