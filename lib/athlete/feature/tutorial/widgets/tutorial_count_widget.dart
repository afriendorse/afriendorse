import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TutorialCountWidget extends StatelessWidget {
  const TutorialCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return Container(
          height: Dimensions.paddingSizeLarge,
          width: Dimensions.paddingSizeLarge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.customThemeColors.error,
          ),
          child: Center(
            child: Text(
              (userProfileController
                      .providerModel
                      ?.content
                      ?.providerInfo
                      ?.tutorialData
                      ?.values
                      .where((value) => value.contains('0'))
                      .length)
                  .toString(),
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
