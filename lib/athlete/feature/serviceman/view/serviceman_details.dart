import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServicemanDetails extends StatefulWidget {
  final String id;
  final bool fromDashboard;
  const ServicemanDetails({
    super.key,
    required this.id,
    required this.fromDashboard,
  });
  @override
  State<ServicemanDetails> createState() => _ServicemanDetailsState();
}

class _ServicemanDetailsState extends State<ServicemanDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(fromDashboard: widget.fromDashboard),
      body: GetBuilder<ServicemanDetailsController>(
        initState: (_) {
          Get.find<ServicemanDetailsController>().getServicemanDetails(
            widget.id,
          );
        },
        builder: (servicemanDetailsController) {
          if (servicemanDetailsController.servicemanModel != null) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CustomImage(
                      height: 100,
                      width: 100,
                      image:
                          servicemanDetailsController
                              .servicemanModel
                              ?.user
                              ?.profileImageFullPath ??
                          "",
                      placeholder: Images.userPlaceHolder,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    "${servicemanDetailsController.servicemanModel!.user!.firstName!} ${servicemanDetailsController.servicemanModel!.user!.lastName!}",
                    style: robotoBold.copyWith(
                      fontSize: 17,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    width: Get.width,
                    color: Get.isDarkMode
                        ? Theme.of(context).cardColor.withValues(
                            alpha: Get.isDarkMode ? 0.5 : 1,
                          )
                        : Theme.of(context).primaryColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ColumnText(
                          amount:
                              servicemanDetailsController
                                  .servicemanModel
                                  ?.bookingsCount
                                  ?.ongoing
                                  .toString() ??
                              "",
                          title: "ongoing".tr,
                        ),

                        Container(width: 1, height: 60, color: Colors.grey),

                        ColumnText(
                          amount:
                              servicemanDetailsController
                                  .servicemanModel
                                  ?.bookingsCount
                                  ?.completed
                                  .toString() ??
                              "",
                          title: "completed".tr,
                        ),
                        Container(width: 1, height: 60, color: Colors.grey),
                        ColumnText(
                          amount:
                              servicemanDetailsController
                                  .servicemanModel
                                  ?.bookingsCount
                                  ?.canceled
                                  .toString() ??
                              "",
                          title: "canceled".tr,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      boxShadow: context.customThemeColors.shadow,
                      color: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          title: Text(
                            servicemanDetailsController
                                    .servicemanModel!
                                    .user!
                                    .phone ??
                                "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          minVerticalPadding: 0,
                          horizontalTitleGap: 0,
                        ),
                        Container(
                          height: 1,
                          width: double.maxFinite,
                          color: Colors.grey.shade200,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          title: Text(
                            servicemanDetailsController
                                    .servicemanModel!
                                    .user!
                                    .email ??
                                "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          minVerticalPadding: 0,
                          horizontalTitleGap: 0,
                        ),
                        Container(
                          height: 1,
                          width: double.maxFinite,
                          color: Colors.grey.shade200,
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.people_outline_rounded,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          title: Text(
                            "${servicemanDetailsController.servicemanModel!.user!.identificationType.toString().tr} - ${servicemanDetailsController.servicemanModel!.user!.identificationNumber}",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          minVerticalPadding: 0,
                          horizontalTitleGap: 0,
                        ),
                      ],
                    ),
                  ),

                  ListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: context.customThemeColors.shadow,
                          color: Theme.of(context).cardColor.withValues(
                            alpha: Get.isDarkMode ? 0.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          child: CustomImage(
                            fit: BoxFit.cover,
                            height: 180,
                            image:
                                '${servicemanDetailsController.servicemanModel?.user?.identificationImageFullPath?[index]}',
                          ),
                        ),
                      );
                    },
                    itemCount: servicemanDetailsController
                        .servicemanModel
                        ?.user
                        ?.identificationImageFullPath
                        ?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            );
          } else {
            return const ServiceManDetailsShimmer();
          }
        },
      ),
    );
  }
}

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  final bool fromDashboard;
  const Appbar({super.key, required this.fromDashboard});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanDetailsController>(
      builder: (servicemanDetailsController) {
        return AppBar(
          elevation: 5,
          titleSpacing: 0,
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          shadowColor: Get.isDarkMode
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          title: Text(
            "profile_details".tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColorLight,
              size: 20,
            ),
          ),
          actions: fromDashboard
              ? [
                  if (!servicemanDetailsController.isLoading)
                    InkWell(
                      onTap: () {
                        Get.find<BusinessSubscriptionController>()
                            .openTrialEndBottomSheet()
                            .then((isTrial) {
                              if (isTrial) {
                                Get.find<ServicemanSetupController>()
                                    .changeServicemanStatus(
                                      -1,
                                      servicemanDetailsController
                                          .servicemanModel!
                                          .id!,
                                      fromDetailsPage: true,
                                    );

                                if (fromDashboard) {
                                  Get.find<DashboardController>()
                                      .getDashboardData();
                                } else {
                                  Get.find<ServicemanSetupController>()
                                      .getAllServicemanList(1, reload: true);
                                }
                              }
                            });
                      },
                      child: Container(
                        height: 25,
                        width: 45,
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color:
                              servicemanDetailsController
                                      .servicemanModel
                                      ?.user
                                      ?.isActive ==
                                  1
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              servicemanDetailsController
                                      .servicemanModel
                                      ?.user
                                      ?.isActive ==
                                  0
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 22,
                              width: 22,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                                color: light.cardColor,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 15,
                                color:
                                    servicemanDetailsController
                                            .servicemanModel
                                            ?.user
                                            ?.isActive ==
                                        0
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).primaryColorLight,
                    ),
                    onSelected: handleClick,
                    itemBuilder: (BuildContext context) {
                      return {'edit', 'delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice.tr),
                        );
                      }).toList();
                    },
                  ),
                ]
              : [],
        );
      },
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'edit':
        {
          Get.find<BusinessSubscriptionController>()
              .openTrialEndBottomSheet()
              .then((isTrial) {
                if (isTrial) {
                  Get.find<ServicemanSetupController>().getSingleServicemanData(
                    index: -1,
                    fromPage: "detailsPage",
                  );
                  Get.to(
                    () => const AddNewServicemanScreen(isEditScreen: true),
                  );
                }
              });
        }
        break;
      case 'delete':
        {
          Get.find<BusinessSubscriptionController>()
              .openTrialEndBottomSheet()
              .then((isTrial) {
                if (isTrial) {
                  showCustomDialog(
                    child: ConfirmationDialog(
                      title: "delete_this_service_man".tr,
                      icon: Images.servicemanImage,
                      description: 'this_operation_cannot_be_undone'.tr,
                      onYesPressed: () async {
                        Get.back();
                        showCustomDialog(child: const CustomLoader());
                        await Get.find<ServicemanSetupController>()
                            .deleteServiceman(
                              Get.find<ServicemanDetailsController>()
                                  .servicemanModel!
                                  .id!,
                              fromDetails: true,
                            );
                      },
                      onNoPressed: () {
                        Get.back();
                      },
                    ),
                    barrierDismissible: true,
                  );
                }
              });
        }
        break;
    }
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size(double.maxFinite, 55);
}
