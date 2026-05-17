// ═══════════════════════════════════════════════════════════════════════════
// booking_details_section.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/feature/booking/widget/booking_approval_widget.dart';
import 'package:afriendorse/feature/booking/widget/booking_otp_widget.dart';
import 'package:afriendorse/feature/booking/widget/booking_photo_evidence.dart';
import 'package:afriendorse/feature/booking/widget/booking_service_location.dart';
import 'package:afriendorse/feature/booking/widget/payment_info_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/feature/booking/widget/regular/booking_summery_widget.dart';
import 'package:afriendorse/feature/booking/widget/provider_info.dart';
import 'package:afriendorse/feature/booking/widget/service_man_info.dart';
import 'booking_screen_shimmer.dart';

class BookingDetailsSection extends StatelessWidget {
  final String? id;
  final bool isSubBooking;
  const BookingDetailsSection({super.key, this.id, required this.isSubBooking});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () async {
        if (id != null) {
          if (isSubBooking) {
            await Get.find<BookingDetailsController>().getSubBookingDetails(
              bookingId: id!,
            );
          } else {
            await Get.find<BookingDetailsController>().getBookingDetails(
              bookingId: id!,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsTabController) {
            BookingDetailsContent? bookingDetails = isSubBooking
                ? bookingDetailsTabController.subBookingDetailsContent
                : bookingDetailsTabController.bookingDetailsContent;

            if (bookingDetails == null) {
              return const SingleChildScrollView(child: BookingScreenShimmer());
            }

            final bookingStatus = bookingDetails.bookingStatus ?? '';
            final isLoggedIn = Get.find<AuthController>().isLoggedIn();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ── Booking Info Card ──────────────────────────────
                      BookingInfo(
                        bookingDetails: bookingDetails,
                        bookingDetailsTabController:
                            bookingDetailsTabController,
                        isSubBooking: isSubBooking,
                      ),

                      // ── OTP Widget ─────────────────────────────────────
                      if (Get.find<SplashController>()
                              .configModel
                              .content!
                              .confirmationOtpStatus! &&
                          (bookingStatus == 'accepted' ||
                              bookingStatus == 'ongoing'))
                        Padding(
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault,
                          ),
                          child: BookingApprovalWidget(
                            bookingDetails: bookingDetails,
                          ),
                        )
                      //
                      else
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ── Payment ────────────────────────────────────────
                      PaymentView(
                        bookingDetails: bookingDetails,
                        isSubBooking: isSubBooking,
                      ),

                      //    const SizedBox(height: Dimensions.paddingSizeLarge),

                      // ── Service Location ───────────────────────────────
                      //      BookingServiceLocation(bookingDetails: bookingDetails),

                      //      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // ── Booking Summary ────────────────────────────────
                      BookingSummeryWidget(bookingDetails: bookingDetails),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // ── Provider & Serviceman ──────────────────────────
                      if (bookingDetails.provider != null ||
                          bookingDetails.serviceman != null)
                        _buildAssignedTeamSection(context, bookingDetails),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // ── Photo Evidence ─────────────────────────────────
                      if (bookingDetails.photoEvidenceFullPath != null &&
                          bookingDetails.photoEvidenceFullPath!.isNotEmpty)
                        BookingPhotoEvidence(
                          bookingDetailsContent: bookingDetails,
                        ),

                      SizedBox(
                        height: bookingStatus == 'completed' && isLoggedIn
                            ? Dimensions.paddingSizeExtraLarge * 3
                            : Dimensions.paddingSizeExtraLarge,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // ── FAB ───────────────────────────────────────────────────────────
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GetBuilder<BookingDetailsController>(
          builder: (bookingDetailsController) {
            final content = bookingDetailsController.bookingDetailsContent;
            if (content == null) return const SizedBox();

            final status = content.bookingStatus ?? '';
            final isLoggedIn = Get.find<AuthController>().isLoggedIn();
            final isActive = status == 'accepted' || status == 'ongoing';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: SizedBox()),

                // ── Chat FAB ─────────────────────────────────────────
                if (isLoggedIn && isActive)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: _buildChatFab(
                      context,
                      content,
                      bookingDetailsController,
                    ),
                  ),

                // ── Completed Actions ─────────────────────────────────
                if (status == 'completed')
                  _buildCompletedActions(
                    context,
                    content,
                    bookingDetailsController,
                    isLoggedIn,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Assigned Team Section ──────────────────────────────────────────────

  Widget _buildAssignedTeamSection(
    BuildContext context,
    BookingDetailsContent bookingDetails,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        /* Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeExtraSmall,
            bottom: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'assigned_team'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ), */
        if (bookingDetails.provider != null)
          ProviderInfo(provider: bookingDetails.provider!),

        if (bookingDetails.provider != null &&
            bookingDetails.serviceman != null)
          const SizedBox(height: Dimensions.paddingSizeSmall),

        if (bookingDetails.serviceman != null)
          ServiceManInfo(user: bookingDetails.serviceman!.user!),
      ],
    );
  }

  // ── Chat FAB ───────────────────────────────────────────────────────────

  Widget _buildChatFab(
    BuildContext context,
    BookingDetailsContent content,
    BookingDetailsController controller,
  ) {
    return FloatingActionButton(
      heroTag: 'chat_fab',
      elevation: 4,
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        if (content.provider != null) {
          showModalBottomSheet(
            useRootNavigator: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (_) => CreateChannelDialog(isSubBooking: isSubBooking),
          );
        } else {
          customSnackBar(
            'provider_or_service_man_assigned'.tr,
            type: ToasterMessageType.info,
          );
        }
      },
      child: Icon(
        Icons.message_rounded,
        color: Theme.of(context).primaryColorLight,
      ),
    );
  }

  // ── Completed Action Buttons ───────────────────────────────────────────
  Widget _buildCompletedActions(
    BuildContext context,
    BookingDetailsContent content,
    BookingDetailsController controller,
    bool isLoggedIn,
  ) {
    final isCustomize = content.isCustomizeBooking ?? false;

    return Container(
      width: MediaQuery.of(context).size.width, // <-- full screen width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoggedIn) ...[
            SizedBox(
              width: 160,
              child: _buildActionButton(
                context,
                label: 'review'.tr,
                icon: Icons.star_rounded,
                isPrimary: false,
                onTap: () => showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReviewRecommendationDialog(id: content.id!),
                ),
              ),
            ),
            if (!isCustomize)
              const SizedBox(width: Dimensions.paddingSizeDefault),
          ],
          if (!isCustomize)
            SizedBox(
              width: 160,
              child: GetBuilder<ServiceBookingController>(
                builder: (serviceBookingController) => _buildActionButton(
                  context,
                  label: 'rebook'.tr,
                  icon: Icons.replay_rounded,
                  isPrimary: true,
                  isLoading: serviceBookingController.isLoading,
                  onTap: () => serviceBookingController.checkCartSubcategory(
                    content.id!,
                    content.subCategoryId!,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? Colors.white : primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isPrimary ? Colors.white : primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isPrimary ? Colors.white : primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
