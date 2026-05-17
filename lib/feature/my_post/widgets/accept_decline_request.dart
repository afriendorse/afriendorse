/*
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class AcceptProviderRequestView extends StatelessWidget {
  final ProviderOfferData providerOfferData;
  final String postId;
  final int length;
  const AcceptProviderRequestView({
    super.key,
    required this.providerOfferData,
    required this.postId,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePostController>(
      builder: (createPostController) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              RouteHelper.getProviderOfferDetailsScreen(
                postId,
                providerOfferData,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
            ),
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
                    alignment: Get.find<LocalizationController>().isLtr
                        ? Alignment.topRight
                        : Alignment.topLeft,
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
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
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
                                  " ${providerOfferData.provider?.avgRating.toString() ?? ""}",
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
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
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
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
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
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Text(
                                PriceConverter.convertPrice(
                                  double.tryParse(
                                    providerOfferData.offeredPrice.toString(),
                                  ),
                                ),
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).colorScheme.primary,
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
                                onTap: () async {
                                  Get.dialog(
                                    ConfirmationDialog(
                                      icon: Images.ignore,
                                      title: 'decline'.tr,
                                      description:
                                          'do_you_want_to_decline_this_request'
                                              .tr,
                                      yesButtonText: 'decline',
                                      onYesPressed: () async {
                                        Get.back();
                                        Get.dialog(
                                          const CustomLoader(),
                                          barrierDismissible: false,
                                        );
                                        await createPostController
                                            .updatePostStatus(
                                              postId,
                                              providerOfferData.provider!.id!,
                                              'deny',
                                            );

                                        if (length > 1) {
                                          await createPostController
                                              .getProvidersOfferList(
                                                1,
                                                postId,
                                                reload: false,
                                              );
                                          Get.back();
                                        } else {
                                          Get.back();
                                          Get.offNamed(
                                            RouteHelper.getMyPostScreen(),
                                          );
                                        }
                                      },
                                    ),
                                    useSafeArea: true,
                                  );
                                },
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeExtraSmall,
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

                              GestureDetector(
                                onTap: () async {
                                  if (createPostController
                                      .checkProviderAvailability(
                                        providerData:
                                            providerOfferData.provider ??
                                            ProviderData(),
                                      )) {
                                    Get.toNamed(
                                      RouteHelper.getCustomPostCheckoutRoute(
                                        postId,
                                        providerOfferData.provider!.id!,
                                        providerOfferData.offeredPrice!,
                                        providerOfferData.id!,
                                      ),
                                    );
                                  } else {
                                    customSnackBar(
                                      "your_selected_provider_is_unavailable_right_now"
                                          .tr,
                                    );
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'accept'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Image.asset(Images.messageIcon, height: 22, width: 22),
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
*/

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class AcceptProviderRequestView extends StatelessWidget {
  final ProviderOfferData providerOfferData;
  final String postId;
  final int length;
  final bool isTargeted;

  const AcceptProviderRequestView({
    super.key,
    required this.providerOfferData,
    required this.postId,
    required this.length,
    this.isTargeted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePostController>(
      builder: (createPostController) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              RouteHelper.getProviderOfferDetailsScreen(
                postId,
                providerOfferData,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isTargeted
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Provider Image ───────────────────────────────────────
                    Hero(
                      tag: 'provider_${providerOfferData.provider?.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        child: CustomImage(
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          image: providerOfferData.provider?.logoFullPath ?? "",
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // ── Provider Info ────────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  providerOfferData.provider?.companyName ?? "",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTargeted)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'selected'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // ── Rating ─────────────────────────────────────────
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: const Color(0xFFFFB800),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${providerOfferData.provider?.avgRating?.toStringAsFixed(1) ?? '0.0'}",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${providerOfferData.provider?.ratingCount ?? '0'} ${'reviews'.tr})",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ── Price ────────────────────────────────────────────
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
                            child: Text(
                              PriceConverter.convertPrice(
                                double.tryParse(
                                  providerOfferData.offeredPrice.toString(),
                                ),
                              ),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // ── Action Buttons ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Get.dialog(
                            ConfirmationDialog(
                              icon: Images.ignore,
                              title: 'decline'.tr,
                              description:
                                  'do_you_want_to_decline_this_request'.tr,
                              yesButtonText: 'decline',
                              onYesPressed: () async {
                                Get.back();
                                Get.dialog(
                                  const CustomLoader(),
                                  barrierDismissible: false,
                                );
                                await createPostController.updatePostStatus(
                                  postId,
                                  providerOfferData.provider!.id!,
                                  'deny',
                                );

                                if (length > 1) {
                                  await createPostController
                                      .getProvidersOfferList(
                                        1,
                                        postId,
                                        reload: false,
                                      );
                                  Get.back();
                                } else {
                                  Get.back();
                                  Get.offNamed(RouteHelper.getMyPostScreen());
                                }
                              },
                            ),
                            useSafeArea: true,
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text('decline'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
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
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (createPostController.checkProviderAvailability(
                            providerData:
                                providerOfferData.provider ?? ProviderData(),
                          )) {
                            Get.toNamed(
                              RouteHelper.getCustomPostCheckoutRoute(
                                postId,
                                providerOfferData.provider!.id!,
                                providerOfferData.offeredPrice!,
                                providerOfferData.id!,
                              ),
                            );
                          } else {
                            customSnackBar(
                              "your_selected_provider_is_unavailable_right_now"
                                  .tr,
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: Text('accept'.tr),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
