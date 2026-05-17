// lib/feature/referral/widget/rewards_history_list.dart

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/referral/repository/referral_reward_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class RewardsHistoryList extends StatelessWidget {
  final List<ReferralReward> rewards;

  const RewardsHistoryList({super.key, required this.rewards});

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                size: 64,
                color: Theme.of(context).hintColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'no_rewards_yet'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'rewards_appear_here'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: rewards.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _RewardHistoryItem(reward: reward);
      },
    );
  }
}

class _RewardHistoryItem extends StatelessWidget {
  final ReferralReward reward;

  const _RewardHistoryItem({required this.reward});

  @override
  Widget build(BuildContext context) {
    final isCredited = reward.status == 'credited';
    final isPending = reward.status == 'pending';
    final isFailed = reward.status == 'failed';
    final isDeduction = reward.rewardType == 'points_deduction';

    Color statusColor = Colors.grey;
    if (isCredited) statusColor = Colors.green;
    if (isPending) statusColor = Colors.orange;
    if (isFailed) statusColor = Colors.red;
    if (isDeduction) statusColor = Colors.red; // override green for deductions

    final isCommission = reward.rewardType == 'brand_commission';
    final isRefereeWelcome = reward.rewardType == 'referee_welcome_points';

    final displayValue = isCommission
        ? PriceConverter.convertPrice(reward.amount)
        : isDeduction
        ? '-${reward.points.abs().toInt()} pts'
        : '+${reward.points.toInt()} pts';

    // Determine title and icon
    String rewardTitle;
    IconData rewardIcon;

    if (isCommission) {
      rewardTitle = 'brand_commission'.tr;
      rewardIcon = Icons.account_balance_wallet_rounded;
    } else if (isRefereeWelcome) {
      rewardTitle = 'welcome_bonus'.tr;
      rewardIcon = Icons.card_giftcard_rounded;
    } else if (isDeduction) {
      rewardTitle = 'points_withdrawn'.tr;
      rewardIcon = Icons.remove_circle_outline_rounded;
    } else {
      rewardTitle = 'referral_points'.tr;
      rewardIcon = Icons.stars_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(rewardIcon, color: statusColor, size: 20),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rewardTitle,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (reward.createdAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(reward.createdAt!),
                            style: robotoRegular.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Amount/Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayValue,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDeduction ? 'WITHDRAWN' : reward.status.toUpperCase(),
                      style: robotoMedium.copyWith(
                        fontSize: 9,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Failure Reason
          if (isFailed && reward.failureReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reward.failureReason!,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Booking ID (for commissions)
          if (isCommission && reward.bookingId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Booking: ${reward.bookingId}',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Theme.of(context).hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
