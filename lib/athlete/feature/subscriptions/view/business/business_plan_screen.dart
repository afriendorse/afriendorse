import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessPlanScreen extends StatefulWidget {
  const BusinessPlanScreen({super.key});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<BusinessSubscriptionController>().clearSearchController(
      shouldUpdate: false,
    );
    Get.find<BusinessSubscriptionController>().getSubscriptionPackageList(
      reload: true,
    );
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<BusinessSubscriptionController>().getSubscriptionTransactionList(
      1,
    );
    _loadTrialWidgetShow();
    _showToolTip();
  }

  Future<void> _loadTrialWidgetShow() async {
    await Get.find<UserProfileController>().trialWidgetShow(
      route: RouteHelper.businessPlan,
    );
  }

  _showToolTip() {
    int remainingDays = DateConverter.countDays(
      endDate: DateTime.tryParse(
        Get.find<UserProfileController>()
                .providerModel
                ?.content
                ?.subscriptionInfo
                ?.subscribedPackageDetails
                ?.packageEndDate ??
            "",
      ),
    );
    if ((Get.find<SplashController>()
                    .configModel
                    .content
                    ?.subscriptionDeadlineWarning ??
                0) >=
            remainingDays &&
        Get.find<UserProfileController>()
                .providerModel
                ?.content
                ?.subscriptionInfo
                ?.status ==
            "subscription_base") {
      Future.delayed(const Duration(seconds: 1), () {
        tooltipController.showTooltip();
      });
      Future.delayed(const Duration(seconds: 6), () {
        if (Get.currentRoute.contains(RouteHelper.businessPlan)) {
          tooltipController.hideTooltip();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Get.find<UserProfileController>().trialWidgetShow(route: '');
        return;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "business_plan".tr, elevation: 0),
        body: GetBuilder<UserProfileController>(
          builder: (userProfileController) {
            if (userProfileController
                    .providerModel
                    ?.content
                    ?.subscriptionInfo ==
                null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return userProfileController
                              .providerModel
                              ?.content
                              ?.subscriptionInfo !=
                          null &&
                      userProfileController
                              .providerModel
                              ?.content
                              ?.subscriptionInfo
                              ?.status ==
                          "commission_base" &&
                      userProfileController
                              .providerModel
                              ?.content
                              ?.subscriptionInfo
                              ?.totalSubscription ==
                          0
                  ? const CommissionInfoWidget()
                  : DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                            ),
                            child: TabBar(
                              unselectedLabelColor: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                              indicatorColor: Theme.of(context).primaryColor,
                              labelColor: Theme.of(context).primaryColorLight,
                              labelStyle: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                              labelPadding: EdgeInsets.zero,
                              dividerHeight: 0.2,
                              dividerColor: Theme.of(context).primaryColor,
                              tabs: [
                                SizedBox(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: Center(child: Text("plan_details".tr)),
                                ),
                                SizedBox(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: Center(child: Text("transaction".tr)),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: TabBarView(
                              children: [
                                userProfileController
                                            .providerModel
                                            ?.content
                                            ?.subscriptionInfo
                                            ?.status ==
                                        "commission_base"
                                    ? const CommissionInfoWidget()
                                    : BusinessPlanDetailsWidget(
                                        tooltipController: tooltipController,
                                      ),
                                const SubscriptionTransactionListScreen(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
            }
          },
        ),
      ),
    );
  }
}
