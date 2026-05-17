/*

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class MyPostView extends StatelessWidget {
  final MyPostData? postData;
  const MyPostView({super.key, this.postData});

  @override
  Widget build(BuildContext context) {
    String status = "null";
    String bookingStatus = "null";

    if (postData!.booking != null && postData!.booking!.bookingStatus != null) {
      bookingStatus = postData!.booking!.bookingStatus!;
    }

    if (postData!.isBooked == 0 && postData!.bidsCount! > 0) {
      status = "bid_available";
    } else if (postData!.isBooked == 0 && postData!.bidsCount == 0) {
      status = "no_bid";
    } else if (postData!.isBooked == 1) {
      status = "bid_accepted";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: GestureDetector(
        onTap: () {
          if (status == "bid_available") {
            Get.toNamed(
              RouteHelper.getProviderOfferListScreen(
                postData?.id ?? "",
                status,
                postData!,
              ),
            );
          } else if (status == "bid_accepted" && postData!.booking != null) {
            Get.toNamed(
              RouteHelper.getBookingDetailsScreen(
                bookingID: postData!.booking!.id,
              ),
            );
          } else if (status == "no_bid") {
            Get.toNamed(
              RouteHelper.getProviderOfferListScreen(
                postData?.id ?? "",
                status,
                postData!,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: status == "bid_available"
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : status == "no_bid"
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),

          child: Stack(
            alignment: Get.find<LocalizationController>().isLtr
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (postData!.booking != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      child: Text(
                        '${'booking'.tr}# ${postData?.booking?.readableId ?? ""}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
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
                          image: postData?.service?.thumbnailFullPath ?? "",
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postData?.service?.name ?? "",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeEight,
                              ),
                              child: Text(
                                postData?.subCategory?.name ?? "",
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

                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeEight,
                              ),
                              child: Text(
                                status == "no_bid"
                                    ? "no_provider_bid_for_post".tr
                                    : status == "bid_available"
                                    ? "${postData?.bidsCount ?? ""} ${'provider_are_interested'.tr}"
                                    : postData?.booking?.bookingStatus
                                              .toString()
                                              .tr ??
                                          "",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: bookingStatus == "ongoing"
                                      ? Theme.of(context).colorScheme.primary
                                      : bookingStatus == "pending"
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: .2)
                                      : bookingStatus == "accepted"
                                      ? Theme.of(context).colorScheme.primary
                                      : bookingStatus == "completed"
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (status == "bid_available")
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(Images.personIcon, height: 30, width: 30),
                    Positioned(
                      top: -9,
                      right: -9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        height: 17,
                        width: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        child: FittedBox(
                          child: Text(
                            postData!.bidsCount.toString(),
                            style: robotoRegular.copyWith(
                              color: light.cardColor,
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
      ),
    );
  }
}

*/

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class MyPostView extends StatelessWidget {
  final MyPostData? postData;

  const MyPostView({super.key, this.postData});

  @override
  Widget build(BuildContext context) {
    String status = "null";
    String bookingStatus = "null";

    if (postData!.booking != null && postData!.booking!.bookingStatus != null) {
      bookingStatus = postData!.booking!.bookingStatus!;
    }

    // Check if this is a targeted post
    final bool isTargetedPost =
        postData?.targetProviderId != null &&
        postData!.targetProviderId!.isNotEmpty;

    if (postData!.isBooked == 0 && postData!.bidsCount! > 0) {
      status = "bid_available";
    } else if (postData!.isBooked == 0 && postData!.bidsCount == 0) {
      status = "no_bid";
    } else if (postData!.isBooked == 1) {
      status = "bid_accepted";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: GestureDetector(
        onTap: () {
          if (status == "bid_available") {
            Get.toNamed(
              RouteHelper.getProviderOfferListScreen(
                postData?.id ?? "",
                status,
                postData!,
              ),
            );
          } else if (status == "bid_accepted" && postData!.booking != null) {
            Get.toNamed(
              RouteHelper.getBookingDetailsScreen(
                bookingID: postData!.booking!.id,
              ),
            );
          } else if (status == "no_bid") {
            Get.toNamed(
              RouteHelper.getProviderOfferListScreen(
                postData?.id ?? "",
                status,
                postData!,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: status == "bid_available"
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : status == "no_bid"
                  ? isTargetedPost
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Stack(
            alignment: Get.find<LocalizationController>().isLtr
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (postData!.booking != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      child: Text(
                        '${'booking'.tr}# ${postData?.booking?.readableId ?? ""}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
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
                          image: postData?.service?.thumbnailFullPath ?? "",
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postData?.service?.name ?? "",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeEight,
                              ),
                              child: Text(
                                postData?.subCategory?.name ?? "",
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

                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeEight,
                              ),
                              child: Text(
                                // ── UPDATED STATUS TEXT LOGIC ─────────────────
                                isTargetedPost && status == "no_bid"
                                    ? "awaiting_athlete_bid".tr
                                    : !isTargetedPost && status == "no_bid"
                                    ? "no_provider_bid_for_post".tr
                                    : isTargetedPost &&
                                          status == "bid_available"
                                    ? "${postData?.targetProvider?.companyName ?? postData?.targetProvider?.owner?.firstName ?? 'Athlete'} ${'has_shown_interest'.tr}"
                                    : !isTargetedPost &&
                                          status == "bid_available"
                                    ? "${postData?.bidsCount ?? ""} ${'provider_are_interested'.tr}"
                                    : postData?.booking?.bookingStatus
                                              .toString()
                                              .tr ??
                                          "",
                                // ── END UPDATED STATUS TEXT ───────────────────
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  // ── UPDATED COLOR LOGIC ─────────────────────
                                  color: isTargetedPost && status == "no_bid"
                                      ? Colors
                                            .black // Awaiting athlete bid = Black
                                      : !isTargetedPost && status == "no_bid"
                                      ? Theme.of(context)
                                            .colorScheme
                                            .error // No provider bid = Red
                                      : isTargetedPost &&
                                            status == "bid_available"
                                      ? Colors
                                            .green // Athlete has shown interest = Green
                                      : !isTargetedPost &&
                                            status == "bid_available"
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primary // Providers interested = Primary
                                      : bookingStatus == "ongoing"
                                      ? Theme.of(context).colorScheme.primary
                                      : bookingStatus == "pending"
                                      ? Theme.of(context).colorScheme.primary
                                            .withValues(alpha: .2)
                                      : bookingStatus == "accepted"
                                      ? Theme.of(context).colorScheme.primary
                                      : bookingStatus == "completed"
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                  // ── END UPDATED COLOR LOGIC ─────────────────
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (status == "bid_available")
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(Images.personIcon, height: 30, width: 30),
                    Positioned(
                      top: -9,
                      right: -9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        height: 17,
                        width: 17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        child: FittedBox(
                          child: Text(
                            postData!.bidsCount.toString(),
                            style: robotoRegular.copyWith(
                              color: light.cardColor,
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
      ),
    );
  }
}
