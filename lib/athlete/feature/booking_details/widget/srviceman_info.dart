import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingDetailsServicemanInfo extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingDetailsServicemanInfo({super.key, required this.bookingDetails});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          margin: const EdgeInsets.only(
            bottom: Dimensions.paddingSizeExtraSmall,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Service_Man_Info".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              Stack(
                children: [
                  bookingDetails.serviceman != null
                      ? BottomCard(
                          name:
                              "${bookingDetails.serviceman!.user!.firstName!} ${bookingDetails.serviceman!.user!.lastName!}",
                          phone: bookingDetails.serviceman!.user!.phone!,
                          image:
                              bookingDetails
                                  .serviceman
                                  ?.user
                                  ?.profileImageFullPath ??
                              "",
                        )
                      : Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(
                              context,
                            ).cardColor.withValues(alpha: 0.6),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                                color: Colors.black.withValues(alpha: 0.1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'missing_serviceman_information'.tr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Text(
                                  'this_serviceman_may_deleted'.tr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.6),
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  bookingDetails.bookingStatus == "accepted" ||
                          bookingDetails.bookingStatus == "ongoing"
                      ? Positioned(
                          top: Dimensions.paddingSizeDefault,
                          right: 15,
                          child: InkWell(
                            child: Image.asset(Images.editIcon),
                            onTap: () {
                              Get.find<ServicemanSetupController>()
                                  .fromBookingDetailsPage(true);
                              bookingDetailsController.showHideExpandView(350);
                            },
                          ),
                        )
                      : const SizedBox(),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        );
      },
    );
  }
}
