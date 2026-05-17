import 'package:afriendorse/athlete/feature/profile/view/view/athlete_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/wallet/screen/wallet_screen.dart';

class AthleteQuickActionsSection extends StatelessWidget {
  const AthleteQuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userCtrl) {
        final account =
            userCtrl.providerModel?.content?.providerInfo?.owner?.account;
        final receivable =
            double.tryParse(account?.accountReceivable ?? '0') ?? 0;

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallPhone = screenWidth < 380;

        final actions = <_QuickActionItem>[
          _QuickActionItem(
            icon: Icons.verified_rounded,
            title: 'Become Verified',
            subtitle: 'Upload ID • Get Badge • Build Trust',
            color: const Color.fromARGB(255, 35, 138, 68),
            onTap: () => Get.to(() => const AthleteVerificationScreen()),
          ),
          _QuickActionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Withdraw Earnings',
            subtitle: receivable > 0
                ? 'You have funds available'
                : 'Review wallet balance',
            color: AthleteDashboardColors.success,
            onTap: () => Get.to(() => const AthleteWalletScreen()),
          ),
          _QuickActionItem(
            icon: Icons.settings_outlined,
            title: 'Athlete Bio Settings',
            subtitle: 'Manage your bio and business settings',
            color: AthleteDashboardColors.warning,
            onTap: () => Get.to(() => const BusinessSettingScreen()),
          ),
          _QuickActionItem(
            icon: Icons.groups_outlined,
            title: 'Groups & Clubs',
            subtitle: 'Connect with your community',
            color: Colors.purple,
            onTap: () => Get.toNamed(RouteHelper.groups),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AthleteSectionTitle(
              title: 'Quick Actions',
              subtitle: 'Jump into your most important next steps',
            ),
            GridView.builder(
              itemCount: actions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isSmallPhone ? 1.12 : 1.35,
              ),
              itemBuilder: (_, index) {
                return _QuickActionCard(item: actions[index]);
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionItem item;

  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AthleteDashboardColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: robotoBold.copyWith(
                color: AthleteDashboardColors.textPrimary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  item.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    color: AthleteDashboardColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
