import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class NotificationSetupShimmer extends StatelessWidget {
  const NotificationSetupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall - 3,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              height: 120,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeSmall,
                ),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 12,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      height: 12,
                      width: 170,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: 18,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: 18,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),

                            Container(
                              height: 18,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
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
      shrinkWrap: true,
      itemCount: 10,
    );
  }
}
