import 'package:afriendorse/athlete/feature/dashboard/widgets/recent_activity_graph.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/recent_activity_list_view.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        return dashboardController.dashboardRecentActivityList.isEmpty &&
                dashboardController.dashboardCustomizedPostList.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault + 3,
                      vertical: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Images.dashboardProfile,
                          height: 15,
                          width: 15,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          "recent_booking_activities".tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () =>
                              dashboardController.changeRecentActivityView(),
                          child: Image.asset(
                            dashboardController.showRecentActivityList
                                ? Images.recentActivityGraph
                                : Images.recentActivityList,
                            width: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: context.customThemeColors.cardBottomShadow,
                    ),
                    child: dashboardController.showRecentActivityList
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeExtraSmall,
                                  vertical: Dimensions.paddingSizeSmall,
                                ),
                                child: TabBar(
                                  controller: dashboardController.tabController,
                                  unselectedLabelColor: Colors.grey,
                                  isScrollable: true,
                                  dividerColor: Colors.transparent,
                                  indicatorColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  labelColor: Theme.of(context).primaryColor,
                                  labelStyle: robotoMedium,
                                  indicatorWeight: 1,
                                  tabAlignment: TabAlignment.start,

                                  tabs: [
                                    SizedBox(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          "normal_booking".tr,
                                          style: robotoMedium,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          "customised_booking".tr,
                                          style: robotoMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onTap: (index) {
                                    if (dashboardController
                                            .tabController
                                            ?.index ==
                                        0) {
                                      dashboardController
                                          .changeTypeOfShowBookingStatus(
                                            status: true,
                                          );
                                    } else {
                                      dashboardController
                                          .changeTypeOfShowBookingStatus(
                                            status: false,
                                          );
                                    }
                                  },
                                ),
                              ),
                              const RecentActivityListView(),
                            ],
                          )
                        : const RecentActivityGraph(),
                  ),
                ],
              );
      },
    );
  }
}
