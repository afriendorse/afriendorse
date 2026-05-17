import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CustomerBookingAcceptView extends StatelessWidget {
  final PostData postData;
  final bool newRequest; // Add this line

  const CustomerBookingAcceptView({
    super.key,
    required this.postData,
    required this.newRequest, // Add this line
  });

  /// True when the brand targeted this specific athlete directly.
  bool get _isDirectDeal =>
      postData.targetProviderId != null &&
      postData.targetProviderId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<PostController>(
      builder: (postController) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          child: Slidable(
            key: ValueKey(postData.id ?? ''),
            closeOnScroll: false,
            endActionPane: newRequest
                ? ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: null,
                    extentRatio: 0.4,
                    children: [
                      CustomSlidableAction(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        flex: 1,
                        onPressed: (context) {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return ConfirmationDialog(
                                icon: Images.ignore,
                                title: 'ignore'.tr,
                                description:
                                    'do_you_want_to_ignore_this_post'.tr,
                                onYesPressed: () async {
                                  Get.back();
                                  showCustomDialog(child: const CustomLoader());
                                  await Get.find<PostController>()
                                      .rejectCustomerPost(postData.id!);
                                  Get.back();
                                },
                              );
                            },
                          );
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(Dimensions.radiusSmall),
                          bottomRight: Radius.circular(Dimensions.radiusSmall),
                        ),
                        child: Image.asset(
                          Images.ignore,
                          height: 27,
                          width: 27,
                        ),
                      ),
                    ],
                  )
                : null,

            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  // Direct deals get a subtle primary-tinted border
                  color: _isDirectDeal
                      ? primary.withValues(alpha: 0.35)
                      : primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  // ── Top row: avatar + name + direct-deal badge ─────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          child: CustomImage(
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            image:
                                postData.customer?.profileImageFullPath ?? "",
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${postData.customer?.firstName ?? ""} ${postData.customer?.lastName ?? ""}",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              /*    const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                "${postData.distance ?? "0 km"} ${'away_from_you'.tr}",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.4),
                                ),
                              ), */
                            ],
                          ),
                        ),

                        // Direct deal badge (top-right)
                        if (_isDirectDeal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 12,
                                  color: primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "direct_deal".tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  Divider(color: primary.withValues(alpha: 0.2), height: 1),

                  // ── Date row ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault,
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Images.calenderOutline,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Text(
                          DateConverter.dateMonthYearTime(
                            DateConverter.isoUtcStringToLocalDate(
                              postData.createdAt!,
                            ),
                          ),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: 0.8),
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),

                  // ── Service row + action button ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          child: CustomImage(
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                            image: postData.service?.thumbnailFullPath ?? "",
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                postData.service?.name ?? "",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall - 2,
                              ),
                              Text(
                                postData.subCategory?.name ?? "",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // Action button
                        GestureDetector(
                          onTap: () async {
                            if (newRequest) {
                              Get.to(
                                () => CustomerPostDetailsScreen(
                                  postData: postData,
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return ConfirmationDialog(
                                    icon: Images.ignore,
                                    title: 'withdraw'.tr,
                                    description:
                                        'do_you_want_to_withdraw_you_bid'.tr,
                                    onYesPressed: () async {
                                      Get.back();
                                      showCustomDialog(
                                        child: const CustomLoader(),
                                      );
                                      await postController.withdrawBidRequest(
                                        postData.id!,
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              color: primary,
                            ),
                            child: Center(
                              child: Text(
                                newRequest
                                    ? 'place_offer'.tr
                                    : 'withdraw_bid'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
