/*
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ProviderBiddingNotificationDialog extends StatelessWidget {
  final ProviderOfferData providerOfferData;
  final String postId;
  const ProviderBiddingNotificationDialog({
    super.key,
    required this.providerOfferData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: 40,
      ),
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Get.back();
              Get.toNamed(
                RouteHelper.getProviderOfferDetailsScreen(
                  postId,
                  providerOfferData,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.highlight_remove, size: 20),
                              ],
                            ),
                            onTap: () => Get.back(),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                child: CustomImage(
                                  height: 65,
                                  width: 65,
                                  fit: BoxFit.cover,
                                  image:
                                      providerOfferData
                                          .provider
                                          ?.logoFullPath ??
                                      "",
                                ),
                              ),

                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      providerOfferData.provider?.companyName ??
                                          "",
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 10,
                                        ),
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Text(
                                            " ${providerOfferData.provider?.avgRating.toString() ?? ""}",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: Dimensions.paddingSizeSmall,
                                        ),
                                        InkWell(
                                          child: Text(
                                            '${providerOfferData.provider?.ratingCount ?? "0"} ${'reviews'.tr}',
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
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
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "price_offered".tr,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: Dimensions.paddingSizeSmall,
                                        ),
                                        Text(
                                          PriceConverter.convertPrice(
                                            double.tryParse(
                                                  providerOfferData
                                                          .offeredPrice ??
                                                      "0",
                                                ) ??
                                                0,
                                          ),
                                          style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.back();
                                            Get.find<CreatePostController>()
                                                .updatePostStatus(
                                                  postId,
                                                  providerOfferData
                                                      .provider!
                                                      .id!,
                                                  'deny',
                                                );
                                          },
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusSmall,
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            child: Center(
                                              child: Text(
                                                'decline'.tr,
                                                style: robotoRegular.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: Dimensions.paddingSizeSmall,
                                        ),
                                        CustomButton(
                                          buttonText: 'accept'.tr,
                                          width: 80,
                                          height: 30,
                                          radius: Dimensions.radiusSmall,
                                          onPressed: () {
                                            Get.back();
                                            Get.toNamed(
                                              RouteHelper.getCustomPostCheckoutRoute(
                                                postId,
                                                providerOfferData.provider!.id!,
                                                providerOfferData.offeredPrice!,
                                                providerOfferData.id!,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ProviderBiddingNotificationDialog extends StatelessWidget {
  final ProviderOfferData providerOfferData;
  final String postId;
  const ProviderBiddingNotificationDialog({
    super.key,
    required this.providerOfferData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = providerOfferData.provider;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: 40,
      ),
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // Prevent tap through
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header with close ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'new_bid'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Provider Info ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          child: CustomImage(
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            image: provider?.logoFullPath ?? "",
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider?.companyName ?? "",
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFB800,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFFFB800),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${provider?.avgRating?.toStringAsFixed(1) ?? '0.0'}",
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: const Color(0xFFFFB800),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${provider?.ratingCount ?? '0'} ${'reviews'.tr})",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // ── Price ───────────────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "offered".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          PriceConverter.convertPrice(
                            double.tryParse(
                                  providerOfferData.offeredPrice ?? "0",
                                ) ??
                                0,
                          ),
                          style: robotoBold.copyWith(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // ── Actions ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.find<CreatePostController>().updatePostStatus(
                                postId,
                                provider!.id!,
                                'deny',
                              );
                            },
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.error,
                              size: 18,
                            ),
                            label: Text('decline'.tr),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(
                                RouteHelper.getProviderOfferDetailsScreen(
                                  postId,
                                  providerOfferData,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: Text('view_details'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
