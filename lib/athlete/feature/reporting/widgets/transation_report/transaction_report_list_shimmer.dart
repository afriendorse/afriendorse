import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TransactionReportListShimmer extends StatelessWidget {
  const TransactionReportListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return const SizedBox(width: Dimensions.paddingSizeDefault);
              },
              itemCount: 5,
              itemBuilder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeDefault,
                      ),
                      color: Get.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade50,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.2),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            height: 70,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(270),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 60,
                          left: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 10,
                                width: 100,
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
                                height: Dimensions.paddingSizeDefault,
                              ),

                              Container(
                                height: 10,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            width: 200,
            height: 50,
            color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 25,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),

                Container(
                  height: 25,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),

                Container(
                  height: 25,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    color: Theme.of(
                      context,
                    ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
                  ),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        horizontalTitleGap: 0,
                        contentPadding: const EdgeInsets.all(0),
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4,
                        ),
                        leading: Container(
                          height: 20,
                          width: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 20,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),

                                Container(
                                  height: 20,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 20,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),

                                Container(
                                  height: 20,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                      ),

                      ListTile(
                        horizontalTitleGap: 0,
                        contentPadding: const EdgeInsets.all(0),
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4,
                        ),
                        leading: const SizedBox(),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 20,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                            ),

                            Container(
                              height: 20,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 20,
                              width: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: Dimensions.paddingSizeDefault);
              },
            ),
          ),
        ],
      ),
    );
  }
}
