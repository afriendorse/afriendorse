import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class VariantBottomSheet extends StatefulWidget {
  const VariantBottomSheet({super.key});

  @override
  State<VariantBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<VariantBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        insetPadding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: pointerInterceptor(),
      );
    }
    return pointerInterceptor();
  }

  pointerInterceptor() {
    return GetBuilder<ServiceDetailsController>(
      builder: (serviceDetailsController) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),

          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, size: 25),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImage(
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  image:
                      serviceDetailsController
                          .serviceDetailsModel
                          ?.content
                          ?.thumbnailFullPath ??
                      "",
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Text(
                  serviceDetailsController.serviceDetailsModel!.content!.name!,
                  style: robotoMedium.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              /*  Text(
                "${serviceDetailsController.variantList.length}  ${'variation_available'.tr}",
                style: robotoRegular.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                ),
                maxLines: 2,
              ), */
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                        left: 2,
                        right: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ],
                        color: Get.isDarkMode
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Theme.of(context).cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              serviceDetailsController
                                  .variantList[index]
                                  .variantName
                                  .replaceAll('-', ' ')
                                  .capitalizeFirst!,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.6),
                              ),
                              //maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Text(
                            PriceConverter.convertPrice(
                              double.tryParse(
                                serviceDetailsController
                                    .variantList[index]
                                    .price
                                    .toString(),
                              ),
                            ),
                            style: robotoMedium.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: serviceDetailsController.variantList.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
