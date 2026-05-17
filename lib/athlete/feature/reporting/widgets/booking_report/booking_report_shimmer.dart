import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BookingReportShimmer extends StatelessWidget {
  const BookingReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Padding(
          padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeSmall,
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 130,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeSmall,
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20,
                                width: 25,
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
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: 10,
                                width: 75,
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
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 20,
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
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Container(
                                height: 10,
                                width: 70,
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

                          Column(
                            children: [
                              Container(
                                height: 20,
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
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Container(
                                height: 10,
                                width: 70,
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

                          Column(
                            children: [
                              Container(
                                height: 20,
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
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Container(
                                height: 10,
                                width: 70,
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

                          Column(
                            children: [
                              Container(
                                height: 20,
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
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Container(
                                height: 10,
                                width: 70,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                height: 300,
                width: double.infinity,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall,
                        top: Dimensions.paddingSizeSmall,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              color: Get.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Container(
                            height: 30,
                            width: 100,
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
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 10,
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
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 2,
                                  width: 300,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 10,
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
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 2,
                                  width: 300,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 10,
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
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 2,
                                  width: 300,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 10,
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
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 2,
                                  width: 300,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                  height: 10,
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
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Container(
                                  height: 2,
                                  width: 300,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeDefault,
                      ),
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeDefault,
                        left: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 25,
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
                                width: Dimensions.paddingSizeDefault,
                              ),

                              Container(
                                height: 20,
                                width: 80,
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
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Container(
                            height: 20,
                            width: 120,
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 20,
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

                              Container(
                                height: 20,
                                width: 50,
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
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 20,
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

                              Container(
                                height: 20,
                                width: 50,
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
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 20,
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

                              Container(
                                height: 20,
                                width: 50,
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
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: Dimensions.paddingSizeSmall);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
