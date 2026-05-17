import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.title,
    required this.selectedCategory,
    required this.image,
    required this.index,
  });
  final String title;
  final String image;
  final String selectedCategory;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceCategoryController>(
      builder: (serviceCategoryController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              bottomRight:
                  (index + 1) == serviceCategoryController.selectedCategory
                  ? const Radius.circular(15)
                  : const Radius.circular(0),
              topRight:
                  (index - 1) == serviceCategoryController.selectedCategory
                  ? const Radius.circular(15)
                  : const Radius.circular(0),
            ),
          ),
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
          child: Container(
            decoration: BoxDecoration(
              color: selectedCategory == title
                  ? Get.isDarkMode
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).primaryColor.withValues(alpha: .07)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: selectedCategory == title
                    ? const Radius.circular(15)
                    : const Radius.circular(0),
                bottomLeft: selectedCategory == title
                    ? const Radius.circular(15)
                    : const Radius.circular(0),
                bottomRight: selectedCategory == title
                    ? const Radius.circular(0)
                    : const Radius.circular(15),
                topRight: selectedCategory == title
                    ? const Radius.circular(0)
                    : const Radius.circular(15),
              ),
            ),

            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall - 1),

            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: selectedCategory == title
                    ? context.customThemeColors.lightShadow
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.07),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CustomImage(height: 30, width: 30, image: image),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(
                    width: 85,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: selectedCategory == title
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).hintColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  //Color(0xFF758590)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
