import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServicemanSetupScreen extends StatelessWidget {
  const ServicemanSetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      initState: (_) => Get.find<ServicemanSetupController>()
          .getAllServicemanList(1, reload: true),
      builder: (servicemanSetUpController) {
        return Scaffold(
          appBar: CustomAppBar(title: "service_man_setup".tr),
          body: GestureDetector(
            onTap: () => Get.find<ServicemanSetupController>().updateIndex(-1),
            child: CustomScrollView(
              controller: servicemanSetUpController.scrollController,
              slivers: [
                servicemanSetUpController.servicemanList == null
                    ? const SliverToBoxAdapter(child: ServiceManListShimmer())
                    : servicemanSetUpController.servicemanList!.isNotEmpty
                    ? SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "you_have".tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                  Text(
                                    " ${servicemanSetUpController.totalServiceman} ",
                                    style: robotoBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    servicemanSetUpController.totalServiceman >
                                            1
                                        ? "service_men".tr
                                        : "service_man".tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const ServiceManListview(),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                          ],
                        ),
                      )
                    : const NoServicemanView(),
              ],
            ),
          ),

          floatingActionButton:
              Get.find<ServicemanSetupController>().servicemanList != null &&
                  Get.find<ServicemanSetupController>()
                      .servicemanList!
                      .isNotEmpty
              ? FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
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
                  child: Icon(
                    Icons.add_circle,
                    size: 30,
                    color: light.cardColor,
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}
