import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessReportStatisticsCard extends StatelessWidget {
  final String icon;
  final String titleAmount;
  final String title;
  const BusinessReportStatisticsCard({
    super.key,
    required this.icon,
    required this.titleAmount,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Get.isDarkMode
            ? Theme.of(context).cardColor.withValues(alpha: 0.5)
            : Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(icon, width: 35),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PriceConverter.convertPrice(
                  double.tryParse(titleAmount),
                  isShowLongPrice: true,
                ),
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                title.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault * 3),
        ],
      ),
    );
  }
}
