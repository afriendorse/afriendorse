import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class EmptyFAQWidget extends StatelessWidget {
  const EmptyFAQWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
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
                Images.help,
                scale: Dimensions.paddingSizeSmall,
                color: Get.isDarkMode
                    ? Theme.of(context).primaryColorLight
                    : null,
                fit: BoxFit.cover,
                height: 60,
                width: 60,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                "no_faq_found".tr,
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
      ),
    );
  }
}
