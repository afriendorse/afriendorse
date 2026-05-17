import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServicemanCardView extends StatelessWidget {
  final ServicemanModel? serviceman;
  final int index;
  const ServicemanCardView({super.key, this.serviceman, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanController) {
        return Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: serviceman?.isActive == 1
                ? Theme.of(
                    context,
                  ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1)
                : Colors.grey.withValues(alpha: 0.2),
            boxShadow: serviceman?.isActive == 1
                ? context.customThemeColors.shadow
                : null,
          ),

          child: Stack(
            alignment: Alignment.center,
            children: [
              const Row(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Stack(
                      children: [
                        CustomImage(
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                          image: '${serviceman?.profileImageFullPath}',
                          placeholder: Images.userPlaceHolder,
                        ),
                        if (serviceman?.isActive.toString() == '0')
                          Container(
                            height: 60,
                            width: 60,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        if (serviceman?.isActive.toString() == '0')
                          Positioned(
                            top: 23,
                            left: 7,
                            child: Text(
                              'inactive'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: light.cardColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: Text(
                      "${serviceman?.firstName ?? ""} ${serviceman?.lastName ?? ""}",
                      style: robotoBold.copyWith(
                        color: serviceman?.isActive == 1
                            ? Theme.of(context).textTheme.bodyLarge!.color!
                                  .withValues(alpha: 0.7)
                            : Theme.of(context).textTheme.bodyLarge!.color!
                                  .withValues(alpha: 0.3),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    serviceman?.phone ?? "",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall - 1,
                      color: serviceman?.isActive == 1
                          ? Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)
                          : Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),

              servicemanController.selectedIndex == index
                  ? Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                        ),
                        width: ResponsiveHelper.isTab(context)
                            ? MediaQuery.of(context).size.width * 0.18
                            : MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 2),
                              blurRadius: 5,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                servicemanController.clearImageData();
                                servicemanController.resetOtherValidationData();
                                servicemanController.updateTabControllerValue(
                                  ServicemanTabControllerState.generalInfo,
                                );
                                servicemanController.controller!.index = 0;
                                servicemanController.getSingleServicemanData(
                                  index: index,
                                  fromPage: 'editPage',
                                );
                                Get.to(
                                  const AddNewServicemanScreen(
                                    isEditScreen: true,
                                  ),
                                );
                              },
                              child: Image.asset(
                                Images.servicemanEdit,
                                height: 25,
                                width: 25,
                              ),
                            ),

                            GestureDetector(
                              onTap: () => showCustomDialog(
                                child: ConfirmationDialog(
                                  title: "delete_this_service_man".tr,
                                  icon: Images.servicemanImage,
                                  description:
                                      'this_operation_cannot_be_undone'.tr,
                                  onYesPressed: () async {
                                    Get.back();
                                    showCustomDialog(
                                      child: const CustomLoader(),
                                    );
                                    await servicemanController.deleteServiceman(
                                      servicemanController
                                          .servicemanList![index]
                                          .serviceman!
                                          .id!,
                                    );
                                  },
                                  onNoPressed: () {
                                    servicemanController.updateIndex(-1);
                                    Get.back();
                                  },
                                ),
                                barrierDismissible: true,
                              ),
                              child: Image.asset(
                                Images.servicemanDelete,
                                height: 25,
                                width: 25,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                servicemanController.changeServicemanStatus(
                                  index,
                                  servicemanController
                                      .servicemanList![index]
                                      .serviceman!
                                      .id!,
                                );

                                Get.find<DashboardController>()
                                    .getDashboardData();
                              },
                              child: Container(
                                height: 25,
                                width: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:
                                      servicemanController
                                              .servicemanList?[index]
                                              .isActive ==
                                          1
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.withValues(alpha: 0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      servicemanController
                                              .servicemanList?[index]
                                              .isActive ==
                                          0
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 22,
                                      width: 22,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 5,
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(50),
                                        color: light.cardColor,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 15,
                                        color:
                                            servicemanController
                                                    .servicemanList?[index]
                                                    .isActive ==
                                                0
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),

              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () => Get.find<BusinessSubscriptionController>()
                      .openTrialEndBottomSheet()
                      .then((isTrail) {
                        if (isTrail) {
                          servicemanController.updateIndex(index);
                        }
                      }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: Theme.of(
                        context,
                      ).primaryColorLight.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
