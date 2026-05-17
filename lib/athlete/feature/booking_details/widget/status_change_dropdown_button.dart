import 'package:afriendorse/athlete/feature/auth/repository/general_firebase_auth_sync_service.dart';
import 'package:afriendorse/feature/auth/repository/deal_approval_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ChangeStatusDropdownButton extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;
  const ChangeStatusDropdownButton({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        List<String> statusList = [];
        for (var element in bookingDetailsController.statusTypeList) {
          statusList.add(element);
        }
        if (isSubBooking &&
            bookingDetails.isPaid == 1 &&
            statusList.contains("canceled")) {
          statusList.remove("canceled");
        }

        String dropdownStatus = isSubBooking
            ? bookingDetailsController.subBookingDropDownValue
            : bookingDetailsController.dropDownValue;

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
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault,
            ),
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
                : dropdownStatus == "completed" &&
                      bookingDetailsController.showPhotoEvidenceField &&
                      Get.find<SplashController>()
                              .configModel
                              .content
                              ?.bookingOtpVerification ==
                          1
                ? CustomButton(
                    btnTxt: "request_brand_approval"
                        .tr, // add translation OR just hardcode text
                    onPressed: () async {
                      // ── Resolve athlete email ────────────────────────────────────
                      String athleteEmail =
                          FirebaseAuth.instance.currentUser?.email?.trim() ??
                          '';

                      if (athleteEmail.isEmpty) {
                        final profileEmail =
                            Get.find<UserProfileController>()
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.owner
                                ?.email
                                ?.trim()
                                .toLowerCase() ??
                            '';

                        if (profileEmail.isNotEmpty) {
                          await FirebaseAuthSyncService.syncAfterLogin(
                            email: profileEmail,
                          );
                          athleteEmail =
                              FirebaseAuth.instance.currentUser?.email
                                  ?.trim() ??
                              '';

                          if (athleteEmail.isEmpty) {
                            athleteEmail = profileEmail;
                          }
                        }
                      }

                      // ── Resolve brand data ───────────────────────────────────────
                      final brandEmail =
                          (bookingDetails.customer?.email?.trim().isNotEmpty ==
                                      true
                                  ? bookingDetails.customer!.email!
                                  : bookingDetails
                                            .subBooking
                                            ?.customer
                                            ?.email ??
                                        '')
                              .trim();

                      final brandPhone =
                          (bookingDetails.customer?.phone?.trim().isNotEmpty ==
                                      true
                                  ? bookingDetails.customer!.phone!
                                  : bookingDetails
                                            .subBooking
                                            ?.customer
                                            ?.phone ??
                                        '')
                              .trim();

                      final readableId = (bookingDetails.readableId ?? '')
                          .trim();

                      // ── Guard ────────────────────────────────────────────────────
                      bool isBlankOrNull(String s) => s.isEmpty || s == 'null';

                      if (isBlankOrNull(athleteEmail) ||
                          isBlankOrNull(brandEmail) ||
                          isBlankOrNull(brandPhone) ||
                          isBlankOrNull(readableId)) {
                        debugPrint('❌ athleteEmail="$athleteEmail"');
                        debugPrint('❌ brandEmail="$brandEmail"');
                        debugPrint('❌ brandPhone="$brandPhone"');
                        debugPrint('❌ readableId="$readableId"');
                        showCustomSnackBar(
                          'Missing data to request approval. Please try again.',
                          type: ToasterMessageType.info,
                        );
                        return;
                      }

                      final controller = Get.find<BookingDetailsController>();

                      // ── COLLECT ALL PHOTO URLs ───────────────────────────────────
                      List<String> photoUrls = [];

                      // 1. Already uploaded MySQL photos (from prior status changes)
                      if (bookingDetails.photoEvidenceFullPath != null &&
                          bookingDetails.photoEvidenceFullPath!.isNotEmpty) {
                        photoUrls.addAll(bookingDetails.photoEvidenceFullPath!);
                      }

                      // 2. Newly picked photos — upload to Firebase Storage
                      if (controller.pickedPhotoEvidence.isNotEmpty) {
                        showCustomSnackBar(
                          'Uploading service proof...',
                          type: ToasterMessageType.info,
                        );

                        final firebaseUrls =
                            await DealApprovalFirestoreService.uploadEvidencePhotos(
                              bookingId,
                              controller.pickedPhotoEvidence,
                            );
                        photoUrls.addAll(firebaseUrls);

                        // Clear local photos after successful upload
                        controller.resetPhotoEvidence();
                      }

                      // ── MySQL OTP notification ─────────────────────────────────
                      controller.sendBookingOTPNotification(
                        bookingId,
                        shouldUpdate: false,
                      );

                      // ── Firestore approval doc WITH photos ─────────────────────
                      await DealApprovalFirestoreService.requestApproval(
                        bookingId: bookingId,
                        isSubBooking: isSubBooking,
                        readableId: readableId,
                        brandEmail: brandEmail,
                        brandPhone: brandPhone,
                        athleteEmail: athleteEmail,
                        photoEvidence: photoUrls.isNotEmpty ? photoUrls : null,
                      );

                      showCustomSnackBar(
                        'Approval requested. After approval (or auto-approval in 72hrs), '
                        'you can receive payment.',
                        type: ToasterMessageType.success,
                      );
                    },
                  )
                : Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: (String newValue) {
                            bookingDetailsController
                                .changeBookingStatusDropDownValue(
                                  newValue,
                                  isSubBooking,
                                );
                            if (newValue == "completed") {
                              if (Get.find<SplashController>()
                                          .configModel
                                          .content
                                          ?.bookingImageVerification ==
                                      1 &&
                                  bookingDetailsController
                                      .pickedPhotoEvidence
                                      .isNotEmpty) {
                                bookingDetailsController
                                    .changePhotoEvidenceStatus(status: true);
                              } else if (Get.find<SplashController>()
                                      .configModel
                                      .content
                                      ?.bookingOtpVerification ==
                                  1) {
                                bookingDetailsController
                                    .changePhotoEvidenceStatus(status: true);
                              } else {
                                bookingDetailsController
                                    .changePhotoEvidenceStatus(status: false);
                              }
                              if (Get.find<SplashController>()
                                          .configModel
                                          .content
                                          ?.bookingImageVerification ==
                                      1 &&
                                  bookingDetailsController
                                      .pickedPhotoEvidence
                                      .isEmpty) {
                                showCustomBottomSheet(
                                  child: CameraButtonSheet(
                                    bookingId: bookingId,
                                    isSubBooking: isSubBooking,
                                  ),
                                );
                              }
                            }
                          },
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - (160),
                          ),
                          offset: const Offset(0, 250),
                          elevation: 2,
                          surfaceTintColor: Theme.of(context).cardColor,
                          itemBuilder: (BuildContext context) {
                            return statusList.map((String items) {
                              return PopupMenuItem<String>(
                                value: items,
                                padding: EdgeInsets.zero,
                                child: dropdownStatus.tr.toLowerCase() == items
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
                                  dropdownStatus.tr,
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
                              onPressed:
                                  bookingDetails.bookingStatus == "completed" ||
                                      dropdownStatus ==
                                          bookingDetails.bookingStatus ||
                                      bookingDetails.bookingStatus == "canceled"
                                  ? null
                                  : () => bookingDetailsController
                                        .changeBookingStatus(
                                          bookingId,
                                          bookingStatus:
                                              bookingDetails.bookingStatus,
                                          isSubBooking: isSubBooking,
                                        ),
                            ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
