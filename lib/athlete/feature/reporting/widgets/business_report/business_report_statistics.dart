import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/business_report_earning_model.dart';
import 'package:afriendorse/athlete/feature/reporting/widgets/business_report/business_report_statistics_card.dart';
import 'package:get/get.dart';

class BusinessReportStatistics extends StatelessWidget {
  final String fromPage;
  final BusinessReportController reportController;
  const BusinessReportStatistics({
    super.key,
    required this.fromPage,
    required this.reportController,
  });

  @override
  Widget build(BuildContext context) {
    List<String> title = [];
    List<String> titleAmount = [];
    List<String> icon = [];

    if (fromPage == 'expense') {
      titleAmount = [
        reportController
                .businessReportExpenseModel
                ?.content
                ?.totalPromotionalCost
                ?.totalExpense
                .toString() ??
            '0',
        reportController
                .businessReportExpenseModel
                ?.content
                ?.totalPromotionalCost
                ?.discount
                .toString() ??
            '0',
        reportController
                .businessReportExpenseModel
                ?.content
                ?.totalPromotionalCost
                ?.campaign
                .toString() ??
            '0',
        reportController
                .businessReportExpenseModel
                ?.content
                ?.totalPromotionalCost
                ?.coupon
                .toString() ??
            '0',
      ];
      title = [
        'total_expense',
        'normal_service_discount',
        'campaign_discount',
        'coupon_discount',
      ];
      icon = [
        Images.reportExpense1,
        Images.reportExpense2,
        Images.reportExpense3,
        Images.reportExpense4,
      ];
    } else if (fromPage == 'earning') {
      double netProfit = 0;
      double totalEarning = 0;
      double totalExpense = 0;

      if (reportController.businessReportEarningModel != null) {
        ChartData data =
            reportController.businessReportEarningModel!.content!.chartData!;

        for (int i = 0; i < data.timeline!.length; i++) {
          netProfit = netProfit + data.netProfit![i];
          totalEarning = totalEarning + data.totalEarning![i];
          totalExpense = totalExpense + data.totalExpense![i];
        }
        netProfit = totalEarning - totalExpense;
      }
      titleAmount = [
        netProfit.toString(),
        totalEarning.toString(),
        totalExpense.toString(),
      ];
      title = ['net_profit', 'total_earning', 'total_expense'];
      icon = [
        Images.reportEarning1,
        Images.reportEarning2,
        Images.reportEarning3,
      ];
    }

    if (fromPage != 'overview') {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        child: SizedBox(
          height: 100,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return BusinessReportStatisticsCard(
                icon: icon[index],
                titleAmount: titleAmount[index],
                title: title[index],
              );
            },
            itemCount: titleAmount.length,
          ),
        ),
      );
    } else {
      return GetBuilder<BusinessReportController>(
        builder: (reportController) {
          double discount = 0;
          double couponDiscount = 0;
          double campaignDiscount = 0;
          double totalExpense = 0;
          double netProfit = 0;
          double taxCollected = 0;

          reportController.businessReportOverviewModel?.content?.amounts
              ?.forEach((element) {
                discount = discount + (element.discountByProvider ?? 0);
                couponDiscount =
                    couponDiscount + (element.couponDiscountByProvider ?? 0);
                campaignDiscount =
                    campaignDiscount +
                    (element.campaignDiscountByProvider ?? 0);
                totalExpense = discount + campaignDiscount + couponDiscount;
                netProfit = netProfit + (element.providerEarning ?? 0);
                taxCollected = taxCollected + (element.serviceTax ?? 0);
              });

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: SizedBox(
              height: 125,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    BusinessReportStatisticsCard(
                      icon: Images.reportOverview1,
                      titleAmount: (netProfit - totalExpense).toString(),
                      title: 'net_profit',
                    ),
                    BusinessReportStatisticsCard2(
                      icon: Images.reportOverview2,
                      titleAmount: totalExpense.toString(),
                      title: 'total_expense',
                      subtitle1: 'normal_discount',
                      subtitleAmount1: discount.toString(),
                      subtitle2: 'coupon_discount',
                      subtitleAmount2: couponDiscount.toString(),
                      subtitle3: 'campaign_discount',
                      subtitleAmount3: campaignDiscount.toString(),
                      withCurrencySymbol: true,
                    ),
                    BusinessReportStatisticsCard(
                      icon: Images.reportEarning2,
                      titleAmount: taxCollected.toString(),
                      title: 'total_tax_calculated',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
