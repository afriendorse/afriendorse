import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/provider_offer.dart';
import 'package:get/get.dart';

class OtherProviderOfferListItem extends StatelessWidget {
  final ProviderOfferData providerOfferData;
  const OtherProviderOfferListItem({
    super.key,
    required this.providerOfferData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImage(
              height: 65,
              width: 65,
              fit: BoxFit.cover,
              image: providerOfferData.provider?.logoFullPath ?? "",
            ),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerOfferData.provider?.companyName ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 10,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            providerOfferData.provider?.avgRating.toString() ??
                                "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        InkWell(
                          child: Text(
                            '${providerOfferData.provider?.ratingCount ?? "0"} ${'reviews'.tr}',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color!
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "price_offered".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          PriceConverter.convertPrice(
                            double.tryParse(
                              providerOfferData.offeredPrice?.toString() ?? "0",
                            ),
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
