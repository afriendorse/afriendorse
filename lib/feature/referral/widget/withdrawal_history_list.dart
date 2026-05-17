// lib/feature/referral/widget/withdrawal_history_list.dart

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/referral/repository/points_withdrawal_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class WithdrawalHistoryList extends StatelessWidget {
  final List<PointsWithdrawal> withdrawals;

  const WithdrawalHistoryList({super.key, required this.withdrawals});

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Theme.of(context).hintColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'no_withdrawals_yet'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'withdrawals_appear_here'.tr,
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
      itemCount: withdrawals.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (context, index) {
        final withdrawal = withdrawals[index];
        return _WithdrawalHistoryItem(withdrawal: withdrawal);
      },
    );
  }
}

class _WithdrawalHistoryItem extends StatelessWidget {
  final PointsWithdrawal withdrawal;

  const _WithdrawalHistoryItem({required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final isCompleted = withdrawal.status == 'completed';
    final isPending = withdrawal.status == 'pending';
    final isApproved = withdrawal.status == 'approved';
    final isRejected = withdrawal.status == 'rejected';

    Color statusColor = Colors.grey;
    if (isCompleted) statusColor = Colors.green;
    if (isPending) statusColor = Colors.orange;
    if (isApproved) statusColor = Colors.blue;
    if (isRejected) statusColor = Colors.red;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal.cashAmount > 0
                          ? '\$${withdrawal.cashAmount.toStringAsFixed(2)}'
                          : '${withdrawal.pointsAmount.toInt()} pts',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      withdrawal.cashAmount > 0
                          ? '${withdrawal.pointsAmount.toInt()} pts → \$${withdrawal.cashAmount.toStringAsFixed(2)}'
                          : '${withdrawal.pointsAmount.toInt()} points',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  withdrawal.status.toUpperCase(),
                  style: robotoMedium.copyWith(
                    fontSize: 10,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (withdrawal.requestedAt != null) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  timeago.format(withdrawal.requestedAt!),
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ],

          // Transaction ID (for completed)
          if (isCompleted && withdrawal.transactionId != null) ...[
            const SizedBox(height: 4),
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
                    'TXN: ${withdrawal.transactionId}',
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

          // Rejection Reason
          if (isRejected && withdrawal.rejectionReason != null) ...[
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
                      withdrawal.rejectionReason!,
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
        ],
      ),
    );
  }
}
