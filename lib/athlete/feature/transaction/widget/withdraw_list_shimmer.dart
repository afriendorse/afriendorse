import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class WithdrawListShimmer extends StatelessWidget {
  const WithdrawListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeSmall,
                ),
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: Dimensions.paddingSizeDefault,
                        width: Dimensions.paddingSizeExtraLarge * 6,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),

                      Container(
                        height: Dimensions.paddingSizeDefault,
                        width: Dimensions.paddingSizeExtraLarge * 3,
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
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: Dimensions.paddingSizeDefault,
                        width: Dimensions.paddingSizeExtraLarge * 8,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),

                      Container(
                        height: Dimensions.paddingSizeDefault,
                        width: Dimensions.paddingSizeExtraLarge * 2.5,
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
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    height: Dimensions.paddingSizeDefault,
                    width: Dimensions.paddingSizeExtraLarge * 7,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeSmall,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: Dimensions.paddingSizeDefault,
                                width: Dimensions.paddingSizeExtraLarge * 4,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                ),
                              ),

                              Container(
                                height: Dimensions.paddingSizeDefault * 1.5,
                                width: Dimensions.paddingSizeExtraLarge * 2,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).hintColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Divider(
                          height: 2,
                          thickness: 2,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Container(
                            height: Dimensions.paddingSizeDefault * 1.5,
                            width:
                                Dimensions.paddingSizeExtraLarge *
                                Dimensions.paddingSizeSmall,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeDefault,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
