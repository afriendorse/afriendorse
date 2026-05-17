// lib/athlete/feature/campaigns/widgets/campaign_widgets.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/shared/currency_helper.dart';

// ─────────────────────────────────────────────
//  Animated Progress Ring
// ─────────────────────────────────────────────

class CampaignProgressRing extends StatefulWidget {
  final double progress; // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Color? color;

  const CampaignProgressRing({
    Key? key,
    required this.progress,
    this.size = 180,
    this.strokeWidth = 12,
    this.child,
    this.color,
  }) : super(key: key);

  @override
  State<CampaignProgressRing> createState() => _CampaignProgressRingState();
}

class _CampaignProgressRingState extends State<CampaignProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CampaignProgressRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFF045F25);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: _anim.value,
            strokeWidth: widget.strokeWidth,
            color: color,
            bgColor: color.withOpacity(0.12),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color bgColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // FIX: Early return if no progress to draw
    if (progress <= 0.001) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // FIX: Ensure minimum sweep angle for valid gradient
    final effectiveSweep = sweepAngle < 0.01 ? 0.01 : sweepAngle;

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + effectiveSweep,
        colors: [color.withOpacity(0.7), color],
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, gradientPaint);

    // Dot at tip
    if (progress > 0.02) {
      final angle = -math.pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, strokeWidth / 2.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Supporter Tier Badge
// ─────────────────────────────────────────────

class SupporterTierBadge extends StatelessWidget {
  final SupporterTier tier;
  final bool large;

  const SupporterTierBadge({Key? key, required this.tier, this.large = false})
    : super(key: key);

  Color get _color {
    switch (tier) {
      case SupporterTier.fan:
        return const Color(0xFFCD7F32); // bronze
      case SupporterTier.supporter:
        return const Color(0xFFC0C0C0); // silver
      case SupporterTier.champion:
        return const Color(0xFFFFD700); // gold
      case SupporterTier.legend:
        return const Color(0xFF9B59B6); // purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = large ? 14.0 : 11.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 6,
        vertical: large ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tier.emoji, style: TextStyle(fontSize: size)),
          const SizedBox(width: 4),
          Text(
            tier.badge,
            style: TextStyle(
              color: _color,
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Donor Leaderboard Row
// ─────────────────────────────────────────────

class DonorLeaderboardTile extends StatelessWidget {
  final CampaignDonor donor;
  final int rank;

  const DonorLeaderboardTile({
    Key? key,
    required this.donor,
    required this.rank,
  }) : super(key: key);

  Widget _rankWidget() {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 20));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 20));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 20));
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 12,
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
        children: [
          SizedBox(width: 30, child: Center(child: _rankWidget())),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
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
                      fontSize: 13,
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
                  donor.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    SupporterTierBadge(tier: donor.tier),
                    const SizedBox(width: 6),
                    if (donor.lastFrequency == DonationFrequency.monthly)
                      _RecurringChip(),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${Currency.symbol}${_formatAmount(donor.totalAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF045F25),
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

class _RecurringChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.autorenew, size: 9, color: Colors.blue),
          SizedBox(width: 2),
          Text(
            'Monthly',
            style: TextStyle(
              fontSize: 9,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Milestone Progress Bar
// ─────────────────────────────────────────────

class MilestoneProgressBar extends StatefulWidget {
  final List<CampaignMilestone> milestones;
  final double currentAmount;
  final double goalAmount;

  const MilestoneProgressBar({
    Key? key,
    required this.milestones,
    required this.currentAmount,
    required this.goalAmount,
  }) : super(key: key);

  @override
  State<MilestoneProgressBar> createState() => _MilestoneProgressBarState();
}

class _MilestoneProgressBarState extends State<MilestoneProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.goalAmount > 0
          ? (widget.currentAmount / widget.goalAmount).clamp(0.0, 1.0)
          : 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar — use LayoutBuilder so we can place milestone dots
          // precisely without negative margins (which crash the Container
          // assertion 'margin.isNonNegative').
          LayoutBuilder(
            builder: (_, constraints) {
              final barWidth = constraints.maxWidth;
              return SizedBox(
                height: 14, // enough room for 10px dot centered on 8px bar
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background track
                    Positioned(
                      top: 3,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Filled progress
                    Positioned(
                      top: 3,
                      left: 0,
                      width: barWidth * _anim.value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF056B2A), Color(0xFF045F25)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Milestone dots — positioned absolutely, no negative margin
                    if (widget.goalAmount > 0)
                      for (final m in widget.milestones)
                        Positioned(
                          // centre of dot = left + half dot width
                          left:
                              (barWidth *
                                  (m.targetAmount / widget.goalAmount).clamp(
                                    0.0,
                                    1.0,
                                  )) -
                              5,
                          top: 2, // (14 - 10) / 2 = 2, centred vertically
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: m.isUnlocked
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: m.isUnlocked
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFFD700,
                                        ).withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Milestone labels
          Row(
            children: widget.milestones
                .map(
                  (m) => Expanded(
                    child: Column(
                      children: [
                        Icon(
                          m.isUnlocked ? Icons.star : Icons.star_border,
                          size: 14,
                          color: m.isUnlocked
                              ? const Color(0xFFFFD700)
                              : Colors.grey.shade400,
                        ),
                        Text(
                          _percent(m.targetAmount),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: m.isUnlocked
                                ? const Color(0xFFFFD700)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _percent(double target) {
    if (widget.goalAmount <= 0) return '';
    final pct = ((target / widget.goalAmount) * 100).round();
    return '$pct%';
  }
}

// ─────────────────────────────────────────────
//  Confetti Burst (pure Flutter, no package)
// ─────────────────────────────────────────────

class ConfettiBurst extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const ConfettiBurst({Key? key, required this.trigger, required this.child})
    : super(key: key);

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _rand = math.Random();
  bool _showing = false;

  static const _colors = [
    Color(0xFFFFD700),
    Color(0xFF045F25),
    Color(0xFF4CAF50),
    Color(0xFFFF6B35),
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
    Color(0xFFE74C3C),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2000),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            setState(() => _showing = false);
          }
        });
  }

  @override
  void didUpdateWidget(ConfettiBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _burst();
  }

  void _burst() {
    _particles.clear();
    for (int i = 0; i < 60; i++) {
      _particles.add(
        _ConfettiParticle(
          color: _colors[_rand.nextInt(_colors.length)],
          angle: _rand.nextDouble() * 2 * math.pi,
          speed: 80 + _rand.nextDouble() * 200,
          size: 4 + _rand.nextDouble() * 8,
          rotationSpeed: _rand.nextDouble() * 10,
          isRect: _rand.nextBool(),
        ),
      );
    }
    setState(() => _showing = true);
    _ctrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        if (_showing)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _ctrl.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  final double rotationSpeed;
  final bool isRect;

  const _ConfettiParticle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
    required this.isRect,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width / 2;
    final startY = size.height * 0.3;

    for (final p in particles) {
      final t = progress;
      final gravity = 200.0 * t * t;
      final x = startX + math.cos(p.angle) * p.speed * t;
      final y = startY + math.sin(p.angle) * p.speed * t + gravity;
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withOpacity(opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * t * math.pi * 2);

      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.4,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Campaign Card (for list views)
// ─────────────────────────────────────────────

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;
  final bool compact;

  const CampaignCard({
    Key? key,
    required this.campaign,
    required this.onTap,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image / gradient header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  campaign.coverImage != null && campaign.coverImage!.isNotEmpty
                      ? Image.network(
                          campaign.coverImage!,
                          height: compact ? 100 : 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _CoverFallback(compact: compact),
                        )
                      : _CoverFallback(compact: compact),
                  Positioned.fill(
                    child: Container(
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
                  ),
                  // Type chip
                  Positioned(
                    top: 8,
                    left: 10,
                    child: _TypeChip(type: campaign.type),
                  ),
                  // Days left
                  Positioned(
                    top: 8,
                    right: 10,
                    child: _DaysLeftChip(daysLeft: campaign.daysLeft),
                  ),
                  // Progress overlay bottom
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: campaign.progressPercent,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF4CAF50),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(campaign.progressPercent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${campaign.creatorName}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Text(
                      campaign.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Currency.symbol}${_fmt(campaign.raisedAmount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF045F25),
                            ),
                          ),
                          Text(
                            'of ${Currency.symbol}${_fmt(campaign.goalAmount)} goal',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${campaign.donorCount}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (campaign.isGoalReached) ...[
                            const SizedBox(width: 8),
                            const Text('🏆', style: TextStyle(fontSize: 16)),
                          ],
                        ],
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
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _CoverFallback extends StatelessWidget {
  final bool compact;
  const _CoverFallback({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 100 : 130,
      width: double.infinity,
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
          size: 40,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final CampaignType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final isGroup = type == CampaignType.group;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isGroup ? Colors.blue.withOpacity(0.85) : Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isGroup ? '🏟 Group' : '🧑 Individual',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DaysLeftChip extends StatelessWidget {
  final int daysLeft;
  const _DaysLeftChip({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final isUrgent = daysLeft <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withOpacity(0.85) : Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        daysLeft == 0 ? 'Ends today' : '${daysLeft}d left',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
