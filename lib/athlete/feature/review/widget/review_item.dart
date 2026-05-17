import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  final Color? backgroundColor;
  final String? fromPage;
  const ReviewItem({
    super.key,
    required this.review,
    this.backgroundColor,
    this.fromPage,
  });

  @override
  Widget build(BuildContext context) {
    var config = Get.find<SplashController>().configModel.content;

    List<String> variationName = [];

    review.booking?.detail?.forEach((element) {
      if (review.serviceId == element.serviceId) {
        variationName.add(element.variantKey ?? '');
      }
    });
    String variation = variationName
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');

    return Container(
      decoration: BoxDecoration(
        color: review.isActive == 0
            ? Theme.of(
                context,
              ).disabledColor.withValues(alpha: Get.isDarkMode ? 0.3 : 0.1)
            : backgroundColor ??
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.05),
          hoverColor: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          onTap: () => Get.toNamed(
            RouteHelper.getBookingDetailsRoute(
              bookingId: review.bookingId!,
              fromPage: "others",
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'review_id'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Expanded(
                              child: Text(
                                '${(review.readableId != null && review.readableId != 0) ? review.readableId : "N/A"}',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Text(
                          DateConverter.dateMonthYearTime(
                            DateConverter.isoUtcStringToLocalDate(
                              review.updatedAt!,
                            ),
                          ),
                          style: robotoRegular.copyWith(
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.8),
                            fontSize: Dimensions.fontSizeSmall + 1,
                          ),
                          textDirection: TextDirection.ltr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),

                      SizedBox(
                        width: review.isActive == 0
                            ? Dimensions.paddingSizeExtraSmall
                            : 0,
                      ),
                      review.isActive == 0
                          ? CustomToolTip(
                              message: "admin_turn_off_this_review".tr,
                              iconColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.7),
                              size: 18,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),

                Divider(
                  height: 0.4,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    if (review.customer != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(50),
                        ),
                        child: CustomImage(
                          height: 60,
                          width: 60,
                          image: "${review.customer?.profileImageFullPath}",
                          placeholder: Images.userPlaceHolder,
                        ),
                      ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          review.customer != null
                              ? Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${review.customer?.firstName ?? ""} ${review.customer?.lastName ?? ""}",
                                        style: robotoMedium.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withValues(alpha: 1),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1.5,
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                        size: 15,
                                      ),
                                    ),
                                    Text(
                                      review.reviewRating!.toString(),
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                  ],
                                )
                              : Text(
                                  "customer_not_available".tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: .6),
                                  ),
                                ),
                          const SizedBox(height: 3),

                          Row(
                            children: [
                              Text(
                                "booking_id".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),

                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                " # ${review.booking?.readableId ?? ""}",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            fromPage == "service" && variation.isNotEmpty
                                ? variation
                                : review.service?.name ?? "",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (review.reviewComment != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          review.reviewComment ?? "",
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.6),
                            fontSize: Dimensions.fontSizeSmall + 1,
                          ),
                          textAlign: TextAlign.justify,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getReviewReplyScreen(
                              review: review,
                              fromPage: fromPage,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.6,
                            ),
                            color: review.isActive == 0
                                ? Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.01)
                                : Theme.of(context).cardColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                            vertical: 6,
                          ),
                          child: Text(
                            config?.providerCanReplyReview == 0
                                ? "view".tr
                                : review.reviewReply != null
                                ? "edit_reply".tr
                                : "reply".tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
