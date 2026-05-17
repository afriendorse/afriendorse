import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget({
    super.key,
    required this.languageModel,
    required this.localizationController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        localizationController.setSelectIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: context.customThemeColors.shadow,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      border: Border.all(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      languageModel.imageUrl!,
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(languageModel.languageName!, style: robotoRegular),
                ],
              ),
            ),
            localizationController.selectedIndex == index
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColorLight,
                      size: 25,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
