import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubCategoryItemShimmer extends StatelessWidget {
  const SubCategoryItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            right: Dimensions.paddingSizeDefault,
            left: 5,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              height: 162,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 25,
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 10,
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: 10,
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: Dimensions.paddingSizeSmall,
                              width: Dimensions.paddingSizeLarge * 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Divider(
                      height: 2,
                      thickness: 1,
                      color: Get.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeLarge * 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),

                        Container(
                          height: Dimensions.paddingSizeExtraLarge + 5,
                          width: Dimensions.paddingSizeLarge * 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: Dimensions.paddingSizeSmall);
      },
      itemCount: 10,
    );
  }
}
