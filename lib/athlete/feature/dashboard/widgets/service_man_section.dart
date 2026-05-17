import 'package:afriendorse/athlete/feature/serviceman/view/serviceman_details.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceManSection extends StatelessWidget {
  const ServiceManSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge - 2,
                vertical: Dimensions.paddingSizeDefault,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        Images.dashboardProfile,
                        height: 15,
                        width: 15,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        "service_man_list".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.serviceManSetup);
                    },
                    child: Text(
                      dashboardController.dashboardServicemanList.isEmpty
                          ? "add_new_service_man".tr
                          : "view_all".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).primaryColor,
                        decorationColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            dashboardController.dashboardServicemanList.isEmpty
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isDesktop(context)
                            ? 6
                            : ResponsiveHelper.isTab(context)
                            ? 4
                            : 2,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),

                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.05),
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Row(),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CustomImage(
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                      image:
                                          '${dashboardController.dashboardServicemanList[index].user!.profileImageFullPath}',
                                      placeholder: Images.userPlaceHolder,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Text(
                                    '${dashboardController.dashboardServicemanList[index].user!.firstName!} ${dashboardController.dashboardServicemanList[index].user!.lastName!}',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Text(
                                    dashboardController
                                        .dashboardServicemanList[index]
                                        .user!
                                        .phone!,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: CustomInkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ServicemanDetails(
                                        id: dashboardController
                                            .dashboardServicemanList[index]
                                            .id!,
                                        fromDashboard: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount:
                          dashboardController.dashboardServicemanList.length,
                    ),
                  ),
          ],
        );
      },
    );
  }
}
