import 'package:afriendorse/athlete/feature/booking_details/widget/update_service_location_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingServiceLocation extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final RepeatBooking? nextBooking;
  final bool isSubBooking;
  final BookingEditType bookingEditType;
  const BookingServiceLocation({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
    required this.bookingEditType,
    this.nextBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        var config = Get.find<SplashController>().configModel.content;
        var settingController = Get.find<BusinessSettingController>();

        String? serviceLocation =
            nextBooking?.serviceLocation ?? bookingDetails.serviceLocation;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          margin: EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'service_location'.tr,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color?.withValues(alpha: 0.9),
                      ),
                    ),
                  ),

                  if (config?.serviceAtProviderPlace == 1 &&
                      settingController.isActiveServiceInProviderLocation &&
                      settingController.isActiveServiceInCustomerLocation &&
                      (bookingDetails.bookingStatus == "accepted" ||
                          bookingDetails.bookingStatus == "ongoing"))
                    InkWell(
                      onTap: () => showCustomBottomSheet(
                        child: UpdateServiceLocationWidget(
                          nextBooking: nextBooking,
                          isSubBooking: isSubBooking,
                          bookingDetails: bookingDetails,
                          bookingEditType: bookingEditType,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 0.6,
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: Dimensions.paddingSizeSmall),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ),
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.paddingSizeSmall,
                  children: [
                    /* Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeEight,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: serviceLocation == "provider"
                              ? "the_customer_will_come_to".tr
                              : "you_need_to_go_to_the".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  " ${serviceLocation == "provider" ? "your_location".tr : 'customer_location'.tr} ",
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " ${serviceLocation == "provider" ? "for_the_service".tr : 'to_provide_the_service'.tr} ",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), 

                    Text(
                      "${'service_location'.tr} : ",
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color?.withValues(alpha: 0.8),
                      ),
                    ), */
                    Row(
                      spacing: Dimensions.paddingSizeDefault,
                      children: [
                        Expanded(
                          child: Text(
                            serviceLocation == "customer"
                                ? bookingDetails.serviceAddress?.address ??
                                      bookingDetails
                                          .subBooking
                                          ?.serviceAddress
                                          ?.address ??
                                      'address_not_found'.tr
                                : Get.find<UserProfileController>()
                                          .providerModel
                                          ?.content
                                          ?.providerInfo
                                          ?.companyAddress ??
                                      'address_not_found'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        /*
                        if (serviceLocation == "customer")
                          InkWell(
                            onTap: () async {
                              _checkPermission(() async {
                                if (bookingDetails.serviceAddress != null ||
                                    bookingDetails.subBooking?.serviceAddress !=
                                        null) {
                                  showCustomDialog(child: const CustomLoader());
                                  await Geolocator.getCurrentPosition().then((
                                    position,
                                  ) {
                                    MapUtils.openMap(
                                      bookingDetails.serviceAddress?.lat ??
                                          bookingDetails
                                              .subBooking
                                              ?.serviceAddress
                                              ?.lat ??
                                          23.8103,
                                      bookingDetails.serviceAddress?.lon ??
                                          bookingDetails
                                              .subBooking
                                              ?.serviceAddress
                                              ?.lon ??
                                          90.4125,
                                      position.latitude,
                                      position.longitude,
                                    );
                                  });
                                  Get.back();
                                } else {
                                  showCustomSnackBar(
                                    "service_address_not_found".tr,
                                  );
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.6,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ),
                          ), */
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      showCustomDialog(
        child: const PermissionDialog(),
        barrierDismissible: true,
      );
    } else {
      onTap();
    }
  }
}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(
    double destinationLatitude,
    double destinationLongitude,
    double userLatitude,
    double userLongitude,
  ) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}
