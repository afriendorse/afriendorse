// lib/athlete/feature/campaigns/widgets/athlete_campaign_section.dart
//
// Displays an athlete's active individual campaigns on their
// ProviderDetailsScreen profile.
//
// Placement in ProviderDetailsScreen (provider_details_screen.dart):
//   Insert the widget BETWEEN the "Donate to this Athlete" button and the
//   role gate builder — see the integration comment at the bottom of this file.
//
// The widget is self-contained:
//   • It streams the athlete's campaigns internally via CampaignFirestoreService.
//   • If no active individual campaigns exist it renders nothing (SizedBox.shrink).
//   • Tapping a card navigates to CampaignDetailScreen, which already handles
//     the full brand/fan donation flow.

import 'package:afriendorse/util/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_firestore_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:intl/intl.dart';

class AthleteCampaignSection extends StatefulWidget {
  /// The athlete's canonical email (lowercase) — same field used throughout
  /// the campaign system as `creatorId` / `athleteEmailLower`.
  final String athleteEmailLower;

  /// Display name shown in the section header, e.g. "John's Campaigns".
  final String athleteDisplayName;

  const AthleteCampaignSection({
    Key? key,
    required this.athleteEmailLower,
    required this.athleteDisplayName,
  }) : super(key: key);

  @override
  State<AthleteCampaignSection> createState() => _AthleteCampaignSectionState();
}

class _AthleteCampaignSectionState extends State<AthleteCampaignSection> {
  List<CampaignModel> _campaigns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    CampaignFirestoreService.streamAthleteCampaigns(
      widget.athleteEmailLower,
    ).listen((list) {
      final individual = list
          .where((c) => c.isActive && c.type == CampaignType.individual)
          .toList();
      if (mounted) {
        setState(() {
          _campaigns = individual;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show nothing while loading or if there are no active individual campaigns
    if (_loading || _campaigns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF045F25).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🏃', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.athleteDisplayName.split(' ').first}\'s Campaigns',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Support this athlete directly',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF045F25).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_campaigns.length} active',
                  style: const TextStyle(
                    color: Color(0xFF045F25),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Horizontal campaign cards ──────────────────────────────────────
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _campaigns.length,
            itemBuilder: (_, i) => _CampaignPreviewCard(
              campaign: _campaigns[i],
              onTap: () => _openDetail(_campaigns[i]),
            ),
          ),
        ),

        // ── Bottom divider ─────────────────────────────────────────────────
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: Colors.grey.withOpacity(0.12)),
        ),
      ],
    );
  }

  void _openDetail(CampaignModel campaign) {
    // Check if user is logged in first
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute());
      return;
    }

    // Ensure the controller is registered (it may not be on the brand/fan side)
    AltCampaignController ctrl;
    try {
      ctrl = Get.find<AltCampaignController>(tag: AltCampaignController.tag);
    } catch (_) {
      ctrl = Get.put(AltCampaignController(), tag: AltCampaignController.tag);
    }
    ctrl.selectCampaign(campaign);
    Get.to(() => CampaignDetailScreen(campaign: campaign));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Campaign Preview Card  (horizontal scroll item)
// ─────────────────────────────────────────────────────────────────────────────

class _CampaignPreviewCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignPreviewCard({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent.clamp(0.0, 1.0);
    final pct = (progress * 100).toStringAsFixed(0);
    final daysLeft = campaign.daysLeft;
    final isUrgent = daysLeft <= 7 && daysLeft > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image / gradient ───────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                height: 88,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    campaign.coverImage != null &&
                            campaign.coverImage!.isNotEmpty
                        ? Image.network(
                            campaign.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _CoverFallback(),
                          )
                        : _CoverFallback(),

                    // Dark overlay for text legibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),

                    // Urgent badge
                    if (isUrgent)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🔥 ${daysLeft}d left',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Goal reached badge
                    if (campaign.isGoalReached)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🏆 Goal hit!',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Progress % bottom-left
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Text(
                        '$pct% funded',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Progress bar ─────────────────────────────────────────────
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: const Color(0xFF045F25).withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF045F25),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                20,
                12,
                12,
              ), // Added bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 1, // Changed from 2 to 1
                    overflow:
                        TextOverflow.ellipsis, // Shows "..." when truncated
                  ),

                  const SizedBox(height: 8),

                  // Amount row
                  Row(
                    children: [
                      // Raised
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Currency.symbol}${_fmt(campaign.raisedAmount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF045F25),
                              ),
                            ),
                            Text(
                              'raised',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.withOpacity(0.15),
                      ),
                      const SizedBox(width: 10),

                      // Donors
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${campaign.donorCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'donors',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // CTA arrow
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF045F25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final formatter = NumberFormat('#,##0.##');
    if (v >= 1000000) return '${formatter.format(v / 1000000)}M';
    if (v >= 1000) return '${formatter.format(v / 1000)}K';
    return formatter.format(v);
  }
}

class _CoverFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF056B2A), Color(0xFF033D18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 32,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HOW TO INTEGRATE INTO provider_details_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//
//  In ProviderDetailsScreenState.build(), inside the Column of the
//  SingleChildScrollView, add AthleteCampaignSection AFTER the
//  "Donate to this Athlete" button and BEFORE the role-gate builder:
//
//  ```dart
//  // ── Donate button (existing) ──
//  if (athleteEmailLower.isNotEmpty)
//    Padding(
//      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//      child: ... // existing ElevatedButton.icon
//    ),
//
//  // ── NEW: Individual campaign strip ──────────────────────────────
//  if (athleteEmailLower.isNotEmpty)
//    AthleteCampaignSection(
//      athleteEmailLower: athleteEmailLower,
//      athleteDisplayName: athleteDisplayName,
//    ),
//
//  // ── Role gate (existing) ────────────────────────────────────────
//  GetBuilder<FanDealRequestController>(
//    builder: (dealCtrl) { ... }
//  ),
//  ```
//
//  That's the only change needed in provider_details_screen.dart.
//  The section self-manages its Firestore stream and renders nothing
//  if the athlete has no active individual campaigns.
