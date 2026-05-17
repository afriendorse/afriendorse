// ═══════════════════════════════════════════════════════════════════════════
// booking_status.dart  (BookingStatus + Timeline1)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/connector_theme.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/connectors.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/indicator_theme.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/indicators.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/timeline_theme.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/timeline_tile_builder.dart';
import 'package:afriendorse/athlete/feature/booking_details/widget/timeline/timelines.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingStatus extends StatefulWidget {
  final String? bookingId;
  final bool isSubBooking;

  const BookingStatus({super.key, this.bookingId, required this.isSubBooking});

  @override
  State<BookingStatus> createState() => _BookingStatusState();
}

class _BookingStatusState extends State<BookingStatus> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().updateServicePageCurrentState(
      BookingDetailsTabControllerState.status,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final bookingDetailsContent = widget.isSubBooking
            ? bookingDetailsController.subBookingDetails
            : bookingDetailsController.bookingDetails;

        if (bookingDetailsContent == null &&
            bookingDetailsContent?.content == null) {
          return const Center(child: BookingDetailsShimmer());
        }

        if (bookingDetailsController.bookingDetails != null &&
            bookingDetailsController.bookingDetails!.content == null) {
          return SizedBox(
            height: Get.height * 0.7,
            child: BookingEmptyScreen(bookingId: widget.bookingId),
          );
        }

        final bookingDetails = widget.isSubBooking
            ? bookingDetailsController.subBookingDetails!.content!
            : bookingDetailsController.bookingDetails!.content!;

        final primary = Theme.of(context).colorScheme.primary;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            children: [
              // ── Info Summary Card ──────────────────────────────────────
              _buildInfoCard(context, bookingDetails, primary),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // ── Timeline section header ────────────────────────────────
              _buildSectionHeader(context, 'activity_timeline'.tr, primary),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // ── Timeline ───────────────────────────────────────────────
              Timeline1(
                bookingDetails: bookingDetails,
                statusHistories: bookingDetails.statusHistories,
                scheduleHistories: bookingDetails.scheduleHistories,
                increment:
                    bookingDetails.scheduleHistories!.length > 1 &&
                        bookingDetails.statusHistories!.isNotEmpty
                    ? 2
                    : 1,
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    BookingDetailsContent bookingDetails,
    Color primary,
  ) {
    final isPaid = bookingDetails.isPaid == 1;
    final isDark = Get.isDarkMode;

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
      child: Column(
        children: [
          // ── Card header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [primary.withOpacity(0.2), primary.withOpacity(0.1)]
                    : [primary.withOpacity(0.13), primary.withOpacity(0.05)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'booking_overview'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Info rows ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                _buildInfoRow(
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
                _buildDivider(),
                if (bookingDetails.serviceSchedule != null) ...[
                  _buildInfoRow(
                    context,
                    primary: primary,
                    icon: Icons.event_available_rounded,
                    label: 'scheduled_date'.tr,
                    value: DateConverter.dateMonthYearTime(
                      DateTime.tryParse(bookingDetails.serviceSchedule!),
                    ),
                  ),
                  _buildDivider(),
                ],
                // Payment Status
                _buildInfoRow(
                  context,
                  primary: primary,
                  icon: Icons.payment_rounded,
                  label: 'payment_status'.tr,
                  trailing: _buildBadge(
                    label: isPaid ? 'paid'.tr : 'unpaid'.tr,
                    backgroundColor: isPaid
                        ? Colors.green
                        : Colors.red, // Changed from 'color'
                    textColor: Colors.white, // Optional: add white text
                    icon: isPaid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                  ),
                ),
                _buildDivider(),

                _buildInfoRow(
                  context,
                  primary: primary,
                  icon: Icons.bookmark_rounded,
                  label: 'Booking_Status'.tr,
                  trailing: _buildBadge(
                    label: bookingDetails.bookingStatus!.tr,
                    backgroundColor: primary, // Primary background
                    textColor: Colors.white, // White text
                    icon: Icons.circle,
                    iconSize: 8,
                  ),
                ),

                /*   _buildInfoRow(
                  context,
                  primary: primary,
                  icon: Icons.bookmark_rounded,
                  label: 'Booking_Status'.tr,
                  trailing: _buildBadge(
                    label: bookingDetails.bookingStatus!.tr,
                    color:
                        context
                            .customThemeColors
                            .buttonTextColorMap[bookingDetails.bookingStatus] ??
                        primary,
                    icon: Icons.circle,
                    iconSize: 8,
                  ),
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
    required Color primary,
    required IconData icon,
    required String label,
    String? value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ),
          if (value != null)
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.85),
              ),
            ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color backgroundColor, // Changed from 'color' to 'backgroundColor'
    Color? textColor, // Optional text color (defaults to white)
    required IconData icon,
    double iconSize = 11,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor, // Solid primary background (no opacity)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3), // Subtle border
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: textColor ?? Colors.white, // White icon
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: textColor ?? Colors.white, // White text
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
    double iconSize = 11,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(label, style: robotoMedium.copyWith(fontSize: 11, color: color)),
        ],
      ),
    );
  }
*/
  Widget _buildDivider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color primary,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────

class Timeline1 extends StatelessWidget {
  final BookingDetailsContent? bookingDetails;
  final List<StatusHistories>? statusHistories;
  final List<ScheduleHistories>? scheduleHistories;
  final int increment;

  const Timeline1({
    super.key,
    required this.statusHistories,
    this.scheduleHistories,
    required this.increment,
    this.bookingDetails,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorTheme: const IndicatorThemeData(position: 0, size: 34.0),
        connectorTheme: ConnectorThemeData(
          thickness: 2,
          color: primary.withOpacity(0.25),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: Get.find<LocalizationController>().isLtr ? 0 : 10,
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: statusHistories!.length + increment,
        contentsBuilder: (_, index) {
          if (index == 0) return _buildBookingPlacedCard(context, primary);
          if (index == 1 && statusHistories!.isNotEmpty) {
            return _buildStatusCard(context, primary, statusHistories![0], 0);
          }
          if (index == 2 && (scheduleHistories?.length ?? 0) > 1) {
            return _buildScheduleChangesCard(context, primary);
          }
          final si = index - increment;
          if (si >= 0 && si < statusHistories!.length) {
            return _buildStatusCard(context, primary, statusHistories![si], si);
          }
          return const SizedBox();
        },
        connectorBuilder: (_, index, __) => SolidLineConnector(
          color: index == 0 ? Colors.transparent : primary.withOpacity(0.3),
          thickness: 2,
        ),
        indicatorBuilder: (_, index) =>
            _buildIndicator(context, primary, index),
      ),
    );
  }

  // ── Indicator ─────────────────────────────────────────────────────────────

  Widget _buildIndicator(BuildContext context, Color primary, int index) {
    final icons = [
      Icons.bookmark_added_rounded,
      Icons.swap_horiz_rounded,
      Icons.schedule_rounded,
    ];
    final icon = index < icons.length ? icons[index] : Icons.adjust_rounded;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 15),
    );
  }

  // ── Timeline Cards ────────────────────────────────────────────────────────

  Widget _buildBookingPlacedCard(BuildContext context, Color primary) {
    final sh = scheduleHistories?.isNotEmpty == true
        ? scheduleHistories![0]
        : null;
    final userName = sh?.user != null
        ? '${sh!.user!.firstName ?? ''} ${sh.user!.lastName ?? ''}'.trim()
        : 'customer'.tr;
    final date = sh?.createdAt != null
        ? DateConverter.dateMonthYearTime(
            DateConverter.isoUtcStringToLocalDate(sh!.createdAt!),
          )
        : '';

    return _timelineCard(
      context,
      primary: primary,
      title: 'booking_placed_by'.tr,
      nameValue: userName,
      dateValue: date,
      chipLabel: 'booked'.tr,
      chipColor: primary,
      icon: Icons.person_rounded,
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    Color primary,
    StatusHistories status,
    int idx,
  ) {
    final isAdmin = status.user?.userType == 'provider-admin';
    final userName = isAdmin
        ? Get.find<UserProfileController>()
                  .providerModel
                  ?.content
                  ?.providerInfo
                  ?.companyName ??
              ''
        : '${status.user?.firstName ?? ''} ${status.user?.lastName ?? ''}'
              .trim();
    final date = status.updatedAt != null
        ? DateConverter.dateMonthYearTime(
            DateConverter.isoUtcStringToLocalDate(status.updatedAt!),
          )
        : '';
    final chipColor = _statusColor(context, status.bookingStatus ?? '');

    return _timelineCard(
      context,
      primary: primary,
      title:
          '${'booking'.tr} ${status.bookingStatus?.tr.toLowerCase() ?? ''} ${'by'.tr} ${status.user?.userType?.tr ?? ''}',
      nameValue: userName,
      dateValue: date,
      chipLabel: status.bookingStatus?.tr ?? '',
      chipColor: chipColor,
      icon: Icons.person_pin_rounded,
    );
  }

  Widget _buildScheduleChangesCard(BuildContext context, Color primary) {
    final changes = scheduleHistories!.sublist(1);

    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 12, top: 4, right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: changes.map((history) {
          final isAdmin = history.user?.userType == 'provider-admin';
          final userName = isAdmin
              ? bookingDetails?.provider?.companyName ?? ''
              : '${history.user?.firstName ?? ''} ${history.user?.lastName ?? ''}'
                    .trim();
          final date = history.schedule != null
              ? DateConverter.dateMonthYearTime(
                  DateTime.tryParse(history.schedule!),
                )
              : '';

          return _timelineCard(
            context,
            primary: primary,
            title:
                '${'booking_schedule_changed_by'.tr} ${history.user?.userType?.tr ?? ''}',
            nameValue: userName,
            dateValue: date,
            chipLabel: 'rescheduled'.tr,
            chipColor: Colors.orange,
            icon: Icons.edit_calendar_rounded,
          );
        }).toList(),
      ),
    );
  }

  Widget _timelineCard(
    BuildContext context, {
    required Color primary,
    required String title,
    required String nameValue,
    required String dateValue,
    required String chipLabel,
    required Color chipColor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 14, top: 4, right: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header tint ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: chipColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: chipColor.withOpacity(0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      chipLabel,
                      style: robotoMedium.copyWith(
                        fontSize: 10,
                        color: chipColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nameValue.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          nameValue,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  if (nameValue.isNotEmpty) const SizedBox(height: 5),
                  if (dateValue.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateValue,
                          textDirection: TextDirection.ltr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'ongoing':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
