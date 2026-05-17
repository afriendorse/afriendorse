import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SuggestServiceListShimmer extends StatelessWidget {
  const SuggestServiceListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.paddingSizeDefault,
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeDefault,
                ),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeDefault,
                ),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeSmall,
                  top: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      horizontalTitleGap: 0,
                      leading: Container(
                        height: 40,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),

                      title: Container(
                        height: 40,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),

                      trailing: Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: Container(
                          height: 40,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 30,
                        width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeDefault,
                ),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeSmall,
                  top: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      horizontalTitleGap: 0,
                      leading: Container(
                        height: 40,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),

                      title: Container(
                        height: 40,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),

                      trailing: Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: Container(
                          height: 40,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 30,
                        width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
