import 'dart:math';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BookingDetailsShimmer extends StatelessWidget {
  const BookingDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Get.width,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Dimensions.paddingSizeExtraLarge + 5,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: Dimensions.paddingSizeLarge,
                                width: 220,
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Container(
                            height: Dimensions.paddingSizeLarge,
                            width: 80,
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
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: Dimensions.paddingSizeLarge,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: Dimensions.paddingSizeLarge,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                ),
                child: Container(
                  height: Dimensions.paddingSizeExtraLarge + 15,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                width: Get.width,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      Container(
                        height: Dimensions.paddingSizeExtraLarge * 2,
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),

                              Container(
                                width: Dimensions.paddingSizeExtraLarge * 2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const HorizontalRow(),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),

                                Container(
                                  height: Dimensions.paddingSizeSmall,
                                  width: Dimensions.paddingSizeExtraLarge * 2,
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
                                  height: Dimensions.paddingSizeSmall,
                                  width: 80,
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
                          );
                        },
                        itemCount: 2,
                      ),

                      Divider(
                        height: 2,
                        thickness: 2,
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HorizontalRow(),
                                SizedBox(height: Dimensions.paddingSizeSmall),
                              ],
                            ),
                          );
                        },
                        itemCount: 4,
                      ),

                      Divider(
                        height: 2,
                        thickness: 2,
                        color: Get.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 60,
                              height: Dimensions.paddingSizeLarge,
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
                              width: 80,
                              height: Dimensions.paddingSizeLarge,
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
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                height: 100,
                width: Get.width,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Dimensions.paddingSizeExtraLarge,
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
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      const HorizontalRow(),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      const HorizontalRow(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                height: 250,
                width: Get.width,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
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
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: 180,
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: 20,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: 20,
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: 20,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HorizontalRow extends StatelessWidget {
  const HorizontalRow({super.key});

  @override
  Widget build(BuildContext context) {
    int randomForStart = Random().nextInt(50) + 100;
    int randomForLast = Random().nextInt(20) + 50;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: randomForStart.toDouble(),
          height: Dimensions.paddingSizeSmall,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
          ),
        ),

        Container(
          width: randomForLast.toDouble(),
          height: Dimensions.paddingSizeSmall,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
