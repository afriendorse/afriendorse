import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaigns_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/create_campaign_flow.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:intl/intl.dart';

class AthleteCampaignSection extends StatelessWidget {
  final AltCampaignController? campaignCtrl;
  const AthleteCampaignSection({super.key, required this.campaignCtrl});

  AltCampaignController _resolveCtrl() {
    if (campaignCtrl != null) return campaignCtrl!;

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
    final ctrl = _resolveCtrl();

    // Safe to call many times (guarded + retries inside)
    ctrl.ensureMyCampaignsListening();

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 380;
    final statWidth = isSmallPhone
        ? (screenWidth - 32 - 10) / 2
        : (screenWidth - 32 - 20) / 3;

    return Obx(() {
      // Show ACTIVE campaigns only
      final activeCampaigns = ctrl.myCampaigns
          .where((c) => c.isActive)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AthleteSectionTitle(
            title: 'Campaigns',
            subtitle: 'Manage active campaigns and community support',
            trailing: GestureDetector(
              onTap: () => Get.to(() => const CampaignsScreen()),
              child: Text(
                'See all',
                style: robotoMedium.copyWith(
                  color: AthleteDashboardColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          if (activeCampaigns.isEmpty)
            GestureDetector(
              onTap: () => showCreateCampaignFlow(context),
              child: AthleteGlassCard(
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AthleteDashboardColors.softBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: AthleteDashboardColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Launch a Campaign',
                            style: robotoBold.copyWith(
                              color: AthleteDashboardColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Raise support from fans, sponsors and the wider community.',
                            style: robotoRegular.copyWith(
                              color: AthleteDashboardColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AthleteDashboardColors.textSecondary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: isSmallPhone ? 198 : 194,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeCampaigns.length + 1,
                itemBuilder: (_, i) {
                  if (i == activeCampaigns.length) {
                    return GestureDetector(
                      onTap: () => showCreateCampaignFlow(context),
                      child: Container(
                        width: isSmallPhone ? 100 : 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AthleteDashboardColors.border,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AthleteDashboardColors.softBg,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AthleteDashboardColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'New\nCampaign',
                              textAlign: TextAlign.center,
                              style: robotoMedium.copyWith(
                                color: AthleteDashboardColors.primary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final c = activeCampaigns[i];
                  return GestureDetector(
                    onTap: () {
                      ctrl.selectCampaign(c);
                      Get.to(() => CampaignDetailScreen(campaign: c));
                    },
                    child: _CampaignCard(
                      campaign: c,
                      isSmallPhone: isSmallPhone,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: statWidth,
                  child: _CampaignAggStat(
                    label: 'Raised',
                    value:
                        '${Currency.symbol}${_fmtLarge(activeCampaigns.fold<double>(0, (s, c) => s + c.raisedAmount))}',
                    icon: Icons.trending_up_rounded,
                    color: AthleteDashboardColors.success,
                  ),
                ),
                SizedBox(
                  width: statWidth,
                  child: _CampaignAggStat(
                    label: 'Supporters',
                    value:
                        '${activeCampaigns.fold<int>(0, (s, c) => s + c.donorCount)}',
                    icon: Icons.favorite_outline,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(
                  width: statWidth,
                  child: _CampaignAggStat(
                    label: 'Goals Hit',
                    value:
                        '${activeCampaigns.where((c) => c.isGoalReached).length}',
                    icon: Icons.flag_outlined,
                    color: AthleteDashboardColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  String _fmtLarge(double v) {
    final formatter = NumberFormat('#,##0.##');
    if (v >= 1000000) return '${formatter.format(v / 1000000)}M';
    if (v >= 1000) return '${formatter.format(v / 1000)}K';
    return formatter.format(v);
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final bool isSmallPhone;

  const _CampaignCard({required this.campaign, required this.isSmallPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSmallPhone ? 168 : 164,
      margin: const EdgeInsets.only(right: 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child:
                campaign.coverImage != null && campaign.coverImage!.isNotEmpty
                ? Image.network(
                    campaign.coverImage!,
                    height: 78,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const _CampaignCoverFallback(),
                  )
                : const _CampaignCoverFallback(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 54,
                  child: Text(
                    campaign.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      color: AthleteDashboardColors.textPrimary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: campaign.progressPercent,
                    minHeight: 5,
                    backgroundColor: AthleteDashboardColors.softBg,
                    valueColor: const AlwaysStoppedAnimation(
                      AthleteDashboardColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Currency.symbol}${_fmt(campaign.raisedAmount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        color: AthleteDashboardColors.success,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(campaign.progressPercent * 100).toStringAsFixed(0)}%',
                      style: robotoRegular.copyWith(
                        color: AthleteDashboardColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _CampaignCoverFallback extends StatelessWidget {
  const _CampaignCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A7A31), Color(0xFF045F25)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.campaign_outlined, color: Colors.white54, size: 24),
      ),
    );
  }
}

class _CampaignAggStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CampaignAggStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AthleteGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: SizedBox(
        height: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 16, color: color),
            Text(
              value,
              style: robotoBold.copyWith(color: color, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                color: AthleteDashboardColors.textSecondary,
                fontSize: 9.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
