import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceShimmer extends StatelessWidget {
  const ServiceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Container(
          padding: ResponsiveHelper.isDesktop(context)
              ? const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeLarge,
                )
              : const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: Get.isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                height: 15,
                width: double.maxFinite,
                color: Theme.of(context).shadowColor,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Container(
                height: 10,
                width: double.maxFinite,
                color: Theme.of(context).shadowColor,
                margin: const EdgeInsets.only(
                  right: Dimensions.paddingSizeLarge,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                children: [
                  Container(
                    height: 10,
                    width: 30,
                    color: Theme.of(context).shadowColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Container(
                    height: 10,
                    width: 20,
                    color: Theme.of(context).shadowColor,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        ),
      ),
    );
  }
}
