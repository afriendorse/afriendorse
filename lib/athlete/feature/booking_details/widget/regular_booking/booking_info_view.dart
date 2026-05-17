// ═══════════════════════════════════════════════════════════════════════════
// booking_information_view.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingInformationView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;

  const BookingInformationView({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Get.isDarkMode;

    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient header ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [primary.withOpacity(0.2), primary.withOpacity(0.1)]
                        : [
                            primary.withOpacity(0.13),
                            primary.withOpacity(0.05),
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // ── Icon box ────────────────────────────────────────
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSubBooking
                            ? Icons.repeat_rounded
                            : Icons.confirmation_number_rounded,
                        size: 17,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ── Booking ID ──────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${'booking'.tr} #${bookingDetails.readableId}',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: primary,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isSubBooking)
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

                    // ── Status chip ─────────────────────────────────────
                    _buildStatusChip(context, isDark),
                  ],
                ),
              ),

              // ── Date rows ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    _buildDateRow(
                      context,
                      primary: primary,
                      icon: Icons.calendar_today_rounded,
                      label: 'booking_date'.tr,
                      value: DateConverter.dateMonthYearTime(
                        DateConverter.isoUtcStringToLocalDate(
                          bookingDetails.createdAt!,
                        ),
                      ),
                    ),
                    if (bookingDetails.serviceSchedule != null) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      _buildDateRow(
                        context,
                        primary: primary,
                        icon: Icons.event_available_rounded,
                        label: 'scheduled_date'.tr,
                        value: DateConverter.dateMonthYearTime(
                          DateTime.tryParse(bookingDetails.serviceSchedule!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Primary background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        bookingDetails.bookingStatus!.tr,
        style: robotoMedium.copyWith(
          fontSize: 11,
          color: Colors.white, // White text
        ),
      ),
    );
  }

  /*
  Widget _buildStatusChip(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.withOpacity(0.2)
            : context.customThemeColors.buttonBackgroundColorMap[bookingDetails
                      .bookingStatus] ??
                  Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              (context.customThemeColors.buttonTextColorMap[bookingDetails
                          .bookingStatus] ??
                      Colors.grey)
                  .withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        bookingDetails.bookingStatus!.tr,
        style: robotoMedium.copyWith(
          fontSize: 11,
          color: isDark
              ? Theme.of(context).primaryColorLight
              : context.customThemeColors.buttonTextColorMap[bookingDetails
                    .bookingStatus],
        ),
      ),
    );
  } */

  Widget _buildDateRow(
    BuildContext context, {
    required Color primary,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: primary.withOpacity(0.7)),
        ),
        const SizedBox(width: 10),
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
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
