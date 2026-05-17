import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/referral/controller/athlete_referral_controller.dart';
import 'package:afriendorse/athlete/feature/referral/widget/athlete_referral_code_card.dart';
import 'package:afriendorse/athlete/feature/referral/widget/athlete_referral_stats_card.dart';
import 'package:afriendorse/athlete/feature/referral/widget/athlete_points_balance_card.dart';
import 'package:afriendorse/feature/referral/widget/referral_history_list.dart';
import 'package:afriendorse/feature/referral/widget/rewards_history_list.dart';
import 'package:afriendorse/feature/referral/widget/withdrawal_history_list.dart';

class AthleteReferralScreen extends StatefulWidget {
  const AthleteReferralScreen({super.key});

  @override
  State<AthleteReferralScreen> createState() => _AthleteReferralScreenState();
}

class _AthleteReferralScreenState extends State<AthleteReferralScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AthleteReferralController _controller; // 🆕 Store controller reference

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 🆕 Initialize controller BEFORE any widget builds
    if (!Get.isRegistered<AthleteReferralController>()) {
      _controller = Get.put(AthleteReferralController());
    } else {
      _controller = Get.find<AthleteReferralController>();
    }

    // Load data after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadUserReferralData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'referral_program'.tr,
        actionWidget: IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          onPressed: () => _showInfoDialog(context),
        ),
      ),
      body: GetBuilder<AthleteReferralController>(
        init: _controller, // 🆕 Provide the controller to GetBuilder
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const AthleteReferralCodeCard(),

                  if (controller.isWithdrawalEnabled()) ...[
                    const AthletePointsBalanceCard(),
                  ],

                  const AthleteReferralStatsCard(),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).hintColor,
                          indicatorColor: Theme.of(context).primaryColor,
                          labelStyle: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          tabs: [
                            Tab(text: 'my_referrals'.tr),
                            Tab(text: 'rewards_history'.tr),
                            Tab(text: 'withdrawals'.tr),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ReferralHistoryList(
                                referrals: controller.referralsList,
                              ),
                              RewardsHistoryList(
                                rewards: controller.rewardsList,
                              ),
                              WithdrawalHistoryList(
                                withdrawals: controller.withdrawalList,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        title: Row(
          children: [
            Icon(
              Icons.card_giftcard_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text('how_it_works'.tr, style: robotoBold),
          ],
        ),
        content: GetBuilder<AthleteReferralController>(
          init: _controller, // 🆕 Provide controller to dialog's GetBuilder too
          builder: (controller) {
            final pointsPerReferral = controller.getPointsPerReferral();
            final pointsPerReferee = controller.getPointsPerReferee();
            final commissionPercent = controller.getCommissionPercentage();
            final isRecurring = controller.isCommissionRecurring();
            final conversionRate =
                controller.settings?.pointsConversionRate ?? 100;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoItem(
                    context,
                    Icons.people_outline_rounded,
                    'refer_users'.tr,
                    'you_earn_points_they_earn'.trParams({
                      'referrerPoints': pointsPerReferral.toString(),
                      'refereePoints': pointsPerReferee.toString(),
                    }),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildInfoItem(
                    context,
                    Icons.business_center_outlined,
                    'refer_brands'.tr,
                    'earn_commission_for_brands'.trParams({
                      'percentage': commissionPercent.toString(),
                      'type': isRecurring ? 'every deal' : 'first deal',
                    }),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildInfoItem(
                    context,
                    Icons.account_balance_wallet_rounded,
                    'convert_points'.tr,
                    'points_to_cash_info'.trParams({
                      'rate': conversionRate.toString(),
                    }),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildInfoItem(
                    context,
                    Icons.share_outlined,
                    'share_code'.tr,
                    'share_your_code_easily'.tr,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('got_it'.tr)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: robotoBold),
              const SizedBox(height: 4),
              Text(
                description,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
