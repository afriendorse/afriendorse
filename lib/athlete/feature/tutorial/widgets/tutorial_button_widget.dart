import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_bottom_sheet_widget.dart';
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_count_widget.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class TutorialButtonWidget extends StatelessWidget {
  const TutorialButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isLtr = Get.find<LocalizationController>().isLtr;

    return GetBuilder<UserProfileController>(
      builder: (profileController) {
        final int count = _getTutorialCount(
          profileController.providerModel?.content?.providerInfo,
        );

        return count > 0
            ? GetBuilder<TutorialController>(
                builder: (tutorialController) {
                  if (!tutorialController.isVisible ||
                      tutorialController.isBottomSheetOpen)
                    return SizedBox();

                  return Positioned.fill(
                    child: Align(
                      alignment: isLtr
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 100,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Get.bottomSheet(TutorialBottomSheetWidget());
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: Dimensions.radiusDefault,
                                  right: isLtr ? Dimensions.radiusDefault : 0,
                                  left: isLtr ? 0 : Dimensions.radiusDefault,
                                ),
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: const Radius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    topLeft: const Radius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    bottomLeft: const Radius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    bottomRight: const Radius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.1),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  child: Image.asset(
                                    Images.tutorialIcon,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 2,
                                right: isLtr ? 3 : null,
                                left: isLtr ? null : 0,
                                child: const Material(
                                  color: Colors.transparent,
                                  child: TutorialCountWidget(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : SizedBox();
      },
    );
  }

  int _getTutorialCount(ProviderInfo? providerInfo) =>
      providerInfo?.tutorialData?.values
          .where((value) => value.contains('0'))
          .length ??
      0;
}
