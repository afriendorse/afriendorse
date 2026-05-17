import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceManListShimmer extends StatefulWidget {
  const ServiceManListShimmer({super.key});

  @override
  State<ServiceManListShimmer> createState() => _ServiceManListShimmerState();
}

class _ServiceManListShimmerState extends State<ServiceManListShimmer> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isTab(context) ? 4 : 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
      ),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 25,
                    width: 35,
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
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
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      height: 5,
                      width: 70,
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
    );
  }
}
