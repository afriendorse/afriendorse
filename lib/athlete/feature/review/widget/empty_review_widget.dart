import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class EmptyReviewWidget extends StatelessWidget {
  const EmptyReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Dimensions.webMaxWidth,
        color: Theme.of(context).cardColor,
        constraints: ResponsiveHelper.isDesktop(context)
            ? BoxConstraints(
                minHeight:
                    !ResponsiveHelper.isDesktop(context) &&
                        Get.size.height < 600
                    ? Get.size.height
                    : Get.size.height - 550,
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50.0),
            Image.asset(
              Images.emptyReview,
              scale: Dimensions.paddingSizeSmall,
              color: Get.isDarkMode
                  ? Theme.of(context).primaryColorLight
                  : null,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(
              "no_review_yet".tr,
              style: robotoMedium.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge!.color!.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ),
      ),
    );
  }
}
