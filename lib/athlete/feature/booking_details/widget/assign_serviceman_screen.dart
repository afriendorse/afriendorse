import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AssignServicemanScreen extends StatelessWidget {
  final List<ServicemanModel> servicemanList;
  final String bookingId;
  final bool? reAssignServiceman;
  final bool isSubBooking;

  const AssignServicemanScreen({
    super.key,
    required this.servicemanList,
    required this.bookingId,
    this.reAssignServiceman,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanSetupController) {
        return GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsController) {
            List<ServicemanModel> activeServicemanList = [];
            for (var serviceman in servicemanList) {
              if (serviceman.isActive == 1) {
                activeServicemanList.add(serviceman);
              }
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeLarge,
                ),
                width: context.width,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Get.isDarkMode
                      ? Theme.of(
                          context,
                        ).primaryColorDark.withValues(alpha: 0.3)
                      : Theme.of(
                          context,
                        ).primaryColorDark.withValues(alpha: 0.2),
                ),

                child: Column(
                  children: [
                    InkWell(
                      onTap: () =>
                          bookingDetailsController.showHideExpandView(0),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    activeServicemanList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "no_serviceman_available".tr,
                                style: robotoMedium.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              CustomButton(
                                width: 200,
                                height: 35,
                                fontSize: Dimensions.fontSizeSmall,
                                btnTxt: "add_new_service_man".tr,
                                onPressed: () {
                                  Get.find<BusinessSubscriptionController>()
                                      .openTrialEndBottomSheet()
                                      .then((isTrial) {
                                        if (isTrial) {
                                          bookingDetailsController
                                              .showHideExpandView(0);
                                          Get.find<ServicemanSetupController>()
                                              .fromBookingDetailsPage(true);
                                          Get.to(
                                            () => const AddNewServicemanScreen(
                                              isEditScreen: false,
                                            ),
                                          );
                                        }
                                      });
                                },
                              ),
                            ],
                          )
                        : GridView.builder(
                            controller: Get.find<ServicemanSetupController>()
                                .scrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      ResponsiveHelper.isDesktop(context)
                                      ? 6
                                      : ResponsiveHelper.isTab(context)
                                      ? 4
                                      : 2,
                                  childAspectRatio: 1.0,
                                  mainAxisSpacing: 0,
                                  crossAxisSpacing: 0,
                                ),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  showCustomDialog(
                                    child: ConfirmationDialog(
                                      icon: Images.servicemanImage,
                                      description: '',
                                      title:
                                          "${"are_you_want_to_assign".tr} "
                                          "${activeServicemanList[index].firstName ?? ""} "
                                          "${activeServicemanList[index].lastName ?? ""} "
                                          "${'for_this_booking'.tr}?",
                                      yesButtonColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      onYesPressed: () {
                                        servicemanSetupController
                                            .assignServiceman(
                                              bookingId: bookingId != "null"
                                                  ? bookingId
                                                  : null,
                                              subBookingId:
                                                  Get.find<
                                                        BookingDetailsController
                                                      >()
                                                      .subBookingDetails
                                                      ?.content
                                                      ?.id,
                                              servicemanId:
                                                  activeServicemanList[index]
                                                      .serviceman!
                                                      .id!,
                                              reAssignServiceman:
                                                  reAssignServiceman ?? false,
                                            );
                                        Get.back();
                                      },
                                    ),
                                    barrierDismissible: true,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: context.customThemeColors.shadow,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CustomImage(
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: 60,
                                          image:
                                              '${activeServicemanList[index].profileImageFullPath}',
                                          placeholder: Images.userPlaceHolder,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      Text(
                                        '${activeServicemanList[index].firstName!} ${activeServicemanList[index].lastName!}',
                                        style: robotoMedium.copyWith(
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),
                                      Text(
                                        activeServicemanList[index].phone !=
                                                null
                                            ? activeServicemanList[index].phone!
                                            : "Phone: NULL",
                                        style: robotoMedium.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: activeServicemanList.length,
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
