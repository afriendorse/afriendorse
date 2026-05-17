import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ProviderReviewShimmer extends StatefulWidget {
  const ProviderReviewShimmer({super.key});

  @override
  State<ProviderReviewShimmer> createState() => _ProviderReviewShimmerState();
}

class _ProviderReviewShimmerState extends State<ProviderReviewShimmer> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault,
                        left: Dimensions.paddingSizeDefault,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 10,
                          width: 50,
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

                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 25,
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
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            height: 25,
                            width: 150,
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Get.isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade100,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  Container(
                                    height: 10,
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
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),

                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Get.isDarkMode
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade100,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  Container(
                                    height: 10,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 200,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),

                        Container(
                          height: 10,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),

                        Container(
                          height: 10,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),

                        Container(
                          height: 10,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),

                        Container(
                          height: 10,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.2),
                          ),
                        ),

                        Container(
                          height: 10,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault,
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

              Container(
                height: 1,
                width: double.infinity,
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                        left: Dimensions.paddingSizeSmall,
                        bottom: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.2),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeSmall,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 10,
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
                                      height: 10,
                                      width: 100,
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

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 10,
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Container(
                            height: 10,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: Dimensions.paddingSizeDefault);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
