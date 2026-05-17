import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceManDetailsShimmer extends StatelessWidget {
  const ServiceManDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).hintColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    height: 15,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            height: 100,
            width: double.infinity,
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      height: 5,
                      width: 40,
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

                Container(
                  height: 70,
                  width: 2,
                  color: Get.isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      height: 5,
                      width: 40,
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

                Container(
                  height: 70,
                  width: 2,
                  color: Get.isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade100,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      height: 5,
                      width: 40,
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
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeLarge,
                      top: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Container(
                          height: 15,
                          width: 180,
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
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Get.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeLarge,
                      top: Dimensions.paddingSizeLarge,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Container(
                          height: 15,
                          width: 180,
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
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Get.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeLarge,
                      top: Dimensions.paddingSizeLarge,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),

                        Container(
                          height: 15,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
