import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceItem extends StatelessWidget {
  final ServiceModel service;
  const ServiceItem({super.key, required this.service});
  @override
  Widget build(BuildContext context) {
    final discount = PriceConverter.discountCalculation(service);

    num lowestPrice = 0.0;
    if (service.variations != null && service.variations!.isNotEmpty) {
      lowestPrice = service.variations![0].price!;
      for (var i = 0; i < service.variations!.length; i++) {
        if (service.variations![i].price! < lowestPrice) {
          lowestPrice = service.variations![i].price!;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        onTap: () => Get.to(
          ServiceDetailsScreen(serviceId: service.id!, discount: discount),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.radiusDefault),
                      ),
                      child: CustomImage(
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        image: service.thumbnailFullPath ?? "",
                      ),
                    ),
                    discount.discountAmount! > 0.0
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Center(
                                child: Text(
                                  PriceConverter.percentageCalculation(
                                    '',
                                    discount.discountAmount.toString(),
                                    discount.discountAmountType.toString(),
                                  ),
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: light.cardColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Text(
                            service.name.toString(),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        "start_form".tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                        ),
                      ),

                      if (discount.discountAmount! > 0)
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(lowestPrice.toDouble()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              decoration: TextDecoration.lineThrough,
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: .8),
                            ),
                          ),
                        ),
                      discount.discountAmount! > 0
                          ? Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice(
                                  lowestPrice.toDouble(),
                                  discount: discount.discountAmount!.toDouble(),
                                  discountType: discount.discountAmountType,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.paddingSizeDefault,
                                  color: Get.isDarkMode
                                      ? Theme.of(context).primaryColorLight
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice(
                                  lowestPrice.toDouble(),
                                ),
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Get.isDarkMode
                                      ? Theme.of(context).primaryColorLight
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ),
        ),
      ),
    );
  }
}
