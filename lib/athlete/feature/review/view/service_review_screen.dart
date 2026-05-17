import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceDetailsReview extends StatelessWidget {
  const ServiceDetailsReview({
    super.key,
    required this.reviewList,
    this.rating,
    required this.scrollController,
    this.serviceName,
  });

  final List<Review> reviewList;
  final Rating? rating;
  final ScrollController scrollController;
  final String? serviceName;

  @override
  Widget build(BuildContext context) {
    if (reviewList.isNotEmpty || (rating?.reviewCount ?? 0) > 0) {
      return SliverToBoxAdapter(
        child: Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            constraints: ResponsiveHelper.isDesktop(context)
                ? BoxConstraints(
                    minHeight:
                        !ResponsiveHelper.isDesktop(context) &&
                            Get.size.height < 600
                        ? Get.size.height
                        : Get.size.height - 550,
                  )
                : null,
            color: Theme.of(context).cardColor,

            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  ReviewHeading(rating: rating),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  if (rating != null) ReviewLinearChart(rating: rating!),

                  const Divider(),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    "my_reviews".tr,
                    style: robotoMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  reviewList.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviewList.length,
                          itemBuilder: (context, index) {
                            return ReviewItem(
                              review: reviewList.elementAt(index),
                              fromPage: "service",
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraMoreLarge * 2,
                          ),
                          child: Center(
                            child: Text(
                              'you_have_not_review_yet'.tr,
                              style: robotoLight,
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
    return const SliverToBoxAdapter(child: EmptyReviewWidget());
  }
}
