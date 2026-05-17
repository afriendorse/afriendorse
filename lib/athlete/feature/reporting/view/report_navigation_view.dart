import 'package:afriendorse/athlete/feature/reporting/view/booking_report.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReportNavigationView extends StatelessWidget {
  const ReportNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "reports".tr),

      body: Column(
        children: [
          GetBuilder<TransactionReportController>(
            builder: (controller) {
              return ReportItem(
                icon: Images.reportOverview1,
                title: 'transactions_report',
                onTap: () {
                  controller.resetFilterValue();
                  Get.to(() => const TransactionReport());
                },
              );
            },
          ),

          ReportItem(
            icon: Images.reportOverview2,
            title: 'business_report',
            onTap: () {
              Get.find<BusinessReportController>().resetValue();
              Get.to(() => const BusinessReport());
            },
          ),

          ReportItem(
            icon: Images.reportOverview3,
            title: 'booking_report',
            onTap: () {
              Get.find<BookingReportController>().resetValue();
              Get.to(() => const BookingReport());
            },
          ),
        ],
      ),
    );
  }
}

class ReportItem extends StatelessWidget {
  final Function() onTap;
  final String title;
  final String icon;
  const ReportItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeExtraLarge,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Get.isDarkMode
                ? Theme.of(context).hintColor.withValues(alpha: 0.5)
                : Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          child: Column(
            children: [
              Image.asset(icon, width: 40),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                title.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ],
          ),
        ),

        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: CustomInkWell(onTap: onTap),
          ),
        ),
      ],
    );
  }
}
