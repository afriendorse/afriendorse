import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReviewHeading extends StatelessWidget {
  final Rating? rating;
  final bool showTitle;
  const ReviewHeading({
    super.key,
    required this.rating,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Row(
            children: [
              Text(
                "your_review_rating".tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 1),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              CustomToolTip(
                message: "avg_review_tooltip_hint_text".tr,
                iconColor: Theme.of(context).primaryColor,
                preferredDirection: AxisDirection.down,
              ),
            ],
          ),
        if (showTitle) const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          width: Get.width,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: context.customThemeColors.cardShadow,
          ),
          child: Column(
            children: [
              Text(
                "${rating?.averageRating ?? "0.0"}",
                style: robotoBold.copyWith(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 30,
                ),
              ),
              RatingBar(rating: rating?.averageRating ?? 0, size: 22),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${rating?.ratingCount ?? "0"} ${'ratings'.tr}",
                    style: robotoRegular.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: .6),
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    "${rating?.reviewCount ?? "0"} ${'reviews'.tr}",
                    style: robotoRegular.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: .6),
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
