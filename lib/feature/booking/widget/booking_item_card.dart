// ═══════════════════════════════════════════════════════════════════════════
// booking_item_card.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/common/models/popup_menu_model.dart';
import 'package:afriendorse/feature/booking/widget/booking_status_widget.dart';
import 'package:afriendorse/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class BookingItemCard extends StatelessWidget {
  final BookingModel bookingModel;
  final int index;

  const BookingItemCard({
    super.key,
    required this.bookingModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Get.find<ThemeController>().darkTheme;
    final String bookingStatus = bookingModel.bookingStatus!;
    final bool isRepeat = bookingModel.isRepeatBooking == 1;
    final scheduleDate = BookingHelper.getRepeatBookingCurrentSchedule(
      bookingModel,
    );

    return GetBuilder<ServiceBookingController>(
      builder: (serviceBookingController) {
        return GestureDetector(
          onTap: () => _navigateToDetails(isRepeat),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.12), width: 1),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: primary.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Banner ──────────────────────────────────────
                _buildHeader(
                  context,
                  primary,
                  isDark,
                  isRepeat,
                  bookingStatus,
                  serviceBookingController,
                ),

                // ── Content ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Date Chips Row ────────────────────────────────
                      _buildDateChips(context, primary, scheduleDate),

                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // ── Divider ───────────────────────────────────────
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: primary.withOpacity(0.07),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      // ── Footer: Status + Amount ───────────────────────
                      _buildFooter(context, primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    Color primary,
    bool isDark,
    bool isRepeat,
    String bookingStatus,
    ServiceBookingController serviceBookingController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        // Light primary tint for the header strip
        gradient: LinearGradient(
          colors: isDark
              ? [primary.withOpacity(0.18), primary.withOpacity(0.10)]
              : [primary.withOpacity(0.13), primary.withOpacity(0.06)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // ── Booking icon ─────────────────────────────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isRepeat
                  ? Icons.repeat_rounded
                  : Icons.confirmation_number_rounded,
              size: 16,
              color: primary,
            ),
          ),

          const SizedBox(width: 10),

          // ── Booking ID ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${'booking'.tr} #${bookingModel.readableId}',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: primary,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (isRepeat)
                  Text(
                    'repeat_booking'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                      color: primary.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),

          // ── Repeat pill ──────────────────────────────────────────────
          if (isRepeat) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.repeat_rounded,
                    color: Colors.green,
                    size: 10,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'repeat'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: 9,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],

          // ── More menu ────────────────────────────────────────────────
          _buildPopupMenu(
            context,
            bookingStatus,
            isRepeat,
            primary,
            serviceBookingController,
          ),
        ],
      ),
    );
  }

  // ── Date Chips ────────────────────────────────────────────────────────────

  Widget _buildDateChips(
    BuildContext context,
    Color primary,
    String? scheduleDate,
  ) {
    final bookingDate = DateConverter.dateMonthYearTimeTwentyFourFormat(
      DateConverter.isoUtcStringToLocalDate(bookingModel.createdAt.toString()),
    );

    final scheduleDateFormatted = scheduleDate != null
        ? DateConverter.dateMonthYearTimeTwentyFourFormat(
            DateTime.tryParse(scheduleDate)!,
          )
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateRow(
          context,
          primary: primary,
          icon: Icons.calendar_today_rounded,
          label: 'booking_date'.tr,
          value: bookingDate,
        ),
        if (scheduleDateFormatted != null) ...[
          const SizedBox(height: 6),
          _buildDateRow(
            context,
            primary: primary,
            icon: Icons.event_available_rounded,
            label: 'service_date'.tr,
            value: scheduleDateFormatted,
          ),
        ],
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context, {
    required Color primary,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 13, color: primary.withOpacity(0.7)),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(0.45),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.ltr,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(0.75),
            ),
          ),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status badge
        Flexible(
          child: BookingStatusButtonWidget(
            bookingStatus: bookingModel.bookingStatus,
          ),
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

        // Amount pill
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.2), width: 0.8),
            ),
            child: Text(
              PriceConverter.convertPrice(
                bookingModel.totalBookingAmount!.toDouble(),
              ),
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Popup Menu ────────────────────────────────────────────────────────────

  Widget _buildPopupMenu(
    BuildContext context,
    String bookingStatus,
    bool isRepeat,
    Color primary,
    ServiceBookingController serviceBookingController,
  ) {
    return PopupMenuButton<PopupMenuModel>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: primary.withOpacity(0.12)),
      ),
      surfaceTintColor: Theme.of(context).cardColor,
      color: Theme.of(context).cardColor,
      position: PopupMenuPosition.under,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.12),
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) {
        return serviceBookingController
            .getPopupMenuList(
              status: bookingStatus,
              isRepeatBooking: isRepeat,
              isCustomizeBooking: bookingModel.isCustomizeBooking ?? false,
            )
            .map(
              (PopupMenuModel option) => PopupMenuItem<PopupMenuModel>(
                value: option,
                height: 46,
                onTap: () async => _handleMenuAction(
                  context,
                  option,
                  isRepeat,
                  serviceBookingController,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(option.icon, size: 16, color: primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      option.title.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(Icons.more_vert_rounded, size: 16, color: primary),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _navigateToDetails(bool isRepeat) {
    if (isRepeat) {
      Get.toNamed(
        RouteHelper.getRepeatBookingDetailsScreen(bookingId: bookingModel.id!),
      );
    } else {
      Get.toNamed(
        RouteHelper.getBookingDetailsScreen(bookingID: bookingModel.id!),
      );
    }
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    PopupMenuModel option,
    bool isRepeat,
    ServiceBookingController serviceBookingController,
  ) async {
    switch (option.title) {
      case 'booking_details':
        _navigateToDetails(isRepeat);
        break;

      case 'rebook':
        serviceBookingController.updateRebookIndex(index);
        await serviceBookingController.checkCartSubcategory(
          bookingModel.id!,
          bookingModel.subCategoryId!,
        );
        break;

      case 'download_invoice':
        final languageCode =
            Get.find<LocalizationController>().locale.languageCode;
        final uri = isRepeat
            ? '${AppConstants.baseUrl}${AppConstants.repeatBookingInvoiceUrl}${bookingModel.id}/$languageCode'
            : '${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${bookingModel.id}/$languageCode';
        await _launchUrl(Uri.parse(uri));
        break;

      case 'cancel':
        Get.dialog(
          ConfirmationDialog(
            icon: Images.warning,
            title: isRepeat
                ? 'are_you_sure_to_cancel_this_full_booking'.tr
                : 'are_you_sure_to_cancel_your_order'.tr,
            description: isRepeat
                ? 'once_cancel_full_booking'.tr
                : 'your_order_will_be_cancel'.tr,
            noButtonText: 'yes_cancel'.tr,
            noButtonColor: Theme.of(context).colorScheme.primary,
            noTextColor: Colors.white,
            yesButtonText: 'not_now'.tr,
            yesButtonColor: Theme.of(context).colorScheme.error,
            yesTextColor: Colors.white,
            buttonFontSize: Dimensions.fontSizeSmall + 1,
            onYesPressed: () => Get.back(),
            onNoPressed: () async {
              Get.back();
              Get.dialog(const CustomLoader(), barrierDismissible: false);
              await Get.find<BookingDetailsController>().bookingCancel(
                bookingId: bookingModel.id ?? '',
                fromListScreen: true,
              );
              Get.back();
            },
          ),
          useSafeArea: false,
        );
        break;
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
