// lib/feature/referral/widget/referral_stats_card.dart

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/referral/controller/referral_controller.dart';

class ReferralStatsCard extends StatelessWidget {
  const ReferralStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(
      builder: (controller) {
        final stats = controller.getReferralStats();

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'your_stats'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Stats Row — 3 items in single row
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.people_outline_rounded,
                      label: 'total_referrals'.tr,
                      value: stats['totalReferrals'].toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  /*  Expanded(
                    child: _StatItem(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'successful'.tr,
                      value: stats['successfulReferrals'].toString(),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12), */
                  Expanded(
                    child: _StatItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'commission_earned'.tr,
                      value: PriceConverter.convertPrice(
                        stats['totalCommission']!,
                      ),
                      color: Colors.purple,
                      isAmount: true,
                    ),
                  ),
                ],
              ),

              // Pending Commission (if any)
              if (stats['pendingCommission']! > 0) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'pending_commission'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                      Text(
                        PriceConverter.convertPrice(
                          stats['pendingCommission']!,
                        ),
                        style: robotoBold.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isAmount;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
