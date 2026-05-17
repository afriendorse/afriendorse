import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessReport extends StatelessWidget {
  const BusinessReport({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      builder: (businessReportController) {
        return Scaffold(
          appBar: ReportAppBarView(
            title: 'business_report'.tr,
            fromPage: 'report',
            isFiltered: businessReportController.isFiltered,
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                businessReportController.isFiltered
                    ? const Padding(
                        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: BusinessReportFilteredWidget(),
                      )
                    : const SizedBox(),

                TabBar(
                  tabAlignment: TabAlignment.start,
                  controller:
                      businessReportController.businessReportTabController,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                  isScrollable: true,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  labelStyle: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                  tabs: [
                    SizedBox(
                      height: 45,
                      child: Center(child: Text("overview".tr)),
                    ),
                    SizedBox(
                      height: 45,
                      child: Center(child: Text("earning_report".tr)),
                    ),
                    SizedBox(
                      height: 45,
                      child: Center(child: Text("expense_report".tr)),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller:
                        businessReportController.businessReportTabController,
                    children: const [
                      BusinessReportView(fromPage: 'overview'),
                      BusinessReportView(fromPage: 'earning'),
                      BusinessReportView(fromPage: 'expense'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
