import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessReportShimmer extends StatelessWidget {
  const BusinessReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                top: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: Dimensions.paddingSizeLarge * 6,
                      width: Dimensions.paddingSizeExtraLarge * 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeDefault,
                        ),
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height:
                                Dimensions.paddingSizeExtraLarge +
                                Dimensions.paddingSizeSmall,
                            width:
                                Dimensions.paddingSizeExtraLarge +
                                Dimensions.paddingSizeSmall,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Get.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge * 3,
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
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge * 3,
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
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Container(
                      height: Dimensions.paddingSizeLarge * 6,
                      width: Dimensions.paddingSizeExtraLarge * 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeDefault,
                        ),
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall,
                              left: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height:
                                      Dimensions.paddingSizeExtraLarge +
                                      Dimensions.paddingSizeSmall,
                                  width:
                                      Dimensions.paddingSizeExtraLarge +
                                      Dimensions.paddingSizeSmall,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Get.isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade100,
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault,
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: Dimensions.paddingSizeSmall,
                                      width:
                                          Dimensions.paddingSizeExtraLarge * 3,
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
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    Container(
                                      height: Dimensions.paddingSizeSmall,
                                      width:
                                          Dimensions.paddingSizeExtraLarge * 3,
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 2,
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
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 3,
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
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 2,
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
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 3,
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
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 2,
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
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge * 3,
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
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Container(
              height: 320,
              width: double.infinity,
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeSmall,
                      top: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Container(
                          height: Dimensions.paddingSizeDefault,
                          width: Dimensions.paddingSizeExtraLarge * 4,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: Dimensions.paddingSizeSmall,
                            width: Dimensions.paddingSizeSmall,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Get.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Container(
                            height: Dimensions.paddingSizeSmall,
                            width: Dimensions.paddingSizeLarge * 2,
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
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Row(
                        children: [
                          Container(
                            height: Dimensions.paddingSizeSmall,
                            width: Dimensions.paddingSizeSmall,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Get.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Container(
                            height: Dimensions.paddingSizeSmall,
                            width: Dimensions.paddingSizeLarge * 2,
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
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeSmall,
                      top: Dimensions.paddingSizeSmall,
                    ),
                    child: SizedBox(
                      height: Dimensions.paddingSizeExtraLarge * 8,
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ),

                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ),

                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ),

                              Container(
                                height: Dimensions.paddingSizeSmall,
                                width: Dimensions.paddingSizeExtraLarge,
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
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Container(
                            height: Dimensions.paddingSizeExtraLarge * 8,
                            width: 2,
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),

                          SizedBox(
                            height: Dimensions.paddingSizeExtraLarge * 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 2,
                                  width: 350,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeLarge * 2,
                      top: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: Dimensions.paddingSizeSmall,
                          width: Dimensions.paddingSizeExtraLarge + 5,
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
                          height: Dimensions.paddingSizeSmall,
                          width: Dimensions.paddingSizeExtraLarge + 5,
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
                          height: Dimensions.paddingSizeSmall,
                          width: Dimensions.paddingSizeExtraLarge + 5,
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
                          height: Dimensions.paddingSizeSmall,
                          width: Dimensions.paddingSizeExtraLarge + 5,
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
                          height: Dimensions.paddingSizeSmall,
                          width: Dimensions.paddingSizeExtraLarge + 5,
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
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(height: Dimensions.paddingSizeSmall);
              },
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                  ),
                  width: double.infinity,
                  height: Dimensions.paddingSizeExtraLarge * 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4,
                        ),
                        leading: Container(
                          height: Dimensions.paddingSizeLarge,
                          width: Dimensions.paddingSizeSmall,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        horizontalTitleGap: 0,
                        title: Container(
                          height: Dimensions.paddingSizeExtraSmall,
                          width: Dimensions.paddingSizeLarge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                        ),
                        trailing: const Padding(
                          padding: EdgeInsets.only(
                            right: Dimensions.paddingSizeLarge * 6,
                          ),
                          child: SizedBox(),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeExtraLarge * 2,
                          right: Dimensions.paddingSizeDefault,
                        ),
                        child: SizedBox(
                          height: Dimensions.paddingSizeExtraLarge * 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
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

                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeExtraLarge + 5,
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

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge,
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
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge,
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

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width:
                                        Dimensions.paddingSizeExtraLarge +
                                        Dimensions.paddingSizeSmall,
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
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeExtraLarge,
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

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge,
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
                                    height: Dimensions.paddingSizeExtraSmall,
                                    width: Dimensions.paddingSizeLarge,
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
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
