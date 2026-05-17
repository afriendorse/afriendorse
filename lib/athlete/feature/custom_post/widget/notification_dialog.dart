import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class NotificationDialog extends StatelessWidget {
  final PostData? postData;
  const NotificationDialog({super.key, this.postData});

  bool get _isDirectDeal =>
      postData?.targetProviderId != null &&
      postData!.targetProviderId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: 30,
      ),
      child: GestureDetector(
        onTap: Get.back,
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(
                    () => CustomerPostDetailsScreen(
                      postData: postData ?? PostData(),
                      fromNotification: true,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
                        // ── Close button ──────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Direct deal badge (shown inline in header)
                            if (_isDirectDeal)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
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
                                      size: 13,
                                      color: primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "direct_deal".tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox.shrink(),

                            InkWell(
                              onTap: Get.back,
                              child: const Icon(
                                Icons.highlight_remove,
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        // ── Customer section ──────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "new_booking_request_from".tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                child: CustomImage(
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  image:
                                      postData
                                          ?.customer
                                          ?.profileImageFullPath ??
                                      "",
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  Dimensions.paddingSizeDefault,
                                  0,
                                  Dimensions.paddingSizeExtraSmall - 2,
                                ),
                                child: Text(
                                  "${postData?.customer?.firstName ?? " "} ${postData?.customer?.lastName ?? " "}",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ),
                              /*  Text(
                                "${postData?.distance ?? "0 km"} ${'away_from_you'.tr}",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(
                                    context,
                                  ).secondaryHeaderColor.withValues(alpha: 0.8),
                                ),
                              ), */
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),

                        // ── Service row ───────────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              child: CustomImage(
                                image:
                                    postData?.service?.thumbnailFullPath ?? "",
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeLarge),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    postData?.service?.name ?? "",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    postData?.subCategory?.name ?? "",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor
                                          .withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ── Direct deal note ──────────────────────────────────
                        if (_isDirectDeal) ...[
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 15,
                                  color: primary,
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                Expanded(
                                  child: Text(
                                    "this_brand_sent_you_a_direct_deal".tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
