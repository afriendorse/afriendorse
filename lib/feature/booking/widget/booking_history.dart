import 'package:afriendorse/feature/booking/widget/booking_screen_shimmer.dart';
import 'package:afriendorse/feature/booking/widget/timeline/connector_theme.dart';
import 'package:afriendorse/feature/booking/widget/timeline/connectors.dart';
import 'package:afriendorse/feature/booking/widget/timeline/indicator_theme.dart';
import 'package:afriendorse/feature/booking/widget/timeline/indicators.dart';
import 'package:afriendorse/feature/booking/widget/timeline/timeline_theme.dart';
import 'package:afriendorse/feature/booking/widget/timeline/timeline_tile_builder.dart';
import 'package:afriendorse/feature/booking/widget/timeline/timelines.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class BookingHistory extends StatelessWidget {
  final String? id;
  final bool isSubBooking;
  const BookingHistory({super.key, this.id, required this.isSubBooking});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(
      () => BookingDetailsController(
        bookingDetailsRepo: BookingDetailsRepo(
          sharedPreferences: Get.find(),
          apiClient: Get.find(),
        ),
      ),
    );

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
      child: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          BookingDetailsContent? bookingDetails = isSubBooking
              ? bookingDetailsController.subBookingDetailsContent
              : bookingDetailsController.bookingDetailsContent;

          if (bookingDetails == null) {
            return const SingleChildScrollView(child: BookingScreenShimmer());
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                if (!ResponsiveHelper.isDesktop(context))
                  _buildHeaderCard(context, bookingDetails),

                _buildTimelineSection(context, bookingDetails),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Header Card ──────────────────────────────────────────────────────────

  Widget _buildHeaderCard(
    BuildContext context,
    BookingDetailsContent bookingDetails,
  ) {
    final createdAt = DateConverter.isoUtcStringToLocalDate(
      bookingDetails.createdAt?.toString() ?? '',
    );
    final scheduledDate = DateTime.tryParse(
      bookingDetails.serviceSchedule ?? '',
    );
    final isPaid = bookingDetails.isPaid != 0;
    final bookingStatus = bookingDetails.bookingStatus ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeExtraLarge,
        Dimensions.paddingSizeDefault,
        0,
      ),
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
        children: [
          // ── Top gradient banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'booking_summary'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Info rows ──
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: 'booking_place'.tr,
                  value: createdAt != null
                      ? DateConverter.dateMonthYearTimeTwentyFourFormat(
                          createdAt,
                        )
                      : '—',
                  valueDirection: TextDirection.ltr,
                ),
                _buildDivider(),
                _buildInfoRow(
                  context,
                  icon: Icons.event_available_rounded,
                  label: 'service_scheduled_date'.tr,
                  value: scheduledDate != null
                      ? DateConverter.dateMonthYearTimeTwentyFourFormat(
                          scheduledDate,
                        )
                      : 'not_set'.tr,
                  valueDirection: TextDirection.ltr,
                ),
                _buildDivider(),
                _buildInfoRow(
                  context,
                  icon: Icons.payment_rounded,
                  label: 'payment_status'.tr,
                  trailing: _buildBadge(
                    context,
                    label: isPaid ? 'paid'.tr : 'unpaid'.tr,
                    color: isPaid ? Colors.green : Colors.red,
                    icon: isPaid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                  ),
                ),
                _buildDivider(),
                _buildInfoRow(
                  context,
                  icon: Icons.info_outline_rounded,
                  label: 'booking_status'.tr,
                  trailing: _buildBadge(
                    context,
                    label: bookingStatus.tr,
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.circle,
                  ),
                ),
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
    String? value,
    Widget? trailing,
    TextDirection valueDirection = TextDirection.ltr,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
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
            child: Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          if (value != null)
            Flexible(
              child: Text(
                value,
                textDirection: valueDirection,
                textAlign: TextAlign.end,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));

  // ─── Timeline Section ─────────────────────────────────────────────────────

  Widget _buildTimelineSection(
    BuildContext context,
    BookingDetailsContent bookingDetails,
  ) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _buildSectionHeader(context, 'activity_timeline'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          HistoryStatus(
            bookingDetailsContent: bookingDetails,
            statusHistories: bookingDetails.statusHistories ?? [],
            scheduleHistories: bookingDetails.scheduleHistories ?? [],
            increment:
                (bookingDetails.scheduleHistories?.length ?? 0) > 1 &&
                    (bookingDetails.statusHistories?.isNotEmpty ?? false)
                ? 2
                : 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HistoryStatus — Pro Timeline
// ═══════════════════════════════════════════════════════════════════════════

class HistoryStatus extends StatelessWidget {
  final BookingDetailsContent? bookingDetailsContent;
  final List<StatusHistories> statusHistories;
  final List<ScheduleHistories> scheduleHistories;
  final int increment;

  const HistoryStatus({
    super.key,
    required this.bookingDetailsContent,
    required this.statusHistories,
    required this.scheduleHistories,
    required this.increment,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = statusHistories.length + increment;
    final primary = Theme.of(context).colorScheme.primary;

    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorTheme: const IndicatorThemeData(position: 0, size: 34.0),
        connectorTheme: ConnectorThemeData(
          thickness: 2.0,
          color: primary.withOpacity(0.25),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: Get.find<LocalizationController>().isLtr ? 0 : 10,
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: totalItems,
        contentsBuilder: (_, index) {
          if (index == 0) return _buildBookingPlacedTile(context);

          if (index == 1 && statusHistories.isNotEmpty) {
            return _buildStatusChangeTile(context, statusHistories[0]);
          }

          if (index == 2 && scheduleHistories.length > 1) {
            return _buildScheduleChangesTile(context);
          }

          final statusIndex = index - increment;
          if (statusIndex >= 0 && statusIndex < statusHistories.length) {
            return _buildStatusChangeTile(
              context,
              statusHistories[statusIndex],
            );
          }
          return const SizedBox();
        },
        connectorBuilder: (_, index, type) {
          final isFirst = index == 0;
          return SolidLineConnector(
            color: isFirst ? Colors.transparent : primary.withOpacity(0.3),
            thickness: 2,
          );
        },
        indicatorBuilder: (_, index) {
          return _buildIndicator(context, index);
        },
      ),
    );
  }

  // ─── Indicator ────────────────────────────────────────────────────────────

  Widget _buildIndicator(BuildContext context, int index) {
    final primary = Theme.of(context).colorScheme.primary;

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
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  // ─── Booking Placed ───────────────────────────────────────────────────────

  Widget _buildBookingPlacedTile(BuildContext context) {
    final firstSchedule = scheduleHistories.isNotEmpty
        ? scheduleHistories.first
        : null;
    final createdAt = firstSchedule?.createdAt != null
        ? DateConverter.isoUtcStringToLocalDate(firstSchedule!.createdAt!)
        : null;

    final customerName = bookingDetailsContent?.customer?.firstName ?? '';
    final customerLastName = bookingDetailsContent?.customer?.lastName ?? '';
    final contactName =
        bookingDetailsContent?.serviceAddress?.contactPersonName ?? '';
    final displayName = customerName.isNotEmpty
        ? '$customerName $customerLastName'
        : contactName;

    return _buildTimelineCard(
      context,
      title: 'service_booked_by_customer'.tr,
      subtitle: displayName.isNotEmpty ? displayName : null,
      dateString: createdAt != null
          ? DateConverter.dateMonthYearTimeTwentyFourFormat(createdAt)
          : null,
      chipLabel: 'booked'.tr,
      chipColor: Theme.of(context).colorScheme.primary,
      icon: Icons.person_rounded,
    );
  }

  // ─── Status Change ────────────────────────────────────────────────────────

  Widget _buildStatusChangeTile(BuildContext context, StatusHistories status) {
    final user = status.user;
    final isAdmin = user?.userType == 'provider-admin';
    final userName = isAdmin
        ? bookingDetailsContent?.provider?.companyName ?? ''
        : '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    final date = DateConverter.isoUtcStringToLocalDate(status.createdAt ?? '');
    final dateString = date != null
        ? DateConverter.dateMonthYearTimeTwentyFourFormat(date)
        : '';

    final statusLabel = status.bookingStatus?.tr.toLowerCase() ?? '';
    final userTypeLabel = user?.userType?.tr ?? '';

    final chipColor = _statusColor(context, status.bookingStatus ?? '');

    return _buildTimelineCard(
      context,
      title: '${'booking'.tr} $statusLabel ${'by'.tr} $userTypeLabel',
      subtitle: userName.isNotEmpty ? userName : null,
      dateString: dateString,
      chipLabel: status.bookingStatus?.tr ?? '',
      chipColor: chipColor,
      icon: Icons.person_pin_rounded,
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

  // ─── Schedule Changes ─────────────────────────────────────────────────────

  Widget _buildScheduleChangesTile(BuildContext context) {
    final changes = scheduleHistories.length > 1
        ? scheduleHistories.sublist(1)
        : <ScheduleHistories>[];

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        bottom: 12.0,
        top: 6,
        right: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: changes.map((history) {
          final user = history.user;
          final isAdmin = user?.userType == 'provider-admin';
          final userName = isAdmin
              ? bookingDetailsContent?.provider?.companyName ?? ''
              : '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

          final scheduleDate = DateTime.tryParse(history.schedule ?? '');
          final dateString = scheduleDate != null
              ? DateConverter.dateMonthYearTimeTwentyFourFormat(scheduleDate)
              : '';

          return _buildTimelineCard(
            context,
            title: '${'schedule_changed_by'.tr} ${user?.userType?.tr ?? ''}',
            subtitle: userName.isNotEmpty ? userName : null,
            dateString: dateString,
            chipLabel: 'rescheduled'.tr,
            chipColor: Colors.orange,
            icon: Icons.edit_calendar_rounded,
          );
        }).toList(),
      ),
    );
  }

  // ─── Shared Timeline Card ─────────────────────────────────────────────────

  Widget _buildTimelineCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? dateString,
    required String chipLabel,
    required Color chipColor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        bottom: 16.0,
        top: 4,
        right: 4,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
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
            // ── Card top bar ──
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
                  Icon(icon, size: 15, color: chipColor),
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
                  const SizedBox(width: 8),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipColor.withOpacity(0.35)),
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

            // ── Card body ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          subtitle,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (dateString != null && dateString.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateString,
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
}
