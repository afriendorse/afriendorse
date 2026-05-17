// lib/athlete/feature/campaigns/widgets/group_campaigns_section.dart
//
// FIX: All Get.put(AltCampaignController()) / Get.find<AltCampaignController>()
// calls now use tag: AltCampaignController.tag so the athlete-side controller
// never collides with the brand/fan AltCampaignController registered under the
// same bare type name by GetX.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_firestore_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/create_campaign_flow.dart';
import 'package:afriendorse/athlete/feature/campaigns/widgets/campaign_widgets.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/shared/currency_helper.dart';

class GroupCampaignsSection extends StatefulWidget {
  final GroupModel group;
  final String currentUserId;

  const GroupCampaignsSection({
    Key? key,
    required this.group,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<GroupCampaignsSection> createState() => _GroupCampaignsSectionState();
}

class _GroupCampaignsSectionState extends State<GroupCampaignsSection> {
  final RxList<CampaignModel> _campaigns = <CampaignModel>[].obs;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.group.creatorId == widget.currentUserId;

    CampaignFirestoreService.streamGroupCampaigns(
      widget.group.id,
    ).listen((list) => _campaigns.value = list);
  }

  // ── Safe controller lookup — always uses the athlete tag ─────────────────
  AltCampaignController get _ctrl {
    try {
      return Get.find<AltCampaignController>(tag: AltCampaignController.tag);
    } catch (_) {
      return Get.put(AltCampaignController(), tag: AltCampaignController.tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final campaigns = _campaigns;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────
              Row(
                children: [
                  const Text(
                    '🚀 Group Campaigns',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const Spacer(),
                  if (_isAdmin)
                    GestureDetector(
                      onTap: () => _openCreateGroupCampaign(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF045F25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Create',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              if (!_isAdmin && campaigns.isEmpty)
                _EmptyState(isAdmin: false, groupName: widget.group.name)
              else if (_isAdmin && campaigns.isEmpty)
                _EmptyState(
                  isAdmin: true,
                  groupName: widget.group.name,
                  onCreate: () => _openCreateGroupCampaign(context),
                )
              else ...[
                _GroupCampaignStats(campaigns: campaigns),
                const SizedBox(height: 14),
                ...campaigns.map(
                  (c) => CampaignCard(
                    campaign: c,
                    onTap: () {
                      // ── FIX: tag added here (was the crash site line 132) ─
                      _ctrl.selectCampaign(c);
                      Get.to(() => CampaignDetailScreen(campaign: c));
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _openCreateGroupCampaign(BuildContext context) {
    // ── FIX: tag added here too ───────────────────────────────────────────
    final ctrl = _ctrl;
    ctrl.campaignType.value = CampaignType.group;
    ctrl.selectedGroupId.value = widget.group.id;
    ctrl.selectedGroupName.value = widget.group.name;

    showCreateCampaignFlow(context);
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _GroupCampaignStats extends StatelessWidget {
  final List<CampaignModel> campaigns;
  const _GroupCampaignStats({required this.campaigns});

  @override
  Widget build(BuildContext context) {
    final totalRaised = campaigns.fold<double>(0, (s, c) => s + c.raisedAmount);
    final totalDonors = campaigns.fold<int>(0, (s, c) => s + c.donorCount);
    final goalsHit = campaigns.where((c) => c.isGoalReached).length;
    final active = campaigns.where((c) => c.isActive && !c.isExpired).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF056B2A), Color(0xFF033D18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(
            label: 'Total Raised',
            value: '${Currency.symbol}${_fmt(totalRaised)}',
            icon: Icons.trending_up,
          ),
          _Divider(),
          _StatCell(
            label: 'Donors',
            value: '$totalDonors',
            icon: Icons.favorite,
          ),
          _Divider(),
          _StatCell(label: 'Active', value: '$active', icon: Icons.campaign),
          _Divider(),
          _StatCell(
            label: 'Goals Hit',
            value: '$goalsHit 🏆',
            icon: Icons.flag,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.15),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isAdmin;
  final String groupName;
  final VoidCallback? onCreate;
  const _EmptyState({
    required this.isAdmin,
    required this.groupName,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text('🚀', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            isAdmin
                ? 'Launch a campaign for $groupName'
                : 'No campaigns yet for $groupName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Create a fundraising campaign your members can support'
                : 'The group admin hasn\'t created any campaigns yet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          if (isAdmin && onCreate != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create Campaign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF045F25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
