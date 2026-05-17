/*
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ProviderOfferDetailsScreen extends StatelessWidget {
  final ProviderOfferData? providerOfferData;
  final String? postId;
  const ProviderOfferDetailsScreen({
    super.key,
    required this.providerOfferData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(title: "provider_offers".tr),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,

        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: FooterBaseView(
          child: WebShadowWrap(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    providerOfferData?.provider?.logoFullPath ??
                                    "",
                              ),
                            ),

                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerOfferData?.provider?.companyName ??
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
                                        " ${providerOfferData?.provider?.avgRating ?? ""}",
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
                                        '${providerOfferData?.provider?.ratingCount ?? ""} ${'reviews'.tr}',
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
                                          providerOfferData?.offeredPrice ??
                                              "0",
                                        ),
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Text(
                          "description".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          providerOfferData?.providerNote ?? "",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: GestureDetector(
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
                                        await Get.find<CreatePostController>()
                                            .updatePostStatus(
                                              postId ?? "",
                                              providerOfferData?.provider?.id ??
                                                  "",
                                              'deny',
                                            );
                                        Get.back();
                                        Get.offAllNamed(
                                          RouteHelper.getMyPostScreen(),
                                        );
                                      },
                                    ),
                                    useSafeArea: true,
                                  );
                                },
                                child: Container(
                                  height: 35,
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
                            ),

                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (Get.find<CreatePostController>()
                                      .checkProviderAvailability(
                                        providerData:
                                            providerOfferData?.provider ??
                                            ProviderData(),
                                      )) {
                                    Get.toNamed(
                                      RouteHelper.getCustomPostCheckoutRoute(
                                        postId ?? "",
                                        providerOfferData?.provider?.id ?? "",
                                        providerOfferData?.offeredPrice ?? "",
                                        providerOfferData?.id ?? "",
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
                                  height: 35,
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
                            ),
                          ],
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
*/

import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ProviderOfferDetailsScreen extends StatelessWidget {
  final ProviderOfferData? providerOfferData;
  final String? postId;
  const ProviderOfferDetailsScreen({
    super.key,
    required this.providerOfferData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = providerOfferData?.provider;

    return CustomPopWidget(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "offer_details".tr,
          isBackButtonExist: true,
        ),
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        body: FooterBaseView(
          child: WebShadowWrap(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  // ── Provider Profile Card ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Header with Image ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'provider_${provider?.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  child: CustomImage(
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    image: provider?.logoFullPath ?? "",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider?.companyName ?? "",
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: const Color(
                                                    0xFFFFB800,
                                                  ),
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

                        const Divider(height: 1),

                        // ── Price Section ───────────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "offered_price".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                PriceConverter.convertPrice(
                                  double.tryParse(
                                    providerOfferData?.offeredPrice ?? "0",
                                  ),
                                ),
                                style: robotoBold.copyWith(
                                  fontSize: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ── Description ─────────────────────────────────────────
                        if (providerOfferData?.providerNote?.isNotEmpty ??
                            false)
                          Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "provider_note".tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  child: Text(
                                    providerOfferData!.providerNote!,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color!
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // ── Action Buttons ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Get.dialog(
                              ConfirmationDialog(
                                icon: Images.ignore,
                                title: 'decline_offer'.tr,
                                description: 'decline_offer_confirmation'.tr,
                                yesButtonText: 'decline',
                                onYesPressed: () async {
                                  Get.back();
                                  Get.dialog(
                                    const CustomLoader(),
                                    barrierDismissible: false,
                                  );
                                  await Get.find<CreatePostController>()
                                      .updatePostStatus(
                                        postId ?? "",
                                        provider?.id ?? "",
                                        'deny',
                                      );
                                  Get.back();
                                  Get.offAllNamed(
                                    RouteHelper.getMyPostScreen(),
                                  );
                                },
                              ),
                              useSafeArea: true,
                            );
                          },
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.error,
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (Get.find<CreatePostController>()
                                .checkProviderAvailability(
                                  providerData: provider ?? ProviderData(),
                                )) {
                              Get.toNamed(
                                RouteHelper.getCustomPostCheckoutRoute(
                                  postId ?? "",
                                  provider!.id!,
                                  providerOfferData?.offeredPrice ?? "",
                                  providerOfferData?.id ?? "",
                                ),
                              );
                            } else {
                              customSnackBar(
                                "your_selected_provider_is_unavailable_right_now"
                                    .tr,
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: Text(
                            'accept_offer'.tr,
                            style: robotoBold.copyWith(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
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
