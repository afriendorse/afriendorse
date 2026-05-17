import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';

class AthleteOverviewStats extends StatelessWidget {
  const AthleteOverviewStats({super.key});

  WalletController _walletCtrl() {
    if (Get.isRegistered<WalletController>()) {
      return Get.find<WalletController>();
    }
    return Get.put(WalletController(), permanent: true);
  }

  AltCampaignController _campaignCtrl() {
    if (Get.isRegistered<AltCampaignController>(
      tag: AltCampaignController.tag,
    )) {
      return Get.find<AltCampaignController>(tag: AltCampaignController.tag);
    }
    return Get.put(
      AltCampaignController(),
      tag: AltCampaignController.tag,
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletCtrl = _walletCtrl();
    final campaignCtrl = _campaignCtrl();

    campaignCtrl.ensureMyCampaignsListening();

    return GetBuilder<UserProfileController>(
      builder: (_) {
        return GetBuilder<DashboardController>(
          builder: (dashboardController) {
            if (dashboardController.dashboardTopCards == null) {
              return const DashboardShimmer();
            }

            final bookingServed =
                dashboardController.dashboardTopCards?.totalBookingServed
                    ?.toString() ??
                '0';

            final subscribedServices =
                dashboardController.dashboardTopCards?.totalSubscribedServices
                    ?.toString() ??
                '0';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AthleteSectionTitle(
                  title: 'Overview',
                  subtitle: 'Quick snapshot of your performance',
                ),
                Row(
                  children: [
                    Expanded(
                      // CHANGED: use same "Total Earned" logic as wallet (merged + reactive)
                      child: Obx(
                        () => _LargeStatCard(
                          title: 'Total Earnings',
                          value: PriceConverter.convertPrice(
                            walletCtrl.mergedTotalEarned,
                            isShowLongPrice: true,
                          ),
                          icon: FontAwesomeIcons.arrowTrendUp,
                          gradient: const [
                            Color(0xFF0C8A38),
                            Color(0xFF045F25),
                          ],
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => _LargeStatCard(
                          title: 'Available Balance',
                          value: PriceConverter.convertPrice(
                            walletCtrl.mergedAvailableBalance,
                            isShowLongPrice: true,
                          ),
                          icon: FontAwesomeIcons.wallet,
                          gradient: const [
                            Color(0xFFF4F8F5),
                            Color(0xFFEAF7EF),
                          ],
                          textColor: AthleteDashboardColors.textPrimary,
                          borderColor: AthleteDashboardColors.border,
                          iconBgColor: AthleteDashboardColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        title: 'Completed Deals',
                        value: bookingServed,
                        icon: FontAwesomeIcons.handshake,
                        accent: AthleteDashboardColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        title: 'Services',
                        value: subscribedServices,
                        icon: FontAwesomeIcons.briefcase,
                        accent: AthleteDashboardColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final activeCount = campaignCtrl.myCampaigns
                            .where((c) => c.isActive)
                            .length;
                        return _MiniStatCard(
                          title: 'Campaigns',
                          value: '$activeCount',
                          icon: FontAwesomeIcons.bullhorn,
                          accent: AthleteDashboardColors.success,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LargeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final FaIconData icon;
  final List<Color> gradient;
  final Color textColor;
  final Color? borderColor;
  final Color? iconBgColor;

  const _LargeStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.textColor,
    this.borderColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(10),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconBgColor != null
                  ? iconBgColor!
                  : Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  color: textColor.withOpacity(0.72),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(color: textColor, fontSize: 17),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final FaIconData icon;
  final Color accent;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AthleteGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: SizedBox(
        height: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(child: FaIcon(icon, size: 14, color: accent)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: robotoBold.copyWith(
                    color: AthleteDashboardColors.textPrimary,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: robotoRegular.copyWith(
                    color: AthleteDashboardColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
