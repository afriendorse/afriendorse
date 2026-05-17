import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubscriptionItemShimmer extends StatelessWidget {
  const SubscriptionItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                        ),
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
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
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Get.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 5,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                        ),

                        const Expanded(flex: 1, child: SizedBox()),

                        Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
