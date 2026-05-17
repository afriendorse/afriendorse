// ═══════════════════════════════════════════════════════════════════════════
// booking_details_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/athlete/feature/booking_details/widget/booking_service_location.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/deal_receive_payment_bar.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingDetailsWidget extends StatelessWidget {
  final String? bookingId;
  final String? subBookingId;
  final bool isSubBooking;
  final TabController? tabController;

  const BookingDetailsWidget({
    super.key,
    this.bookingId,
    required this.isSubBooking,
    this.tabController,
    this.subBookingId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      initState: (_) => Get.find<BookingDetailsController>().showHideExpandView(
        0,
        shouldUpdate: false,
      ),
      builder: (bookingDetailsController) {
        final bookingDetailsContent = isSubBooking
            ? bookingDetailsController.subBookingDetails
            : bookingDetailsController.bookingDetails;

        // ── Loading ──────────────────────────────────────────────────────
        if (bookingDetailsContent == null &&
            bookingDetailsContent?.content == null) {
          return const Center(child: BookingDetailsShimmer());
        }

        // ── Empty ────────────────────────────────────────────────────────
        if (bookingDetailsContent != null &&
            bookingDetailsContent.content == null) {
          return SizedBox(
            height: Get.height * 0.7,
            child: BookingEmptyScreen(bookingId: bookingId ?? ''),
          );
        }

        // ── Content ──────────────────────────────────────────────────────
        final bookingDetails = isSubBooking
            ? bookingDetailsController.subBookingDetails!.content
            : bookingDetailsController.bookingDetails!.content;

        final bool isPartial =
            bookingDetails!.partialPayments != null &&
            bookingDetails.partialPayments!.isNotEmpty;
        final ConfigModel configModel =
            Get.find<SplashController>().configModel;
        final String bookingStatus = bookingDetails.bookingStatus ?? '';
        final int isGuest = bookingDetails.isGuest ?? 0;
        final bool subBookingPaid = isSubBooking && bookingDetails.isPaid == 1;
        final primary = Theme.of(context).colorScheme.primary;

        // ✅ This is the key change:
        // Show BOTH ReceivePaymentBar and ChangeStatusDropdownButton only when
        // the screen is in a state that allows status actions.
        final bool canShowStatusActions =
            (!isSubBooking ||
                (isSubBooking && bookingDetails.bookingStatus != 'pending')) &&
            (bookingDetails.bookingStatus == 'pending' ||
                bookingDetails.bookingStatus == 'accepted' ||
                bookingDetails.bookingStatus == 'ongoing');

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              // ── Scrollable content ─────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: primary,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () async {
                    if (isSubBooking) {
                      await Get.find<BookingDetailsController>()
                          .getBookingSubDetails(
                            subBookingId ?? '',
                            reload: false,
                          );
                    } else {
                      await Get.find<BookingDetailsController>()
                          .getBookingDetails(bookingId ?? '', reload: false);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // ── Action Buttons (Edit + Invoice) ──────────────
                        /*   if (bookingDetails.bookingStatus != 'pending')
                          _buildActionButtons(
                            context,
                            bookingDetails,
                            bookingStatus,
                            isPartial,
                            isGuest,
                            subBookingPaid,
                            configModel,
                            primary,
                          ), 

                        const SizedBox(height: Dimensions.paddingSizeSmall), */

                        // ── Sections ─────────────────────────────────────
                        BookingInformationView(
                          bookingDetails: bookingDetails,
                          isSubBooking: isSubBooking,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        /*  BookingServiceLocation(
                          bookingDetails: bookingDetails,
                          isSubBooking: isSubBooking,
                          bookingEditType: isSubBooking
                              ? BookingEditType.subBooking
                              : BookingEditType.regular,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall), */
                        BookingSummeryView(bookingDetails: bookingDetails),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        PaymentInfoView(bookingDetails: bookingDetails),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        BookingDetailsCustomerInfo(
                          bookingDetails: bookingDetails,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        ServiceCompletedPhotoEvidence(
                          bookingDetails: bookingDetails,
                          isSubBooking: isSubBooking,
                        ),

                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Status Dropdown ────────────────────────────────────────
              // ── Status + Approval Gate (bottom) ─────────────────────────
              if (canShowStatusActions) ...[
                DealReceivePaymentBar(
                  bookingDetails: bookingDetails,
                  isSubBooking: isSubBooking,
                ),

                ChangeStatusDropdownButton(
                  bookingDetails: bookingDetails,
                  bookingId: bookingDetails.id!,
                  isSubBooking: isSubBooking,
                ),
              ],
              //
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),

          // ── FABs ─────────────────────────────────────────────────────────
          floatingActionButton:
              bookingDetailsController.isShowChattingButton(
                bookingDetails,
                tabController,
              )
              ? _buildFabs(context, bookingDetails)
              : null,
        );
      },
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext context,
    BookingDetailsContent bookingDetails,
    String bookingStatus,
    bool isPartial,
    int isGuest,
    bool subBookingPaid,
    ConfigModel configModel,
    Color primary,
  ) {
    final canEdit =
        !subBookingPaid &&
        configModel.content?.providerCanEditBooking == 1 &&
        !isPartial &&
        (bookingStatus == 'accepted' || bookingStatus == 'ongoing') &&
        !(isGuest == 1 && bookingDetails.paymentMethod != 'cash_after_service');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        children: [
          // ── Edit button ────────────────────────────────────────────────
          Expanded(
            child: _ActionButton(
              label: 'edit_booking'.tr,
              icon: Icons.edit_rounded,
              isPrimary: true,
              isDisabled: !canEdit,
              onTap: canEdit
                  ? () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrail) {
                            if (isTrail) {
                              Get.to(
                                () => BookingEditScreen(
                                  bookingEditType: isSubBooking
                                      ? BookingEditType.subBooking
                                      : BookingEditType.regular,
                                ),
                              );
                            }
                          });
                    }
                  : null,
            ),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          // ── Invoice button ─────────────────────────────────────────────
          _ActionButton(
            label: 'invoice'.tr,
            icon: Icons.file_present_rounded,
            isPrimary: false,
            accentColor: Colors.blue,
            width: 120,
            onTap: () async {
              showCustomDialog(child: const CustomLoader());
              final languageCode =
                  Get.find<LocalizationController>().locale.languageCode;
              final uri =
                  '${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetails.id}/$languageCode';
              await _launchUrl(Uri.parse(uri));
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  // ── FABs ──────────────────────────────────────────────────────────────────

  Widget _buildFabs(
    BuildContext context,
    BookingDetailsContent bookingDetails,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: GetPlatform.isAndroid ? 70 : 35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Call FAB ──────────────────────────────────────────────────
          /*    _buildFab(
            context,
            heroTag: 'fab_call',
            backgroundColor: Colors.green,
            icon: Icons.call_rounded,
            onTap: () async => launchUrl(
              Uri(
                scheme: 'tel',
                path:
                    bookingDetails.serviceAddress?.contactPersonNumber ??
                    bookingDetails
                        .subBooking
                        ?.serviceAddress
                        ?.contactPersonNumber ??
                    '',
              ),
              mode: LaunchMode.externalApplication,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall), */

          // ── Chat FAB ──────────────────────────────────────────────────
          _buildFab(
            context,
            heroTag: 'fab_chat',
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icons.message_rounded,
            onTap: () {
              if (Get.find<UserProfileController>()
                  .checkAvailableFeatureInSubscriptionPlan(
                    featureType: 'chat',
                  )) {
                showCustomBottomSheet(
                  child: CreateChannelDialog(isSubBooking: isSubBooking),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFab(
    BuildContext context, {
    required String heroTag,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        elevation: 0,
        shape: const CircleBorder(),
        backgroundColor: backgroundColor,
        onPressed: onTap,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}

// ── Action Button Helper ───────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDisabled;
  final Color? accentColor;
  final double? width;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.isDisabled = false,
    this.accentColor,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;
    final effectiveColor = isDisabled ? color.withOpacity(0.4) : color;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: width,
        height: 46,
        decoration: BoxDecoration(
          color: isPrimary ? effectiveColor : effectiveColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: effectiveColor.withOpacity(isPrimary ? 0 : 0.3),
          ),
          boxShadow: isPrimary && !isDisabled
              ? [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isPrimary ? Colors.white : effectiveColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isPrimary ? Colors.white : effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// booking_empty_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

class BookingEmptyScreen extends StatelessWidget {
  final String? bookingId;
  const BookingEmptyScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Illustration container ─────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Image.asset(Images.noResults, color: primary),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              'information_not_found'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              'booking_details_unavailable'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            // ── Go Back button ─────────────────────────────────────────
            GestureDetector(
              onTap: () {
                Get.find<BookingRequestController>().removeBookingItemFromList(
                  bookingId ?? '',
                  shouldUpdate: true,
                  bookingStatus: '',
                );
                Get.back();
              },
              child: Container(
                height: 46,
                width: 160,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusExtraLarge,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'go_back'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
