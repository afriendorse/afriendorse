import 'package:afriendorse/athlete/helper/booking_helper.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingRequestItem extends StatelessWidget {
  final BookingRequestModel booking;
  const BookingRequestItem({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    var ongoingRepeatBooking = BookingHelper.getCurrentOngoingRepeatBooking(
      booking,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: context.customThemeColors.lightShadow,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeExtraSmall + 3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "booking".tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color!
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                " # ${booking.readableId}",
                                style: robotoBold.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.8),
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              if (booking.isRepeatBooking == 1)
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: const Icon(
                                    Icons.repeat,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            booking.subCategory?.name ?? " ",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall + 2,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeExtraSmall,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "${'booking_date'.tr}: ",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  " ${DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(booking.createdAt!))}",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Row(
                            children: [
                              Text(
                                "${'scheduled_date'.tr}: ",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                              if (BookingHelper.getRepeatBookingCurrentSchedule(
                                    booking,
                                  ) !=
                                  null)
                                Expanded(
                                  child: Text(
                                    DateConverter.dateMonthYearTime(
                                      DateTime.tryParse(
                                        BookingHelper.getRepeatBookingCurrentSchedule(
                                          booking,
                                        )!,
                                      ),
                                    ),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                    textDirection: TextDirection.ltr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'total_amount'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        Text(
                          PriceConverter.convertPrice(
                            booking.totalBookingAmount ?? 0,
                          ),
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /*  Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                margin: EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  5,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(
                  spacing: Dimensions.paddingSizeExtraSmall,
                  children: [
                    Icon(Icons.location_on_rounded, size: 17),
                     Text(
                      booking.serviceLocation == "provider"
                          ? "your_location".tr
                          : "customer_location".tr,
                      style: robotoMedium.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                      ),
                    ), 
                  ],
                ),
              ), */
            ],
          ),
          Positioned.fill(
            child: CustomInkWell(
              onTap: () {
                if (booking.isRepeatBooking == 1) {
                  Get.toNamed(
                    RouteHelper.getRepeatBookingDetailsRoute(
                      bookingId: booking.id!,
                    ),
                  );
                } else {
                  Get.toNamed(
                    RouteHelper.getBookingDetailsRoute(bookingId: booking.id!),
                  );
                }
              },
            ),
          ),

          Positioned(
            right: 10,
            top: 15,
            child: GetBuilder<BookingRequestController>(
              builder: (bookingRequestController) {
                return PopupMenuButton<PopupMenuModel>(
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Dimensions.radiusDefault),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                    ),
                  ),
                  surfaceTintColor: Theme.of(context).cardColor,
                  position: PopupMenuPosition.under,
                  elevation: 8,
                  shadowColor: Theme.of(
                    context,
                  ).hintColor.withValues(alpha: 0.3),
                  itemBuilder: (BuildContext context) {
                    return bookingRequestController
                        .getPopupMenuList(
                          status: booking.bookingStatus ?? "",
                          isRepeatBooking: booking.isRepeatBooking == 1,
                          ongoingRepeatBooking: ongoingRepeatBooking,
                        )
                        .map((PopupMenuModel option) {
                          return PopupMenuItem<PopupMenuModel>(
                            onTap: () async {
                              if (option.title == "booking_details" ||
                                  option.title == "full_booking_details") {
                                if (booking.isRepeatBooking == 1) {
                                  Get.toNamed(
                                    RouteHelper.getRepeatBookingDetailsRoute(
                                      bookingId: booking.id!,
                                    ),
                                  );
                                } else {
                                  Get.toNamed(
                                    RouteHelper.getBookingDetailsRoute(
                                      bookingId: booking.id,
                                    ),
                                  );
                                }
                              } else if (option.title == "accept") {
                                if (Get.find<UserProfileController>()
                                        .providerModel
                                        ?.content
                                        ?.subscriptionInfo
                                        ?.subscribedPackageDetails
                                        ?.isCanceled ==
                                    1) {
                                  showCustomSnackBar(
                                    "your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request"
                                        .tr,
                                    type: ToasterMessageType.info,
                                  );
                                } else {
                                  Get.find<BusinessSubscriptionController>()
                                      .openTrialEndBottomSheet()
                                      .then((isTrial) {
                                        if (isTrial) {
                                          showCustomDialog(
                                            child: ConfirmationDialog(
                                              noButtonColor: Theme.of(
                                                Get.context!,
                                              ).colorScheme.error,
                                              noTextColor: Colors.white,
                                              yesButtonColor: Theme.of(
                                                Get.context!,
                                              ).primaryColor,
                                              title: "want_accept_this_booking?"
                                                  .tr,
                                              icon: Images.servicemanImage,
                                              description:
                                                  'accept_booking_hint_text'.tr,
                                              onYesPressed: () {
                                                Get.find<
                                                      BookingDetailsController
                                                    >()
                                                    .acceptBookingRequest(
                                                      booking.id!,
                                                    );
                                                Get.back();
                                              },
                                              onNoPressed: () => Get.back(),
                                            ),
                                          );
                                        }
                                      });
                                }
                              } else if (option.title == "ignore") {
                                showCustomDialog(
                                  child: ConfirmationDialog(
                                    yesButtonColor: Theme.of(
                                      Get.context!,
                                    ).primaryColor,
                                    title:
                                        "are_you_sure_to_ignore_the_booking_request"
                                            .tr,
                                    description: "once_you_ignore_the_request",
                                    noButtonColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                    noTextColor: Colors.white,
                                    icon: Images.warning,
                                    noButtonText: "cancel",
                                    onYesPressed: () {
                                      Get.find<BookingDetailsController>()
                                          .ignoreBookingRequest(booking.id!);
                                      Get.back();
                                      Get.back();
                                    },
                                  ),
                                );
                              } else if (option.title == "download_invoice" ||
                                  option.title == "download_full_invoice") {
                                String languageCode =
                                    Get.find<LocalizationController>()
                                        .locale
                                        .languageCode;
                                String uri =
                                    "${AppConstants.baseUrl}${booking.isRepeatBooking == 1 ? AppConstants.fullRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${booking.id}/$languageCode";
                                if (kDebugMode) {
                                  print("Uri : $uri");
                                }
                                await _launchUrl(Uri.parse(uri));
                              } else if (option.title ==
                                      "download_ongoing_invoice" ||
                                  option.title == "download_upcoming_invoice") {
                                String languageCode =
                                    Get.find<LocalizationController>()
                                        .locale
                                        .languageCode;
                                String uri =
                                    "${AppConstants.baseUrl}${AppConstants.singleRepeatBookingInvoiceUrl}${ongoingRepeatBooking!.id}/$languageCode";
                                if (kDebugMode) {
                                  print("Uri : $uri");
                                }
                                await _launchUrl(Uri.parse(uri));
                              } else if (option.title ==
                                      "ongoing_booking_details" ||
                                  option.title == "upcoming_booking_details") {
                                Get.toNamed(
                                  RouteHelper.getBookingDetailsRoute(
                                    subBookingId: ongoingRepeatBooking!.id!,
                                  ),
                                );
                              }
                            },
                            value: option,
                            height: 35,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall,
                                ),
                                Icon(
                                  option.icon,
                                  size: Dimensions.fontSizeLarge,
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),
                                Text(
                                  option.title.tr.capitalizeFirst ?? "",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList();
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
