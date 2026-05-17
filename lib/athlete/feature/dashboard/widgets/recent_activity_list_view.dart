import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/custom_post/model/post_model.dart';

class RecentActivityListView extends StatelessWidget {
  const RecentActivityListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        // ── Standard/Normal booking tab (commented out) ──────────────────────
        // Restore this block AND update TabController length to 3 in
        // DashboardController.onInit() when re-enabling cart-based bookings.
        //
        // if (dashboardController.showNormalBooking) {
        //   return _buildNormalBookings(context, dashboardController);
        // }
        // ────────────────────────────────────────────────────────────────────

        // Route between targeted and open based on active tab index
        return dashboardController.activeTabIndex == 0
            ? _buildTargetedBookings(context, dashboardController)
            : _buildOpenBookings(context, dashboardController);
      },
    );
  }

  // ── Normal bookings (commented out — restore when needed) ─────────────────
  // Widget _buildNormalBookings(
  //   BuildContext context,
  //   DashboardController dashboardController,
  // ) {
  //   if (dashboardController.dashboardRecentActivityList.isEmpty) {
  //     return const Padding(
  //       padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
  //       child: NoDataScreen(
  //         text: "you_have_no_normal_request",
  //         type: NoDataType.none,
  //       ),
  //     );
  //   }
  //   return ListView.separated(
  //     itemCount: dashboardController.dashboardRecentActivityList.length,
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: const EdgeInsets.only(bottom: 8),
  //     separatorBuilder: (_, __) => Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Divider(height: 1, thickness: 1, color: AthleteDashboardColors.border),
  //     ),
  //     itemBuilder: (context, index) {
  //       final item = dashboardController.dashboardRecentActivityList[index];
  //       return Stack(
  //         children: [
  //           RecentActivityCardItem(dashboardRecentActivityModel: item),
  //           Positioned.fill(
  //             child: CustomInkWell(
  //               radius: 18,
  //               onTap: () {
  //                 if (item.isRepeatBooking == 1) {
  //                   Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(bookingId: item.id));
  //                 } else {
  //                   Get.toNamed(RouteHelper.getBookingDetailsRoute(bookingId: item.id));
  //                 }
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // ──────────────────────────────────────────────────────────────────────────

  // ── Tab 0: Targeted requests ───────────────────────────────────────────────
  Widget _buildTargetedBookings(
    BuildContext context,
    DashboardController dashboardController,
  ) {
    if (dashboardController.dashboardTargetedPostList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: NoDataScreen(
          text: "no_targeted_requests",
          type: NoDataType.none,
        ),
      );
    }
    return _buildPostList(dashboardController.dashboardTargetedPostList);
  }

  // ── Tab 1: Open requests ───────────────────────────────────────────────────
  Widget _buildOpenBookings(
    BuildContext context,
    DashboardController dashboardController,
  ) {
    if (dashboardController.dashboardOpenPostList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: NoDataScreen(
          text: "you_have_no_customizes_request",
          type: NoDataType.none,
        ),
      );
    }
    return _buildPostList(dashboardController.dashboardOpenPostList);
  }

  // ── Shared card list — used by both targeted and open tabs ─────────────────
  Widget _buildPostList(List<PostData> list) {
    return ListView.separated(
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 8),
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AthleteDashboardColors.border,
        ),
      ),
      itemBuilder: (context, index) {
        final item = list[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AthleteDashboardColors.cardBg2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AthleteDashboardColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomImage(
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  image: item.service?.thumbnailFullPath ?? "",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.service?.name ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: AthleteDashboardColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subCategory?.name ?? "",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: AthleteDashboardColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateConverter.dateMonthYearTime(
                        DateConverter.isoUtcStringToLocalDate(
                          "${item.createdAt}",
                        ),
                      ),
                      textDirection: TextDirection.ltr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: AthleteDashboardColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        Get.find<BusinessSubscriptionController>()
                            .openTrialEndBottomSheet()
                            .then((isTrial) async {
                              if (isTrial) {
                                if (Get.find<UserProfileController>()
                                    .checkAvailableFeatureInSubscriptionPlan(
                                      featureType: 'bidding',
                                    )) {
                                  await Get.to(
                                    () => CustomerPostDetailsScreen(
                                      postData: item,
                                      fromNotification: true,
                                      fromDashboard: true,
                                    ),
                                  );
                                }
                              }
                            });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AthleteDashboardColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'place_offer'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
