import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/caash_in_hand_widget.dart';
import 'package:afriendorse/athlete/feature/wallet/screen/wallet_screen.dart';

class AthleteWalletSpotlightCard extends StatelessWidget {
  final JustTheController? toolTip;

  const AthleteWalletSpotlightCard({super.key, this.toolTip});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userCtrl) {
        final account =
            userCtrl.providerModel?.content?.providerInfo?.owner?.account;

        final receivable =
            double.tryParse(account?.accountReceivable ?? '0') ?? 0;
        final payable = double.tryParse(account?.accountPayable ?? '0') ?? 0;
        final pending = double.tryParse(account?.balancePending ?? '0') ?? 0;
        final withdrawn = double.tryParse(account?.totalWithdrawn ?? '0') ?? 0;

        final transactionType = userCtrl.getTransactionType(
          payable,
          receivable,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AthleteSectionTitle(
              title: 'Wallet Spotlight',
              subtitle: 'Track your balance, pending payouts and withdrawals',
            ),
            GestureDetector(
              onTap: () => Get.to(() => const AthleteWalletScreen()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A7A31), Color(0xFF045F25)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AthleteDashboardColors.primary.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Balance',
                                style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                PriceConverter.convertPrice(
                                  receivable,
                                  isShowLongPrice: true,
                                ),
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _WalletChip(
                            title: 'Pending',
                            value: PriceConverter.convertPrice(
                              pending,
                              isShowLongPrice: true,
                            ),
                            color: AthleteDashboardColors.warning,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WalletChip(
                            title: 'Withdrawn',
                            value: PriceConverter.convertPrice(
                              withdrawn,
                              isShowLongPrice: true,
                            ),
                            color: AthleteDashboardColors.info,
                          ),
                        ),
                      ],
                    ),
                    if (transactionType == TransactionType.payable ||
                        transactionType ==
                            TransactionType.adjustAndPayable) ...[
                      const SizedBox(height: 14),
                      TotalCashInHandWidget(toolTip: toolTip),
                    ],
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Open Wallet',
                          style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WalletChip extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _WalletChip({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoRegular.copyWith(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
