import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PriceTableScreen extends StatelessWidget {
  const PriceTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceDetailsController>(
      builder: (serviceDetailsController) {
        return SliverToBoxAdapter(
          child: Container(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${serviceDetailsController.variantList.length}",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          Text(
                            'variant_available'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Get.isDarkMode
                                  ? Theme.of(context).primaryColorLight
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Divider(
                              thickness: 1,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.2),
                            ),
                          );
                        },

                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  serviceDetailsController
                                      .variantList[index]
                                      .variantName
                                      .replaceAll('-', ' ')
                                      .capitalizeFirst!,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Get.isDarkMode
                                        ? Theme.of(context).primaryColorLight
                                        : Colors.black.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),

                              Text(
                                PriceConverter.convertPrice(
                                  double.tryParse(
                                    serviceDetailsController
                                        .variantList[index]
                                        .price
                                        .toString(),
                                  ),
                                ),
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          );
                        },

                        itemCount: serviceDetailsController.variantList.length,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
