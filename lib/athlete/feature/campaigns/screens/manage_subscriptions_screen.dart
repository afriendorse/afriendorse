// lib/athlete/feature/campaigns/screens/manage_subscriptions_screen.dart

import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_subscription_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/service/campaign_currency_mixin.dart';
import 'package:afriendorse/shared/currency_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageSubscriptionsScreen extends StatefulWidget {
  const ManageSubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<ManageSubscriptionsScreen> createState() =>
      _ManageSubscriptionsScreenState();
}

class _ManageSubscriptionsScreenState extends State<ManageSubscriptionsScreen>
    with CampaignCurrencyMixin {
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady();
  }

  @override
  Widget build(BuildContext context) {
    AltCampaignController ctrl;
    try {
      ctrl = Get.find<AltCampaignController>(tag: AltCampaignController.tag);
    } catch (_) {
      ctrl = Get.put(AltCampaignController(), tag: AltCampaignController.tag);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF045F25),
        title: const Text(
          'Monthly Donations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        final subs = ctrl.mySubscriptions;

        if (subs.isEmpty) {
          return _EmptyState();
        }

        final active = subs.where((s) => s.isActive).toList();
        final inactive = subs.where((s) => !s.isActive).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            // ── Summary banner ────────────────────────────────────────────
            _SummaryBanner(
              activeCount: active.length,
              totalMonthly: active.fold<double>(0, (s, e) => s + e.amount),
              hasLocalCurrency: hasLocalCurrency,
              isLoadingCurrency: isLoadingCurrency,
              getLocalEquivalent: getLocalEquivalent,
              localCurrencyCode: localCurrencyCode,
              localCountryFlag: localCountryFlag,
            ),

            const SizedBox(height: 20),

            // ── Active subscriptions ──────────────────────────────────────
            if (active.isNotEmpty) ...[
              _SectionHeader(
                label: 'Active (${active.length})',
                color: const Color(0xFF045F25),
                icon: Icons.autorenew,
              ),
              const SizedBox(height: 10),
              ...active.map(
                (s) => _SubCard(
                  sub: s,
                  ctrl: ctrl,
                  hasLocalCurrency: hasLocalCurrency,
                  isLoadingCurrency: isLoadingCurrency,
                  getLocalEquivalent: getLocalEquivalent,
                  localCurrencyCode: localCurrencyCode,
                  localCountryFlag: localCountryFlag,
                  onCancel: () => _confirmCancel(context, s, ctrl),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Paused / cancelled subscriptions ─────────────────────────
            if (inactive.isNotEmpty) ...[
              _SectionHeader(
                label: 'Inactive (${inactive.length})',
                color: Colors.grey.shade500,
                icon: Icons.pause_circle_outline,
              ),
              const SizedBox(height: 10),
              ...inactive.map(
                (s) => _SubCard(
                  sub: s,
                  ctrl: ctrl,
                  hasLocalCurrency: hasLocalCurrency,
                  isLoadingCurrency: isLoadingCurrency,
                  getLocalEquivalent: getLocalEquivalent,
                  localCurrencyCode: localCurrencyCode,
                  localCountryFlag: localCountryFlag,
                  onReactivate: s.status == 'paused' || s.status == 'cancelled'
                      ? () => _confirmReactivate(context, s, ctrl)
                      : null,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _confirmCancel(
    BuildContext context,
    CampaignSubscription sub,
    AltCampaignController ctrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              color: Colors.orange[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cancel Monthly Donation?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.heart,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub.campaignTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.creditCard,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${Currency.symbol}${_fmt(sub.amount)}/month',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                  // Local equivalent
                  if (hasLocalCurrency && !isLoadingCurrency) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 22),
                        if (localCountryFlag.isNotEmpty) ...[
                          Text(
                            localCountryFlag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          '≈ ${getLocalEquivalent(sub.amount)} $localCurrencyCode/month',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can reactivate anytime — your card details remain secure.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Keep Supporting',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ctrl.cancelSubscription(sub.campaignId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmReactivate(
    BuildContext context,
    CampaignSubscription sub,
    AltCampaignController ctrl,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleCheck,
              color: const Color(0xFF045F25),
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Reactivate Donation?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF045F25).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF045F25).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.heart,
                        size: 14,
                        color: const Color(0xFF045F25),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub.campaignTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.creditCard,
                        size: 14,
                        color: const Color(0xFF045F25),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${Currency.symbol}${_fmt(sub.amount)}/month',
                        style: const TextStyle(
                          color: Color(0xFF045F25),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Local equivalent
                  if (hasLocalCurrency && !isLoadingCurrency) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 22),
                        if (localCountryFlag.isNotEmpty) ...[
                          Text(
                            localCountryFlag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          '≈ ${getLocalEquivalent(sub.amount)} $localCurrencyCode/month',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF045F25).withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Resume your monthly support? You\'ll be charged on your next billing date using your saved card.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ctrl.reactivateSubscription(sub.campaignId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF045F25),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Reactivate',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v >= 1000000) {
      return '${_numberFormat.format(v / 1000000)}M';
    }
    if (v >= 1000) {
      return '${_numberFormat.format(v / 1000)}K';
    }
    return _numberFormat.format(v);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary Banner
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final int activeCount;
  final double totalMonthly;
  final bool hasLocalCurrency;
  final bool isLoadingCurrency;
  final String Function(double) getLocalEquivalent;
  final String localCurrencyCode;
  final String localCountryFlag;

  const _SummaryBanner({
    required this.activeCount,
    required this.totalMonthly,
    required this.hasLocalCurrency,
    required this.isLoadingCurrency,
    required this.getLocalEquivalent,
    required this.localCurrencyCode,
    required this.localCountryFlag,
  });

  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF056B2A), Color(0xFF033D18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF045F25).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.rotate, size: 32, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Impact',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Currency.symbol}${_numberFormat.format(totalMonthly)}/month',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // Local equivalent
                if (hasLocalCurrency && !isLoadingCurrency) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (localCountryFlag.isNotEmpty) ...[
                        Text(
                          localCountryFlag,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '≈ ${getLocalEquivalent(totalMonthly)} $localCurrencyCode/month',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'across $activeCount active campaign${activeCount == 1 ? "" : "s"}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Subscription Card
// ─────────────────────────────────────────────────────────────────────────────

class _SubCard extends StatelessWidget {
  final CampaignSubscription sub;
  final AltCampaignController ctrl;
  final bool hasLocalCurrency;
  final bool isLoadingCurrency;
  final String Function(double) getLocalEquivalent;
  final String localCurrencyCode;
  final String localCountryFlag;
  final VoidCallback? onCancel;
  final VoidCallback? onReactivate;

  const _SubCard({
    required this.sub,
    required this.ctrl,
    required this.hasLocalCurrency,
    required this.isLoadingCurrency,
    required this.getLocalEquivalent,
    required this.localCurrencyCode,
    required this.localCountryFlag,
    this.onCancel,
    this.onReactivate,
  });

  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  @override
  Widget build(BuildContext context) {
    final isActive = sub.isActive;
    final isPaused = sub.status == 'paused';
    final isCancelled = sub.status == 'cancelled';

    final statusColor = isActive
        ? const Color(0xFF045F25)
        : isPaused
        ? Colors.orange
        : Colors.grey.shade400;

    final statusLabel = isActive
        ? '● Active'
        : isPaused
        ? '⚠ Paused'
        : '✕ Cancelled';

    final nextDate = isActive
        ? '${sub.nextChargeDate.day}/${sub.nextChargeDate.month}/${sub.nextChargeDate.year}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isActive
              ? const Color(0xFF045F25).withOpacity(0.12)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // ── Top row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF045F25).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      isActive
                          ? FontAwesomeIcons.rotate
                          : FontAwesomeIcons.pause,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Title + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.campaignTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${Currency.symbol}${_numberFormat.format(sub.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isActive
                            ? const Color(0xFF045F25)
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      '/month',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                    // Local equivalent
                    if (hasLocalCurrency && !isLoadingCurrency) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (localCountryFlag.isNotEmpty) ...[
                            Text(
                              localCountryFlag,
                              style: const TextStyle(fontSize: 8),
                            ),
                            const SizedBox(width: 2),
                          ],
                          Text(
                            '≈ ${getLocalEquivalent(sub.amount)}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isActive
                                  ? const Color(0xFF045F25).withOpacity(0.6)
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(height: 1, color: Colors.grey.withOpacity(0.08)),

          // ── Bottom row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                // Meta info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nextDate != null)
                        _MetaRow(
                          icon: Icons.calendar_today,
                          text: 'Next charge: $nextDate',
                          color: Colors.blueGrey,
                        ),
                      if (sub.lastChargedAt != null)
                        _MetaRow(
                          icon: Icons.check_circle_outline,
                          text:
                              'Last charged: '
                              '${sub.lastChargedAt!.day}/'
                              '${sub.lastChargedAt!.month}/'
                              '${sub.lastChargedAt!.year}',
                          color: Colors.grey.shade500,
                        ),
                      if (sub.failureCount > 0 && !isActive)
                        _MetaRow(
                          icon: Icons.warning_amber_outlined,
                          text: sub.failureReason ?? 'Charge failed',
                          color: Colors.orange,
                        ),
                      if (sub.cancelledAt != null)
                        _MetaRow(
                          icon: Icons.cancel_outlined,
                          text:
                              'Cancelled: '
                              '${sub.cancelledAt!.day}/'
                              '${sub.cancelledAt!.month}/'
                              '${sub.cancelledAt!.year}',
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),

                // Action button
                if (isActive && onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red, width: 0.8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (!isActive && onReactivate != null)
                  TextButton(
                    onPressed: onReactivate,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF045F25),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFF045F25),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Reactivate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
//  Meta Row
// ─────────────────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetaRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF045F25).withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.rotate,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Monthly Donations',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a monthly donation to your favourite athlete campaign '
              'to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF045F25),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Browse Campaigns'),
            ),
          ],
        ),
      ),
    );
  }
}
