import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessReportStatisticsCard2 extends StatelessWidget {
  final bool withCurrencySymbol;
  final String icon;
  final String titleAmount;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String? subtitle3;
  final String? subtitle4;
  final String subtitleAmount1;
  final String subtitleAmount2;
  final String? subtitleAmount3;
  final String? subtitleAmount4;

  const BusinessReportStatisticsCard2({
    super.key,
    required this.icon,
    required this.titleAmount,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    this.subtitle3,
    required this.subtitleAmount1,
    required this.subtitleAmount2,
    this.subtitleAmount3,
    required this.withCurrencySymbol,
    this.subtitle4,
    this.subtitleAmount4,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, width: 35),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    withCurrencySymbol
                        ? PriceConverter.convertPrice(
                            double.tryParse(titleAmount),
                          )
                        : titleAmount,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                    ),
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
              //SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT,),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SubTitleView(
                amount: subtitleAmount1,
                subTitle: subtitle1,
                titleColor: Theme.of(context).colorScheme.error,
                withCurrencySymbol: withCurrencySymbol,
              ),
              SubTitleView(
                amount: subtitleAmount2,
                subTitle: subtitle2,
                titleColor: Theme.of(context).primaryColorLight,
                withCurrencySymbol: withCurrencySymbol,
              ),
              if (subtitle3 != null)
                SubTitleView(
                  amount: subtitleAmount3 != null ? subtitleAmount3! : '0',
                  subTitle: subtitle3!,
                  titleColor: Colors.blue,
                  withCurrencySymbol: withCurrencySymbol,
                ),

              if (subtitle4 != null)
                SubTitleView(
                  amount: subtitleAmount4 != null ? subtitleAmount4! : '0',
                  subTitle: subtitle4!,
                  titleColor: Colors.green,
                  withCurrencySymbol: withCurrencySymbol,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubTitleView extends StatelessWidget {
  final String amount;
  final String subTitle;
  final Color titleColor;
  final bool withCurrencySymbol;
  const SubTitleView({
    super.key,
    required this.amount,
    required this.subTitle,
    required this.titleColor,
    required this.withCurrencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeSmall),
      child: Column(
        children: [
          Text(
            withCurrencySymbol
                ? PriceConverter.convertPrice(
                    double.tryParse(amount),
                    isShowLongPrice: true,
                  )
                : amount,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: titleColor.withValues(alpha: 0.8),
            ),
          ),

          Text(
            subTitle.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
