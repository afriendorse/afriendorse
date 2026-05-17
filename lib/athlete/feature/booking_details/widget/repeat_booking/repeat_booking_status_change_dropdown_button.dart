import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RepeatBookingChangeStatusDropdownButton extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;
  const RepeatBookingChangeStatusDropdownButton({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        List<String> bookingStatus = ["canceled"];

        bookingStatus.add(bookingDetails.bookingStatus ?? "");

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Get.isDarkMode
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.07), // Shadow color
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: bookingDetails.bookingStatus == 'pending'
                ? Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          btnTxt: "ignore".tr,
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          textColor: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeDefault,
                          isLoading:
                              bookingDetailsController.isAcceptButtonLoading
                              ? false
                              : false,
                          onPressed:
                              bookingDetailsController.isAcceptButtonLoading
                              ? () {}
                              : () {
                                  showCustomDialog(
                                    child: ConfirmationDialog(
                                      yesButtonColor: Theme.of(
                                        Get.context!,
                                      ).primaryColor,
                                      title:
                                          "are_you_sure_to_ignore_the_booking_request"
                                              .tr,
                                      description:
                                          "once_you_ignore_the_request",
                                      noButtonColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      noTextColor: Colors.white,
                                      icon: Images.warning,
                                      noButtonText: "cancel",
                                      onYesPressed: () {
                                        bookingDetailsController
                                            .ignoreBookingRequest(bookingId);
                                        Get.back();
                                        Get.back();
                                      },
                                    ),
                                  );
                                },
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: CustomButton(
                          btnTxt: "accept".tr,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          textColor: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeDefault,
                          isLoading:
                              bookingDetailsController.isAcceptButtonLoading,
                          onPressed:
                              bookingDetailsController.isIgnoreButtonLoading
                              ? () {}
                              : () {
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
                                                title:
                                                    "want_accept_this_booking?"
                                                        .tr,
                                                icon: Images.servicemanImage,
                                                description:
                                                    'accept_booking_hint_text'
                                                        .tr,
                                                onYesPressed: () {
                                                  bookingDetailsController
                                                      .acceptBookingRequest(
                                                        bookingId,
                                                      );
                                                  Get.back();
                                                },
                                                onNoPressed: () => Get.back(),
                                              ),
                                            );
                                          }
                                        });
                                  }
                                },
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: (String newValue) {
                            if (newValue == "canceled") {
                              showCustomDialog(
                                child: ConfirmationDialog(
                                  yesButtonColor: Theme.of(
                                    Get.context!,
                                  ).primaryColor,
                                  title: "you_can't_cancel_full_booking".tr,
                                  description:
                                      "if_you_face_any_problem_and_want_to_cancel"
                                          .tr,
                                  noButtonColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  noTextColor: Colors.white,
                                  icon: Images.warning,
                                  noButtonText: "cancel",
                                  customButton: CustomButton(
                                    btnTxt: "okay".tr,
                                    height: 40,
                                    width: 120,
                                    onPressed: () => Get.back(),
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                  onYesPressed: () async {},
                                ),
                              );
                            }
                          },
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - (160),
                          ),
                          offset: const Offset(0, 250),
                          elevation: 2,
                          surfaceTintColor: Theme.of(context).cardColor,
                          itemBuilder: (BuildContext context) {
                            return bookingStatus.map((String items) {
                              return PopupMenuItem<String>(
                                value: items,
                                padding: EdgeInsets.zero,
                                child:
                                    bookingDetailsController.dropDownValue.tr
                                            .toLowerCase() ==
                                        items
                                    ? Container(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.08),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              items.tr,
                                              style: robotoMedium.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.done,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeDefault,
                                        ),
                                        child: Text(items.tr),
                                      ),
                              );
                            }).toList();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              border: Border.all(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bookingDetails.bookingStatus?.tr ?? "",
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      bookingDetailsController.isStatusUpdateLoading
                          ? SizedBox(
                              height: 45,
                              width: 112,
                              child: Center(
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).hoverColor,
                                  ),
                                ),
                              ),
                            )
                          : CustomButton(
                              color: Theme.of(context).primaryColor,
                              height: 45,
                              width: 112,
                              btnTxt: "change".tr,
                              onPressed: null,
                            ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
