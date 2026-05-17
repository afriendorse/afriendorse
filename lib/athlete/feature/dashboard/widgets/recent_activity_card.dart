import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RecentActivityCardItem extends StatelessWidget {
  final DashboardRecentActivityModel dashboardRecentActivityModel;

  const RecentActivityCardItem({
    super.key,
    required this.dashboardRecentActivityModel,
  });

  @override
  Widget build(BuildContext context) {
    final detail =
        (dashboardRecentActivityModel.detail != null &&
            dashboardRecentActivityModel.detail!.isNotEmpty)
        ? dashboardRecentActivityModel.detail!.first
        : null;

    final serviceImage = detail?.service?.thumbnailFullPath ?? '';
    final serviceName = detail?.service?.name ?? '';
    final bookingStatus = dashboardRecentActivityModel.bookingStatus ?? '';
    final readableId =
        dashboardRecentActivityModel.readableId?.toString() ?? '';
    final createdAt = dashboardRecentActivityModel.createdAt ?? '';

    final statusBgColor = Get.isDarkMode
        ? Colors.grey.withOpacity(0.2)
        : context.customThemeColors.buttonBackgroundColorMap[bookingStatus] ??
              AthleteDashboardColors.softBg;

    final statusTextColor = Get.isDarkMode
        ? Theme.of(context).primaryColorLight
        : context.customThemeColors.buttonTextColorMap[bookingStatus] ??
              AthleteDashboardColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AthleteDashboardColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomImage(
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              image: serviceImage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            "${'booking'.tr} #$readableId",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AthleteDashboardColors.textPrimary,
                            ),
                          ),
                          if (dashboardRecentActivityModel.isRepeatBooking == 1)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AthleteDashboardColors.success,
                              ),
                              child: const Icon(
                                Icons.repeat,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (serviceName.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: AthleteDashboardColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: AthleteDashboardColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        createdAt.isNotEmpty
                            ? DateConverter.dateMonthYearTime(
                                DateConverter.isoUtcStringToLocalDate(
                                  createdAt,
                                ),
                              )
                            : '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: AthleteDashboardColors.textSecondary,
                        ),
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: statusBgColor,
                ),
                child: Text(
                  bookingStatus.tr,
                  style: robotoMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: Dimensions.fontSizeSmall,
                    color: statusTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: AthleteDashboardColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
