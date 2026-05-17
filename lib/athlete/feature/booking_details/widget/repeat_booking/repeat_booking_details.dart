import 'package:afriendorse/athlete/feature/booking_details/widget/booking_service_location.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/all_booking_summary_widget.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/next_upcoming_service_widget.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/repeat_booking_info_view.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/repeat_booking_status_change_dropdown_button.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/repeat_booking/repeat_booking_summery_widget.dart';
import 'package:afriendorse/athlete/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RepeatBookingDetailsWidget extends StatelessWidget {
  final String bookingId;
  final TabController? tabController;
  final bool isSubBooking;
  const RepeatBookingDetailsWidget({
    super.key,
    required this.bookingId,
    this.tabController,
    required this.isSubBooking,
  });
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      initState: (_) => Get.find<BookingDetailsController>().showHideExpandView(
        0,
        shouldUpdate: false,
      ),
      builder: (bookingDetailsController) {
        final bookingDetails = bookingDetailsController.bookingDetails?.content;

        if (bookingDetails == null &&
            bookingDetailsController.bookingDetails == null) {
          return const Center(child: BookingDetailsShimmer());
        } else if (bookingDetailsController.bookingDetails != null &&
            bookingDetailsController.bookingDetails!.content == null) {
          return SizedBox(
            height: Get.height * 0.7,
            child: BookingEmptyScreen(bookingId: bookingId),
          );
        } else {
          ConfigModel configModel = Get.find<SplashController>().configModel;
          String bookingStatus = bookingDetails?.bookingStatus ?? "";
          int isGuest = bookingDetails?.isGuest ?? 0;
          bool isPartial =
              (bookingDetails!.partialPayments != null &&
                  bookingDetails.partialPayments!.isNotEmpty)
              ? true
              : false;
          String? providerId = Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.id;

          RepeatBooking? nextBooking =
              BookingHelper.getNextUpcomingRepeatBooking(
                bookingDetails,
                providerId,
              );

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Get.find<BookingDetailsController>()
                          .getBookingDetails(bookingId, reload: false);
                    },
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),

                              Expanded(
                                child: CustomButton(
                                  btnTxt: "edit_booking".tr,
                                  icon: Icons.edit,
                                  onPressed:
                                      (nextBooking != null &&
                                          nextBooking.isPaid == 0 &&
                                          configModel
                                                  .content
                                                  ?.providerCanEditBooking ==
                                              1 &&
                                          !isPartial &&
                                          (bookingStatus == "accepted" ||
                                              bookingStatus == "ongoing") &&
                                          (isGuest == 1 &&
                                                  bookingDetails
                                                          .paymentMethod !=
                                                      "cash_after_service"
                                              ? false
                                              : true))
                                      ? () {
                                          Get.find<
                                                BusinessSubscriptionController
                                              >()
                                              .openTrialEndBottomSheet()
                                              .then((isTrail) {
                                                if (isTrail) {
                                                  Get.to(
                                                    () =>
                                                        const BookingEditScreen(
                                                          bookingEditType:
                                                              BookingEditType
                                                                  .repeat,
                                                        ),
                                                  );
                                                }
                                              });
                                        }
                                      : null,
                                ),
                              ),

                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              CustomButton(
                                width: 120,
                                color: Colors.blue,
                                icon: Icons.file_present,
                                btnTxt: "invoice".tr,
                                onPressed: () async {
                                  showCustomDialog(child: const CustomLoader());
                                  String languageCode =
                                      Get.find<LocalizationController>()
                                          .locale
                                          .languageCode;
                                  String uri =
                                      "${AppConstants.baseUrl}${AppConstants.fullRepeatBookingInvoiceUrl}${bookingDetails.id}/$languageCode";
                                  if (kDebugMode) {
                                    print("Uri : $uri");
                                  }
                                  await _launchUrl(Uri.parse(uri));
                                  Get.back();
                                },
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          const RepeatBookingInformationView(),

                          BookingServiceLocation(
                            bookingDetails: bookingDetails,
                            isSubBooking: false,
                            bookingEditType: BookingEditType.repeat,
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          nextBooking != null
                              ? NextUpcomingServiceWidget(booking: nextBooking)
                              : const SizedBox(),
                          SizedBox(
                            height: nextBooking != null
                                ? Dimensions.paddingSizeDefault
                                : 0,
                          ),

                          AllBookingSummaryWidget(
                            tabController: tabController,
                            bookingDetails: bookingDetails,
                          ),

                          RepeatBookingSummeryWidget(
                            bookingDetails: bookingDetails,
                            nextBooking: nextBooking,
                          ),

                          BookingDetailsCustomerInfo(
                            bookingDetails: bookingDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                ((bookingDetails.bookingStatus == "pending" ||
                        bookingDetails.bookingStatus == "accepted" ||
                        bookingDetails.bookingStatus == "ongoing"))
                    ? RepeatBookingChangeStatusDropdownButton(
                        bookingDetails: bookingDetails,
                        bookingId: bookingDetails.id!,
                        isSubBooking: isSubBooking,
                      )
                    : const SizedBox(),
              ],
            ),

            floatingActionButton:
                bookingDetailsController.isShowChattingButton(
                  bookingDetails,
                  tabController,
                )
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: GetPlatform.isAndroid ? 70 : 35,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: FloatingActionButton(
                            shape: const CircleBorder(),

                            heroTag: "1",
                            elevation: 0.0,
                            backgroundColor: Colors.green,
                            onPressed: () async => await launchUrl(
                              Uri(
                                scheme: 'tel',
                                path:
                                    bookingDetails
                                        .serviceAddress
                                        ?.contactPersonNumber ??
                                    bookingDetails
                                        .subBooking
                                        ?.serviceAddress
                                        ?.contactPersonNumber ??
                                    "",
                              ),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Icon(
                              Icons.call,
                              color: light.cardColor,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        SizedBox(
                          height: 48,
                          width: 48,
                          child: FloatingActionButton(
                            shape: const CircleBorder(),
                            heroTag: "2",
                            elevation: 0.0,
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              if (Get.find<UserProfileController>()
                                  .checkAvailableFeatureInSubscriptionPlan(
                                    featureType: "chat",
                                  )) {
                                showCustomBottomSheet(
                                  child: const CreateChannelDialog(
                                    isSubBooking: false,
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              Icons.message_rounded,
                              color: light.cardColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          );
        }
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
