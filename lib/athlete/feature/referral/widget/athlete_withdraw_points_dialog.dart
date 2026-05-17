import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/referral/controller/athlete_referral_controller.dart';

class AthleteWithdrawPointsDialog extends StatelessWidget {
  const AthleteWithdrawPointsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AthleteReferralController>(
      init: Get.find<AthleteReferralController>(),
      builder: (controller) {
        final availablePoints = controller.rewardsSummary['totalPoints'] ?? 0;
        final minPoints = controller.getMinimumWithdrawalPoints();
        final maxPoints = controller.getMaximumWithdrawalPoints();
        final conversionRate = controller.settings?.pointsConversionRate ?? 100;

        return Container(
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeLarge,
            right: Dimensions.paddingSizeLarge,
            top: Dimensions.paddingSizeLarge,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                Dimensions.paddingSizeLarge,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'convert_points_to_cash'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'available_balance'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              '${availablePoints.toInt()} points',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '≈ ${PriceConverter.convertPrice(controller.getCashEquivalent(availablePoints))}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'enter_points_to_withdraw'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.withdrawalAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'e.g. ${minPoints}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixText: 'pts',
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onChanged: (value) {
                    controller.update();
                  },
                ),
                const SizedBox(height: 12),

                if (controller.withdrawalAmountController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'you_will_receive'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          PriceConverter.convertPrice(
                            controller.getCashEquivalent(
                              double.tryParse(
                                    controller.withdrawalAmountController.text,
                                  ) ??
                                  0,
                            ),
                          ),
                          style: robotoBold.copyWith(
                            color: Colors.green,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickAmountButton(
                      context,
                      controller,
                      minPoints,
                      minPoints.toString(),
                    ),
                    _buildQuickAmountButton(
                      context,
                      controller,
                      minPoints * 2,
                      (minPoints * 2).toString(),
                    ),
                    _buildQuickAmountButton(
                      context,
                      controller,
                      minPoints * 5,
                      (minPoints * 5).toString(),
                    ),
                    if (availablePoints >= maxPoints)
                      _buildQuickAmountButton(
                        context,
                        controller,
                        maxPoints,
                        maxPoints.toString(),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'conversion_rate_info'.trParams({
                                'rate': conversionRate.toString(),
                              }),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'withdrawal_limits_info'.trParams({
                          'min': minPoints.toString(),
                          'max': maxPoints.toString(),
                        }),
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isProcessingWithdrawal
                        ? null
                        : () => controller.processWithdrawal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isProcessingWithdrawal
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'confirm_withdrawal'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: TextButton(
                    onPressed: () {
                      controller.withdrawalAmountController.clear();
                      Get.back();
                    },
                    child: Text(
                      'cancel'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountButton(
    BuildContext context,
    AthleteReferralController controller,
    int amount,
    String label,
  ) {
    return InkWell(
      onTap: () => controller.setWithdrawalAmount(amount.toString()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: controller.withdrawalAmountController.text == amount.toString()
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color:
                controller.withdrawalAmountController.text == amount.toString()
                ? Colors.white
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
