import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class CategoryItemShimmer extends StatelessWidget {
  final int index;
  const CategoryItemShimmer({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (serviceCategoryController) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Dimensions.paddingSizeDefault,
              ),
              color: Get.isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade100,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 35,
                    width: 35,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Container(
                  width: 60,
                  height: 20,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  ),
                ),
                //Color(0xFF758590)
              ],
            ),
          ),
        );
      },
    );
  }
}
