// lib/athlete/feature/campaigns/screens/campaign_detail_screen.dart

import 'package:afriendorse/athlete/feature/campaigns/repository/athlete_wallet_donation_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/athlete_campaign_payment_sheet.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_payment_method_sheet.dart';
import 'package:afriendorse/athlete/feature/campaigns/service/campaign_currency_mixin.dart';
import 'package:afriendorse/athlete/feature/campaigns/service/campaign_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/widgets/currency_quick_amount_widget.dart';
import 'package:afriendorse/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/widgets/campaign_widgets.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:intl/intl.dart';

class CampaignDetailScreen extends StatefulWidget {
  final CampaignModel campaign;
  const CampaignDetailScreen({Key? key, required this.campaign})
    : super(key: key);

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen>
    with TickerProviderStateMixin {
  late AltCampaignController _ctrl;
  late AnimationController _headerAnim;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _confettiTrigger = false;

  @override
  void initState() {
    super.initState();
    try {
      _ctrl = Get.find<AltCampaignController>();
    } catch (_) {
      _ctrl = Get.put(AltCampaignController());
    }
    _ctrl.selectCampaign(widget.campaign);

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    if (widget.campaign.isGoalReached) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _confettiTrigger = true);
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isCreator => _ctrl.currentUserId == widget.campaign.creatorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: ConfettiBurst(
        trigger: _confettiTrigger,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    _buildHeroStats(),
                    _buildProgressSection(),
                    _buildMilestones(),
                    _buildStory(),
                    _buildLeaderboard(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildDonateButton(context),
    );
  }

  // ─── Sliver App Bar ───────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF045F25),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          tooltip: 'Share campaign',
          icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
          onPressed: () => CampaignDeepLinkService.shareCampaign(
            campaignId: widget.campaign.id,
            campaignTitle: widget.campaign.title,
            creatorName: widget.campaign.creatorName,
            coverImage: widget.campaign.coverImage,
          ),
        ),
        if (_isCreator)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'edit') _showEditDialog(context);
              if (v == 'delete') _confirmDelete(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Edit Campaign'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete Campaign',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(52, 0, 52, 14),
        title: Text(
          widget.campaign.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.campaign.coverImage != null &&
                    widget.campaign.coverImage!.isNotEmpty
                ? Image.network(
                    widget.campaign.coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _coverFallback(),
                  )
                : _coverFallback(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
            Positioned(
              bottom: 52,
              left: 16,
              child: Row(
                children: [
                  _StatusPill(campaign: widget.campaign),
                  const SizedBox(width: 8),
                  _TypePill(type: widget.campaign.type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback() => Container(
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
        size: 80,
        color: Colors.white.withOpacity(0.2),
      ),
    ),
  );

  // ─── Hero Stats ───────────────────────────────

  Widget _buildHeroStats() {
    final c = widget.campaign;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 320;

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Raised',
                        '${Currency.symbol}${_fmt(c.raisedAmount)}',
                        const Color(0xFF045F25),
                        Icons.trending_up,
                      ),
                    ),
                    _buildVDivider(),
                    Expanded(
                      child: _buildStatItem(
                        'Goal',
                        '${Currency.symbol}${_fmt(c.goalAmount)}',
                        Colors.blueGrey,
                        Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Donors',
                        '${c.donorCount}',
                        Colors.orange,
                        Icons.favorite_border,
                      ),
                    ),
                    _buildVDivider(),
                    Expanded(
                      child: _buildStatItem(
                        'Days Left',
                        c.isExpired ? 'Ended' : '${c.daysLeft}d',
                        c.daysLeft <= 3 ? Colors.red : Colors.blueAccent,
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Raised',
                  '${Currency.symbol}${_fmt(c.raisedAmount)}',
                  const Color(0xFF045F25),
                  Icons.trending_up,
                ),
              ),
              _buildVDivider(),
              Expanded(
                child: _buildStatItem(
                  'Goal',
                  '${Currency.symbol}${_fmt(c.goalAmount)}',
                  Colors.blueGrey,
                  Icons.flag_outlined,
                ),
              ),
              _buildVDivider(),
              Expanded(
                child: _buildStatItem(
                  'Donors',
                  '${c.donorCount}',
                  Colors.orange,
                  Icons.favorite_border,
                ),
              ),
              _buildVDivider(),
              Expanded(
                child: _buildStatItem(
                  'Days Left',
                  c.isExpired ? 'Ended' : '${c.daysLeft}d',
                  c.daysLeft <= 3 ? Colors.red : Colors.blueAccent,
                  Icons.access_time,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVDivider() => Container(
    width: 1,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Colors.grey.withOpacity(0.1),
  );

  // ─── Progress Section ─────────────────────────

  Widget _buildProgressSection() {
    final c = widget.campaign;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: c.isGoalReached
                    ? _pulseAnim.value.clamp(0.95, 1.05)
                    : 1.0,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: CampaignProgressRing(
                    progress: c.progressPercent.clamp(0.0, 1.0),
                    size: 120,
                    strokeWidth: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${(c.progressPercent * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF045F25),
                            ),
                          ),
                        ),
                        Text(
                          c.isGoalReached ? '🏆 Goal!' : 'funded',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              c.isGoalReached
                  ? '🎉 Goal reached! This campaign smashed its target.'
                  : '${Currency.symbol}${_fmt(c.remainingAmount)} remaining to reach the goal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: c.isGoalReached
                    ? const Color(0xFF045F25)
                    : Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (c.recurringDonorCount > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.autorenew, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${c.recurringDonorCount} monthly supporters',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          MilestoneProgressBar(
            milestones: c.milestones,
            currentAmount: c.raisedAmount,
            goalAmount: c.goalAmount,
          ),
        ],
      ),
    );
  }

  // ─── Milestones ───────────────────────────────

  Widget _buildMilestones() {
    final milestones = widget.campaign.milestones;
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text('🏅 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  'Campaign Milestones',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...milestones.asMap().entries.map(
            (e) => _MilestoneTile(milestone: e.value, index: e.key),
          ),
        ],
      ),
    );
  }

  // ─── Story ────────────────────────────────────

  Widget _buildStory() {
    final story = widget.campaign.story;
    final description = widget.campaign.description;
    if (story.isEmpty && description.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📖 Our Story',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            story.isNotEmpty ? story : description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF045F25).withOpacity(0.12),
                backgroundImage:
                    widget.campaign.creatorAvatar?.isNotEmpty == true
                    ? NetworkImage(widget.campaign.creatorAvatar!)
                    : null,
                child: widget.campaign.creatorAvatar?.isNotEmpty != true
                    ? Text(
                        widget.campaign.creatorName.isNotEmpty
                            ? widget.campaign.creatorName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF045F25),
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.campaign.creatorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.campaign.type == CampaignType.group
                          ? 'Admin · ${widget.campaign.groupName ?? "Group Campaign"}'
                          : 'Campaign Organiser',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Leaderboard ──────────────────────────────

  Widget _buildLeaderboard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text('🏆 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  'Top Supporters',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final donors = _ctrl.leaderboard;
            if (donors.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        size: 32,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to support!',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: donors
                  .asMap()
                  .entries
                  .map(
                    (e) =>
                        DonorLeaderboardTile(donor: e.value, rank: e.key + 1),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  // ─── Donate FAB ───────────────────────────────

  Widget _buildDonateButton(BuildContext context) {
    if (!widget.campaign.isActive || widget.campaign.isExpired) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => _showDonateBottomSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF045F25),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF045F25).withOpacity(0.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 18),
            SizedBox(width: 8),
            Text(
              'Support This Campaign',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonateBottomSheet(BuildContext context) {
    _ctrl.resetDonateForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DonateSheet(
        campaign: widget.campaign,
        controller: _ctrl,
        onSuccess: () {
          setState(() => _confettiTrigger = true);
          Future.delayed(
            const Duration(milliseconds: 2000),
            () => setState(() => _confettiTrigger = false),
          );
        },
      ),
    );
  }

  // ─── Creator: Edit ────────────────────────────

  void _showEditDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: widget.campaign.title);
    final descCtrl = TextEditingController(text: widget.campaign.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Campaign',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF045F25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _ctrl.editCampaign(
                campaignId: widget.campaign.id,
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ─── Creator: Delete ──────────────────────────

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Campaign',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red),
        ),
        content: const Text(
          'This will permanently delete this campaign and all its donation data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);

              final ok = await _ctrl.deleteCampaign(widget.campaign.id);

              if (!mounted) return;

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Campaign deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade700,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 1800));
                if (mounted) Get.back();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to delete campaign'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  String _fmt(double v) {
    final formatter = NumberFormat('#,##0.##');
    if (v >= 1000000) return '${formatter.format(v / 1000000)}M';
    if (v >= 1000) return '${formatter.format(v / 1000)}K';
    return formatter.format(v);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Donate Bottom Sheet - WITH CURRENCY SUPPORT
// ─────────────────────────────────────────────────────────────────────────────

class _DonateSheet extends StatefulWidget {
  final CampaignModel campaign;
  final AltCampaignController controller;
  final VoidCallback onSuccess;

  const _DonateSheet({
    required this.campaign,
    required this.controller,
    required this.onSuccess,
  });

  @override
  State<_DonateSheet> createState() => _DonateSheetState();
}

class _DonateSheetState extends State<_DonateSheet> with CampaignCurrencyMixin {
  final _quickAmounts = [25.0, 50.0, 100.0, 250.0, 500.0];

  double _amt = 0;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady(); // ✅ Initialize currency
    _amt = double.tryParse(widget.controller.donateAmountController.text) ?? 0;
    widget.controller.donateAmountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final parsed =
        double.tryParse(widget.controller.donateAmountController.text) ?? 0;
    if (!mounted) return;
    setState(() {
      _amt = parsed;
      if (_amountError != null) _amountError = null;
    });
  }

  @override
  void dispose() {
    widget.controller.donateAmountController.removeListener(_onAmountChanged);
    super.dispose();
  }

  String? _validateAmount() {
    final raw = widget.controller.donateAmountController.text.trim();

    if (raw.isEmpty) return 'Please enter a donation amount.';

    final amount = double.tryParse(raw);
    if (amount == null) return 'Please enter a valid number.';
    if (amount <= 0) return 'Amount must be greater than zero.';

    if (amount < widget.campaign.minimumDonation) {
      final min = widget.campaign.minimumDonation.toStringAsFixed(0);
      return 'Minimum donation is ${Currency.symbol}$min. '
          'Please increase your amount.';
    }

    return null;
  }

  Future<void> _handleDonate() async {
    final error = _validateAmount();
    if (error != null) {
      setState(() => _amountError = error);
      return;
    }

    final amount =
        double.tryParse(widget.controller.donateAmountController.text) ?? 0;

    Navigator.pop(context);

    final isAthlete = widget.controller.userRole == 'athlete';

    if (isAthlete) {
      await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AthleteCampaignPaymentSheet(
          campaign: widget.campaign,
          amount: amount,
          onWalletPayment: () => _donateViaAthleteWallet(amount),
          onOnlinePayment: () => _donateViaFlutterwave(amount),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CampaignPaymentMethodSheet(
          amount: amount,
          frequency: widget.controller.donationFrequency.value,
          onWalletPayment: () => _donateViaWallet(amount),
          onOnlinePayment: () => _donateViaFlutterwave(amount),
        ),
      );
    }
  }

  Future<void> _donateViaAthleteWallet(double amount) async {
    if (widget.controller.donationFrequency.value ==
        DonationFrequency.monthly) {
      Get.snackbar(
        'Not Available',
        'Monthly donations require online payment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final success = await AthleteWalletDonationService.donate(
      athleteEmailLower: widget.controller.currentUserIdLower,
      athleteName: widget.controller.currentUserName,
      athleteId: widget.controller.currentUserId,
      campaign: widget.campaign,
      amount: amount,
      isAnonymous: widget.controller.donateAnonymously.value,
      message: widget.controller.donateMessageController.text.isEmpty
          ? null
          : widget.controller.donateMessageController.text,
    );

    widget.controller.resetDonateForm();

    if (success) {
      widget.onSuccess();
      Get.snackbar(
        'Donation Successful 🎉',
        'Thank you! Your donation to "${widget.campaign.title}" was received.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Payment Failed',
        'Could not process wallet donation. Please check your balance or try online payment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _donateViaWallet(double amount) async {
    if (widget.controller.donationFrequency.value ==
        DonationFrequency.monthly) {
      Get.snackbar(
        'Not Available',
        'Monthly donations require online payment to save your card for recurring charges.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    try {
      final walletController = Get.find<WalletController>();
      final success = await walletController.deductAndRefresh(
        amount: amount,
        purpose: 'campaign_donation',
      );

      if (!success) {
        Get.snackbar(
          'Payment Failed',
          'Wallet payment could not be processed. Please try online payment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final donationId = await CampaignFirestoreService.initiateDonation(
        campaignId: widget.campaign.id,
        campaignTitle: widget.campaign.title,
        athleteId: widget.campaign.creatorId,
        athleteName: widget.campaign.creatorName,
        groupId: widget.campaign.groupId,
        donorId: widget.controller.currentUserId,
        donorName: widget.controller.donateAnonymously.value
            ? 'Anonymous'
            : widget.controller.currentUserName,
        donorEmail: widget.controller.currentUserEmail,
        amount: amount,
        frequency: DonationFrequency.oneTime,
        isAnonymous: widget.controller.donateAnonymously.value,
        message: widget.controller.donateMessageController.text.isEmpty
            ? null
            : widget.controller.donateMessageController.text,
      );

      if (donationId == null) {
        final ref = 'wallet_campaign_${DateTime.now().millisecondsSinceEpoch}';
        Get.snackbar(
          'Action Needed',
          'Your wallet was charged (ref: $ref) but the donation '
              'record failed. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 8),
        );
        return;
      }

      final walletRef =
          'wallet_campaign_${widget.controller.currentUserId}_'
          '${DateTime.now().millisecondsSinceEpoch}';

      final completed = await CampaignFirestoreService.completeDonation(
        donationId: donationId,
        transactionRef: walletRef,
      );

      widget.controller.resetDonateForm();

      if (completed) {
        widget.onSuccess();
        Get.snackbar(
          'Donation Successful 🎉',
          'Thank you! Your donation to "${widget.campaign.title}" was received.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Processing',
          'Payment confirmed! Your donation is being processed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (kDebugMode) print('[CampaignWalletDonation] error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _donateViaFlutterwave(double amount) async {
    final bool ok = await widget.controller.startDonation(
      campaign: widget.campaign,
      context: Get.context!,
    );
    if (ok) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF045F25).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF045F25),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Make a Donation',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.campaign.title,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group campaign banner
            if (widget.campaign.type == CampaignType.group &&
                widget.campaign.groupName != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Text('🏟', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.campaign.groupName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Quick amounts label
            const Text(
              'Quick amounts',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Currency-aware quick chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amt) {
                final isBelowMin = amt < widget.campaign.minimumDonation;
                final selected =
                    widget.controller.donateAmountController.text ==
                    amt.toStringAsFixed(0);

                return CampaignQuickAmountChip(
                  usdAmount: amt,
                  isSelected: selected,
                  onTap: isBelowMin
                      ? () {}
                      : () {
                          widget.controller.donateAmountController.text = amt
                              .toStringAsFixed(0);
                          setState(() => _amountError = null);
                        },
                  activeColor: const Color(0xFF045F25),
                  displayLabel: '${Currency.symbol}${_fmtAmt(amt)}',
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Custom amount with inline error ──────────────────────
            TextField(
              controller: widget.controller.donateAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Or enter amount (${Currency.symbol})',
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: _amountError != null
                      ? Colors.red
                      : const Color(0xFF045F25),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _amountError != null
                        ? Colors.red.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _amountError != null
                        ? Colors.red
                        : const Color(0xFF045F25),
                    width: 2,
                  ),
                ),
                helperText: _amountError == null
                    ? 'Minimum: ${Currency.symbol}'
                          '${widget.campaign.minimumDonation.toStringAsFixed(0)}'
                    : null,
                errorText: _amountError,
                errorMaxLines: 2,
              ),
            ),

            // ✅ Local currency hint
            CampaignDonationAmountHint(
              usdAmount: _amt,
              textColor: const Color(0xFF045F25),
            ),

            const SizedBox(height: 14),

            // Frequency
            const Text(
              'Donation type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: DonationFrequency.values.map((f) {
                      final sel =
                          widget.controller.donationFrequency.value == f;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              widget.controller.donationFrequency.value = f,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              right: f == DonationFrequency.oneTime ? 6 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFF045F25)
                                  : Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF045F25)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  f == DonationFrequency.oneTime
                                      ? Icons.bolt
                                      : Icons.autorenew,
                                  color: sel ? Colors.white : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f == DonationFrequency.oneTime
                                      ? 'One-time'
                                      : 'Monthly',
                                  style: TextStyle(
                                    color: sel ? Colors.white : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                      axisAlignment: -1,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child:
                        widget.controller.donationFrequency.value ==
                            DonationFrequency.monthly
                        ? _MonthlyInfoBanner(
                            key: const ValueKey('monthly_banner'),
                            amount: _amt,
                            campaign: widget.campaign,
                          )
                        : const SizedBox.shrink(key: ValueKey('no_banner')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Message
            TextField(
              controller: widget.controller.donateMessageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Leave a message (optional)',
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF045F25),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Anonymous toggle
            Obx(
              () => Row(
                children: [
                  Switch(
                    value: widget.controller.donateAnonymously.value,
                    onChanged: (v) =>
                        widget.controller.donateAnonymously.value = v,
                    activeColor: const Color(0xFF045F25),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Donate anonymously',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text('🦸', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tier preview
            if (_amt > 0 && _amountError == null) ...[
              Builder(
                builder: (_) {
                  final tier = SupporterTierX.fromAmount(_amt);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF045F25).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF045F25).withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(tier.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "You'll join as a ${tier.label}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _tierDesc(tier),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SupporterTierBadge(tier: tier),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Exchange rate info
            Center(
              child: CampaignExchangeRateStrip(
                textColor: const Color(0xFF045F25).withOpacity(0.7),
                backgroundColor: const Color(0xFF045F25).withOpacity(0.05),
              ),
            ),

            const SizedBox(height: 16),

            // Donate button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: widget.controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleDonate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF045F25),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF045F25).withOpacity(0.4),
                        ),
                        child: const Text(
                          'Proceed to Donate',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tierDesc(SupporterTier tier) {
    switch (tier) {
      case SupporterTier.fan:
        return 'Every contribution counts!';
      case SupporterTier.supporter:
        return 'A true supporter of this athlete';
      case SupporterTier.champion:
        return 'Gold-tier champion of this campaign';
      case SupporterTier.legend:
        return "Legendary support — you're unstoppable!";
    }
  }

  String _fmtAmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// [Rest of your widget classes remain exactly the same: _StatusPill, _TypePill, _MilestoneTile, DonorLeaderboardTile, _MonthlyInfoBanner, _InfoTile, _RecurringChip]

// ─────────────────────────────────────────────────────────────────────────────
//  Small shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final CampaignModel campaign;
  const _StatusPill({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final isActive = campaign.isActive && !campaign.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.85)
            : Colors.red.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? '🟢 Active' : '🔴 Closed',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final CampaignType type;
  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      type == CampaignType.group ? '🏟 Group Campaign' : '🧑 Individual',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _MilestoneTile extends StatelessWidget {
  final CampaignMilestone milestone;
  final int index;
  const _MilestoneTile({required this.milestone, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: milestone.isUnlocked
              ? const Color(0xFFFFD700).withOpacity(0.06)
              : Colors.grey.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: milestone.isUnlocked
                ? const Color(0xFFFFD700).withOpacity(0.3)
                : Colors.grey.withOpacity(0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: milestone.isUnlocked
                    ? const Color(0xFFFFD700)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  milestone.isUnlocked ? '⭐' : '${index + 1}',
                  style: TextStyle(
                    fontSize: milestone.isUnlocked ? 14 : 11,
                    fontWeight: FontWeight.w700,
                    color: milestone.isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: milestone.isUnlocked
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: milestone.isUnlocked
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${Currency.symbol}${_fmt(milestone.targetAmount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: milestone.isUnlocked
                        ? const Color(0xFFFFD700)
                        : Colors.grey,
                  ),
                ),
                if (milestone.isUnlocked && milestone.unlockedAt != null)
                  const Text(
                    'Unlocked! 🎉',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class DonorLeaderboardTile extends StatelessWidget {
  final CampaignDonor donor;
  final int rank;

  const DonorLeaderboardTile({
    Key? key,
    required this.donor,
    required this.rank,
  }) : super(key: key);

  Widget _rankWidget() {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 18));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 18));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 18));
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 28, child: Center(child: _rankWidget())),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF045F25).withOpacity(0.12),
            backgroundImage:
                donor.donorAvatar != null && donor.donorAvatar!.isNotEmpty
                ? NetworkImage(donor.donorAvatar!)
                : null,
            child: donor.donorAvatar == null || donor.donorAvatar!.isEmpty
                ? Text(
                    donor.displayName.isNotEmpty
                        ? donor.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF045F25),
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  donor.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SupporterTierBadge(tier: donor.tier),
                    if (donor.lastFrequency == DonationFrequency.monthly) ...[
                      const SizedBox(width: 4),
                      _RecurringChip(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${Currency.symbol}${_formatAmount(donor.totalAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF045F25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

class _MonthlyInfoBanner extends StatelessWidget {
  final double amount;
  final CampaignModel campaign;

  const _MonthlyInfoBanner({
    super.key,
    required this.amount,
    required this.campaign,
  });

  static const Color _kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final hasAmount = amount > 0;
    final amountStr = hasAmount
        ? '${Currency.symbol}${amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2)}'
        : '${Currency.symbol}—';

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGreen.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.autorenew_rounded,
                      color: _kGreen,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Monthly recurring donation',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: _kGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kGreen,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'AUTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Charge summary ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Charge frequency',
                    value: 'Every 30 days',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.payments_outlined,
                    label: 'Amount per cycle',
                    value: amountStr,
                    valueColor: hasAmount ? _kGreen : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.credit_card_outlined,
                    label: 'Card saved?',
                    value: 'Yes — for future charges',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.cancel_outlined,
                    label: 'Cancel anytime',
                    value: 'From your Donations page',
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 20, color: _kGreen.withOpacity(0.1)),
          ),

          // ── Consent line ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFF5A8F6A),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.black.withOpacity(0.55),
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'By proceeding, you authorise AfriEndorse to charge your card ',
                        ),
                        TextSpan(
                          text: hasAmount ? '$amountStr monthly ' : 'monthly ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _kGreen,
                          ),
                        ),
                        TextSpan(
                          text:
                              'to support "${campaign.title}" until you cancel. '
                              'You can cancel at any time from your Donations page.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small two-line info tile used inside the banner ───────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF5A8F6A)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black.withOpacity(0.45),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecurringChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.autorenew, size: 8, color: Colors.blue),
          SizedBox(width: 2),
          Text(
            'Monthly',
            style: TextStyle(
              fontSize: 8,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
