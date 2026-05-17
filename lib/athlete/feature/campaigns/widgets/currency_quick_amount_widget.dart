// lib/athlete/feature/campaigns/widgets/campaign_donation_widgets.dart

import 'package:afriendorse/athlete/feature/campaigns/service/campaign_currency_mixin.dart';
import 'package:flutter/material.dart';

/// Shows live local currency equivalent below amount input field
class CampaignDonationAmountHint extends StatefulWidget {
  final double usdAmount;
  final Color? textColor;

  const CampaignDonationAmountHint({
    super.key,
    required this.usdAmount,
    this.textColor,
  });

  @override
  State<CampaignDonationAmountHint> createState() =>
      _CampaignDonationAmountHintState();
}

class _CampaignDonationAmountHintState extends State<CampaignDonationAmountHint>
    with CampaignCurrencyMixin {
  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    // Rebuild every 500ms to catch currency loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
        if (isLoadingCurrency) {
          _startPeriodicRefresh(); // Keep checking until loaded
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingCurrency || !hasLocalCurrency || widget.usdAmount <= 0) {
      return const SizedBox.shrink();
    }

    final local = getLocalEquivalent(widget.usdAmount);
    final flag = localCountryFlag;
    final code = localCurrencyCode;

    if (local.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey('${widget.usdAmount}-$code'),
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (flag.isNotEmpty) ...[
              Text(flag, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
            ],
            Text(
              '≈ $local',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: widget.textColor ?? Colors.green[700],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              code,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: (widget.textColor ?? Colors.green[700])?.withOpacity(
                  0.65,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick amount chip with local currency shown below USD
class CampaignQuickAmountChip extends StatefulWidget {
  final double usdAmount;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final String displayLabel;

  const CampaignQuickAmountChip({
    super.key,
    required this.usdAmount,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.displayLabel,
  });

  @override
  State<CampaignQuickAmountChip> createState() =>
      _CampaignQuickAmountChipState();
}

class _CampaignQuickAmountChipState extends State<CampaignQuickAmountChip>
    with CampaignCurrencyMixin {
  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
        if (isLoadingCurrency) {
          _startPeriodicRefresh();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showLocal = hasLocalCurrency && !isLoadingCurrency;
    final localAmount = showLocal ? getLocalEquivalent(widget.usdAmount) : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: localAmount != null && localAmount.isNotEmpty ? 6 : 9,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.activeColor
              : widget.activeColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: widget.isSelected
                ? widget.activeColor
                : widget.activeColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // USD label (primary)
            Text(
              widget.displayLabel,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : widget.activeColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),

            // Local equivalent (secondary)
            if (localAmount != null && localAmount.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                localAmount,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.78)
                      : widget.activeColor.withOpacity(0.65),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact exchange rate info strip
class CampaignExchangeRateStrip extends StatefulWidget {
  final Color? textColor;
  final Color? backgroundColor;

  const CampaignExchangeRateStrip({
    super.key,
    this.textColor,
    this.backgroundColor,
  });

  @override
  State<CampaignExchangeRateStrip> createState() =>
      _CampaignExchangeRateStripState();
}

class _CampaignExchangeRateStripState extends State<CampaignExchangeRateStrip>
    with CampaignCurrencyMixin {
  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {});
        if (isLoadingCurrency) {
          _startPeriodicRefresh();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingCurrency || !hasLocalCurrency || rateLabel.isEmpty) {
      return const SizedBox.shrink();
    }

    final flag = localCountryFlag;
    final rate = rateLabel;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              (widget.backgroundColor ??
              Theme.of(context).colorScheme.primary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (flag.isNotEmpty) ...[
            Text(flag, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 5),
          ],
          Icon(
            Icons.info_outline,
            size: 11,
            color:
                widget.textColor ??
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              rate,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color:
                    widget.textColor ??
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
