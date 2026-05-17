import 'package:afriendorse/feature/booking/widget/booking_status_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class BookingInfo extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  final BookingDetailsController bookingDetailsTabController;

  const BookingInfo({
    super.key,
    required this.bookingDetails,
    required this.bookingDetailsTabController,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${'booking'.tr} #${bookingDetails.readableId}',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                /* BookingStatusButtonWidget(
                  bookingStatus: bookingDetails.bookingStatus,
                ), */
              ],
            ),
          ),

          // ── Info Rows ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: 'booking_date'.tr,
                  value: DateConverter.dateMonthYearTimeTwentyFourFormat(
                    DateConverter.isoUtcStringToLocalDate(
                      bookingDetails.createdAt!,
                    ),
                  ),
                ),
                if (bookingDetails.serviceSchedule != null) ...[
                  _buildRowDivider(),
                  _buildInfoRow(
                    context,
                    icon: Icons.event_available_rounded,
                    label: 'service_schedule_date'.tr,
                    value: DateConverter.dateMonthYearTimeTwentyFourFormat(
                      DateTime.tryParse(bookingDetails.serviceSchedule!)!,
                    ),
                  ),
                ],
                /*  _buildRowDivider(),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_rounded,
                  label: 'address'.tr,
                  value:
                      bookingDetails.serviceAddress?.address ??
                      bookingDetails.subBooking?.serviceAddress?.address ??
                      'no_address_found'.tr,
                  maxLines: 2,
                ), */
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));
}
