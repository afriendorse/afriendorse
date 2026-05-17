import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/referral/controller/athlete_referral_controller.dart';
import 'package:afriendorse/athlete/feature/referral/widget/athlete_withdraw_points_dialog.dart';

class AthletePointsBalanceCard extends StatelessWidget {
  const AthletePointsBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<AthleteReferralController>(
      init: Get.find<AthleteReferralController>(),
      builder: (controller) {
        final points = controller.rewardsSummary['totalPoints'] ?? 0;
        final cashEquivalent = controller.getCashEquivalent(points);
        final minWithdrawal = controller.getMinimumWithdrawalPoints();
        final canWithdraw = points >= minWithdrawal;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: primary.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.stars_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'points_balance'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'tap_to_convert'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${points.toInt()} pts',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'cash_value'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PriceConverter.convertPrice(cashEquivalent),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: canWithdraw
                        ? () => _showWithdrawDialog(context)
                        : null,
                    icon: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: canWithdraw ? Colors.white : Colors.grey,
                    ),
                    label: Text(
                      canWithdraw ? 'withdraw'.tr : 'locked'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: canWithdraw ? Colors.white : Colors.grey,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canWithdraw
                          ? primary
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),

              if (!canWithdraw) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'need_more_points'.trParams({
                            'needed': (minWithdrawal - points)
                                .toInt()
                                .toString(),
                            'min': minWithdrawal.toString(),
                          }),
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Colors.orange.shade800,
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
      },
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    Get.bottomSheet(
      const AthleteWithdrawPointsDialog(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }
}
