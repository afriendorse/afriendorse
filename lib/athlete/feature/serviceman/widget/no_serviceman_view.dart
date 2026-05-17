import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class NoServicemanView extends StatelessWidget {
  const NoServicemanView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: Get.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Images.noServicemanIcon, height: 60, width: 60),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text("no_serviceman_title".tr, style: robotoBold),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
              ),
              child: Text(
                "no_serviceman_subtitle".tr,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: robotoLight,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    onPressed: () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrial) {
                            if (isTrial) {
                              Get.find<ServicemanSetupController>()
                                      .controller!
                                      .index =
                                  0;
                              Get.find<ServicemanSetupController>()
                                  .getSingleServicemanData(
                                    index: -1,
                                    fromPage: "others",
                                  );
                              Get.find<ServicemanSetupController>()
                                  .clearAllData();
                              Get.find<ServicemanSetupController>()
                                  .resetOtherValidationData();
                              Get.to(() => const AddNewServicemanScreen());
                            }
                          });
                    },
                    btnTxt: "add_serviceman".tr,
                    icon: Icons.add_circle_outline,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
