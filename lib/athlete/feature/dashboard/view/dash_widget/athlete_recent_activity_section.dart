import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/recent_activity_graph.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/recent_activity_list_view.dart';

class AthleteRecentActivitySection extends StatelessWidget {
  const AthleteRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return dashboardController.dashboardRecentActivityList.isEmpty &&
                dashboardController.dashboardTargetedPostList.isEmpty &&
                dashboardController.dashboardOpenPostList.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AthleteSectionTitle(
                    title: 'Recent Activity',
                    subtitle:
                        'Latest bookings, requests and performance updates',
                    trailing: InkWell(
                      onTap: () =>
                          dashboardController.changeRecentActivityView(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AthleteDashboardColors.border,
                          ),
                        ),
                        child: FaIcon(
                          dashboardController.showRecentActivityList
                              ? FontAwesomeIcons.chartBar
                              : FontAwesomeIcons.list,
                          color: AthleteDashboardColors.textPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  AthleteGlassCard(
                    padding: EdgeInsets.zero,
                    child: dashboardController.showRecentActivityList
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  10,
                                  6,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AthleteDashboardColors.cardBg2,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AthleteDashboardColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: TabBar(
                                    controller:
                                        dashboardController.tabController,
                                    unselectedLabelColor: Colors.black87,
                                    isScrollable: false,
                                    dividerColor: Colors.transparent,
                                    splashFactory: InkRipple.splashFactory,
                                    overlayColor: WidgetStateProperty.all(
                                      AthleteDashboardColors.primary
                                          .withOpacity(0.08),
                                    ),
                                    indicator: BoxDecoration(
                                      color: AthleteDashboardColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AthleteDashboardColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    labelColor: Colors.white,
                                    labelStyle: robotoMedium,
                                    tabAlignment: TabAlignment.fill,
                                    tabs: [
                                      // ── Standard/Normal booking tab ──────────────────
                                      // Commented out — restore this AND change
                                      // TabController length back to 3 in DashboardController.onInit()
                                      // to re-enable the cart-based booking tab.
                                      // _TabItem(label: "normal_booking".tr),

                                      // Tab 0: Targeted requests
                                      // (brand booked this athlete specifically)
                                      _TabItem(label: "targeted_requests".tr),

                                      // Tab 1: Open requests
                                      // (brand posted for all athletes to bid on)
                                      _TabItem(label: "open_requests".tr),
                                    ],
                                    onTap: (index) {
                                      // ── Normal booking tap (commented out) ──
                                      // if (index == 0) {
                                      //   dashboardController
                                      //     .changeTypeOfShowBookingStatus(status: true);
                                      // }
                                      dashboardController.setActiveTab(index);
                                    },
                                  ),
                                ),
                              ),
                              const RecentActivityListView(),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: RecentActivityGraph(),
                          ),
                  ),
                ],
              );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  const _TabItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 34,
      child: Center(
        child: Text(
          label,
          style: robotoMedium.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
