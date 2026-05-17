// lib/feature/referral/view/referral_screen.dart
// COMPLETE FILE - REPLACE EVERYTHING

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/referral/controller/referral_controller.dart';
import 'package:afriendorse/feature/referral/widget/referral_code_card.dart';
import 'package:afriendorse/feature/referral/widget/referral_stats_card.dart';
import 'package:afriendorse/feature/referral/widget/referral_history_list.dart';
import 'package:afriendorse/feature/referral/widget/rewards_history_list.dart';
import 'package:afriendorse/feature/referral/widget/points_balance_card.dart';
import 'package:afriendorse/feature/referral/widget/withdrawal_history_list.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // 🆕 Changed from 2 to 3

    // Load referral data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ReferralController>().loadUserReferralData();
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
      drawer: ResponsiveHelper.isDesktop(context)
          ? const AddressSelectionDrawer()
          : null,
      endDrawer: ResponsiveHelper.isDesktop(context)
          ? const MenuDrawer()
          : null,
      appBar: CustomAppBar(
        title: 'referral_program'.tr,
        actionWidget: IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          onPressed: () => _showInfoDialog(context),
        ),
      ),
      body: GetBuilder<ReferralController>(
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
                  // Referral Code Card
                  const ReferralCodeCard(),

                  // 🆕 Points Balance Card (NEW)
                  // WITH — brands never need points balance:
                  if (!controller.isBrand &&
                      controller.isWithdrawalEnabled()) ...[
                    const PointsBalanceCard(),
                  ],

                  // Stats Cards
                  const ReferralStatsCard(),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Tabs for History
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
                        // WITH — brands get 2 tabs (no withdrawals), fans/athletes get 3:
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
                            if (!controller.isBrand)
                              Tab(text: 'rewards_history'.tr),
                            if (!controller.isBrand)
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
                              if (!controller.isBrand)
                                RewardsHistoryList(
                                  rewards: controller.rewardsList,
                                ),
                              if (!controller.isBrand)
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
        content: GetBuilder<ReferralController>(
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
                // REPLACE the Column children inside the GetBuilder in _showInfoDialog:
                children: [
                  if (!controller.isBrand) ...[
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
                  ],
                  _buildInfoItem(
                    context,
                    Icons.business_center_outlined,
                    'refer_brands'.tr,
                    'earn_commission_for_brands'.trParams({
                      'percentage': commissionPercent.toString(),
                      'type': isRecurring ? 'every deal' : 'first deal',
                    }),
                  ),
                  if (!controller.isBrand) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    _buildInfoItem(
                      context,
                      Icons.account_balance_wallet_rounded,
                      'convert_points'.tr,
                      'points_to_cash_info'.trParams({
                        'rate': conversionRate.toString(),
                      }),
                    ),
                  ],
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
