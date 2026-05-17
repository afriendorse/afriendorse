// lib/athlete/feature/campaigns/screens/campaigns_screen.dart
//
// FIX: Get.put(AltCampaignController()) in initState now uses
// tag: AltCampaignController.tag — prevents collision with the brand/fan
// AltCampaignController registered under the same bare type key.

import 'package:afriendorse/athlete/feature/campaigns/service/campaign_deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/create_campaign_flow.dart';
import 'package:afriendorse/athlete/feature/campaigns/widgets/campaign_widgets.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:intl/intl.dart';

enum _CampaignFilter { all, individual, group, nearGoal }

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({Key? key}) : super(key: key);

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen>
    with SingleTickerProviderStateMixin {
  late AltCampaignController _ctrl;
  _CampaignFilter _filter = _CampaignFilter.all;
  late AnimationController _bannerAnim;
  late Animation<double> _bannerFade;

  @override
  void initState() {
    super.initState();

    // ── FIX: always use the athlete tag ──────────────────────────────────
    try {
      _ctrl = Get.find<AltCampaignController>(tag: AltCampaignController.tag);
    } catch (_) {
      _ctrl = Get.put(AltCampaignController(), tag: AltCampaignController.tag);
    }

    _ctrl.listenToMyCampaigns(_ctrl.currentUserId);

    _bannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bannerFade = CurvedAnimation(parent: _bannerAnim, curve: Curves.easeOut);
    _bannerAnim.forward();
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    super.dispose();
  }

  List<CampaignModel> get _filtered {
    final all = _ctrl.activeCampaigns;
    switch (_filter) {
      case _CampaignFilter.individual:
        return all.where((c) => c.type == CampaignType.individual).toList();
      case _CampaignFilter.group:
        return all.where((c) => c.type == CampaignType.group).toList();
      case _CampaignFilter.nearGoal:
        return all.where((c) => c.progressPercent >= 0.75).toList();
      case _CampaignFilter.all:
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _bannerFade,
              child: Column(
                children: [
                  _buildHeroBanner(context),
                  _buildMyCampaignsStrip(context),
                  _buildFilterBar(),
                ],
              ),
            ),
          ),
          _buildCampaignList(),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: _ctrl.canCreateCampaign
          ? FloatingActionButton.extended(
              onPressed: () => showCreateCampaignFlow(context),
              backgroundColor: const Color(0xFF045F25),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.campaign),
              label: const Text(
                'New Campaign',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF045F25),
      title: const Text(
        'Campaigns',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Obx(() {
      final total = _ctrl.activeCampaigns.length;
      final totalRaised = _ctrl.activeCampaigns.fold<double>(
        0,
        (s, c) => s + c.raisedAmount,
      );
      final totalDonors = _ctrl.activeCampaigns.fold<int>(
        0,
        (s, c) => s + c.donorCount,
      );

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF056B2A), Color(0xFF033D18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF045F25).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '$total Active Campaigns',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Support Your\nFavourite Athletes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _BannerStat(
                  label: 'Total Raised',
                  value: '${Currency.symbol}${_fmtLarge(totalRaised)}',
                  icon: Icons.trending_up,
                ),
                const SizedBox(width: 24),
                _BannerStat(
                  label: 'Donors',
                  value: '$totalDonors',
                  icon: Icons.people_outline,
                ),
                const SizedBox(width: 24),
                _BannerStat(
                  label: 'Goals Hit',
                  value:
                      '${_ctrl.activeCampaigns.where((c) => c.isGoalReached).length}',
                  icon: Icons.flag,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMyCampaignsStrip(BuildContext context) {
    return Obx(() {
      if (_ctrl.myCampaigns.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: [
                const Text(
                  '⚡ My Campaigns',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                Text(
                  '${_ctrl.myCampaigns.length} total',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _ctrl.myCampaigns.length,
              itemBuilder: (_, i) {
                final c = _ctrl.myCampaigns[i];
                return GestureDetector(
                  onTap: () {
                    _ctrl.selectCampaign(c);
                    Get.to(() => CampaignDetailScreen(campaign: c));
                  },
                  onLongPress: () => CampaignDeepLinkService.shareCampaign(
                    campaignId: c.id,
                    campaignTitle: c.title,
                    creatorName: c.creatorName,
                  ),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _TypeChipSmall(type: c.type),
                                  const Spacer(),
                                  _StatusDot(isActive: c.isActive),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              LinearProgressIndicator(
                                value: c.progressPercent,
                                backgroundColor: const Color(
                                  0xFF045F25,
                                ).withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF045F25),
                                ),
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${Currency.symbol}${_fmtLarge(c.raisedAmount)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFF045F25),
                                    ),
                                  ),
                                  Text(
                                    '${(c.progressPercent * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (c.isGoalReached)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Text('🏆', style: TextStyle(fontSize: 16)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterBar() {
    final filters = [
      (_CampaignFilter.all, 'All'),
      (_CampaignFilter.individual, '🧑 Individual'),
      (_CampaignFilter.group, '🏟 Group'),
      (_CampaignFilter.nearGoal, '🔥 Near Goal'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discover Campaigns',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final selected = _filter == f.$1;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF045F25)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList() {
    return Obx(() {
      final items = _filtered;
      if (items.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No campaigns yet',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Be the first to launch a campaign!',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => CampaignCard(
              campaign: items[i],
              onTap: () {
                _ctrl.selectCampaign(items[i]);
                Get.to(() => CampaignDetailScreen(campaign: items[i]));
              },
            ),
            childCount: items.length,
          ),
        ),
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

// ─── Small banner helpers ─────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _TypeChipSmall extends StatelessWidget {
  final CampaignType type;
  const _TypeChipSmall({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: type == CampaignType.group
            ? Colors.blue.withOpacity(0.12)
            : const Color(0xFF045F25).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type == CampaignType.group ? '🏟' : '🧑',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isActive;
  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
