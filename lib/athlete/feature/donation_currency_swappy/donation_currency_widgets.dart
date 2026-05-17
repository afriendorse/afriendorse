// lib/athlete/feature/donation_currency_swappy/donation_currency_widgets.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Controller Bootstrap
//  Ensures at least one currency controller is alive when donation
//  screens open — even if the wallet screen was never visited.
// ─────────────────────────────────────────────────────────────────────────────

/// Call this in initState() of every donation screen/sheet
void ensureDonationCurrencyReady() {
  // Ensure CurrencyService singleton is up
  if (!Get.isRegistered<CurrencyService>()) {
    Get.put<CurrencyService>(CurrencyService(), permanent: true);
  }

  // If either controller already exists and has resolved a currency — done
  if (Get.isRegistered<AthleteCurrencyController>()) {
    final c = Get.find<AthleteCurrencyController>();
    // Re-init if it resolved to USD fallback (might have failed first time)
    if (!c.isLoadingRates.value && c.hasLocalCurrency) return;
  }

  if (Get.isRegistered<CurrencyController>()) {
    final c = Get.find<CurrencyController>();
    if (!c.isLoadingRates.value && c.hasLocalCurrency) return;
  }

  // Register based on which user session is active
  // Athlete session takes priority
  try {
    // ignore: avoid_dynamic_calls
    Get.find(tag: 'athlete_profile_controller');
    if (!Get.isRegistered<AthleteCurrencyController>()) {
      Get.put<AthleteCurrencyController>(
        AthleteCurrencyController(),
        permanent: false,
      );
    }
    return;
  } catch (_) {}

  // Fan/brand session
  if (!Get.isRegistered<CurrencyController>()) {
    Get.put<CurrencyController>(CurrencyController(), permanent: false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Internal resolver — returns the active controller's live values
//  wrapped in Obx-compatible Rx reads
// ─────────────────────────────────────────────────────────────────────────────

bool _athleteCtrlActive() => Get.isRegistered<AthleteCurrencyController>();
bool _fanBrandCtrlActive() => Get.isRegistered<CurrencyController>();

/// Must be called inside Obx() to be reactive
String _getLocalEquivalent(double usdAmount) {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().getLocalEquivalent(usdAmount);
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().getLocalEquivalent(usdAmount);
  }
  return '';
}

bool _hasLocalCurrency() {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().hasLocalCurrency;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().hasLocalCurrency;
  }
  return false;
}

bool _isLoading() {
  if (_athleteCtrlActive()) {
    // Reading .value inside Obx makes it reactive
    return Get.find<AthleteCurrencyController>().isLoadingRates.value;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().isLoadingRates.value;
  }
  return false;
}

String _flag() {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().localCountryFlag.value;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().localCountryFlag.value;
  }
  return '';
}

String _code() {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().localCurrencyCode.value;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().localCurrencyCode.value;
  }
  return 'USD';
}

String _rateLabel() {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().rateLabel;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().rateLabel;
  }
  return '';
}

bool _showLocal() {
  if (_athleteCtrlActive()) {
    return Get.find<AthleteCurrencyController>().showLocalCurrency.value;
  }
  if (_fanBrandCtrlActive()) {
    return Get.find<CurrencyController>().showLocalCurrency.value;
  }
  return false;
}

Future<void> _toggle() async {
  if (_athleteCtrlActive()) {
    await Get.find<AthleteCurrencyController>().toggleCurrencyDisplay();
    return;
  }
  if (_fanBrandCtrlActive()) {
    await Get.find<CurrencyController>().toggleCurrencyDisplay();
  }
}

Future<void> _refresh() async {
  if (_athleteCtrlActive()) {
    await Get.find<AthleteCurrencyController>().refreshRates();
    return;
  }
  if (_fanBrandCtrlActive()) {
    await Get.find<CurrencyController>().refreshRates();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  1. DonationLocalAmountHint
//  Shows live local equivalent below the amount input as user types
// ─────────────────────────────────────────────────────────────────────────────

class DonationLocalAmountHint extends StatelessWidget {
  final double usdAmount;
  final Color? textColor;

  const DonationLocalAmountHint({
    super.key,
    required this.usdAmount,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Obx makes this reactive to controller state changes
    return Obx(() {
      // Touch reactive fields to subscribe
      final loading = _isLoading();
      final hasLocal = _hasLocalCurrency();

      if (loading || !hasLocal || usdAmount <= 0) {
        return const SizedBox.shrink();
      }

      final local = _getLocalEquivalent(usdAmount);
      final flag = _flag();
      final code = _code();

      if (local.isEmpty) return const SizedBox.shrink();

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          key: ValueKey('$usdAmount-$code'),
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
                  color: textColor ?? Colors.green[700],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                code,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: (textColor ?? Colors.green[700])?.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2. DonationQuickChipWithLocal
//  Quick amount chip that shows local equivalent below the USD label
// ─────────────────────────────────────────────────────────────────────────────

class DonationQuickChipWithLocal extends StatelessWidget {
  final double usdAmount;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final String displayLabel;

  const DonationQuickChipWithLocal({
    super.key,
    required this.usdAmount,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.displayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to reactive fields
      final loading = _isLoading();
      final hasLocal = _hasLocalCurrency();
      final localAmount = (!loading && hasLocal)
          ? _getLocalEquivalent(usdAmount)
          : null;

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: localAmount != null ? 6 : 9,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : activeColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? activeColor : activeColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // USD label (primary)
              Text(
                displayLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : activeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),

              // Local equivalent (secondary — only when loaded)
              if (localAmount != null && localAmount.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  localAmount,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white.withOpacity(0.78)
                        : activeColor.withOpacity(0.65),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3. DonationCurrencyStrip
//  Full strip: local equivalent + toggle + refresh + rate label
//  Used in payment method sheets (bottom sheets)
// ─────────────────────────────────────────────────────────────────────────────

class DonationCurrencyStrip extends StatelessWidget {
  final double usdAmount;
  final bool isDark;

  const DonationCurrencyStrip({
    super.key,
    required this.usdAmount,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to all reactive fields
      final loading = _isLoading();
      final hasLocal = _hasLocalCurrency();

      // Shimmer while loading
      if (loading) return _DonationStripShimmer(isDark: isDark);

      // Nothing to show for USD users
      if (!hasLocal) return const SizedBox.shrink();

      final localAmount = _getLocalEquivalent(usdAmount);
      if (localAmount.isEmpty) return const SizedBox.shrink();

      final flag = _flag();
      final code = _code();
      final rateLabel = _rateLabel();
      final showLocal = _showLocal();

      final bgColor = isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.06);
      final borderColor = isDark
          ? Colors.white.withOpacity(0.18)
          : Colors.grey.withOpacity(0.18);
      final textColor = isDark ? Colors.white : Colors.black87;
      final subtleColor = isDark
          ? Colors.white.withOpacity(0.5)
          : Colors.black.withOpacity(0.4);

      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // ── Flag + amounts ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: flag + code + live dot
                  Row(
                    children: [
                      if (flag.isNotEmpty) ...[
                        Text(flag, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '$code Equivalent',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _DonationPulseDot(),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Animated local amount
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      key: ValueKey(localAmount),
                      localAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),

                  // Rate label
                  if (rateLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      rateLabel,
                      style: TextStyle(fontSize: 10, color: subtleColor),
                    ),
                  ],
                ],
              ),
            ),

            // ── Toggle + Refresh ───────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle USD ⇄ Local
                GestureDetector(
                  onTap: _toggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            key: ValueKey(showLocal),
                            showLocal ? '$code → USD' : 'USD → $code',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 12,
                          color: textColor.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Refresh
                GestureDetector(
                  onTap: _refresh,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: subtleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  4. DonationSuccessAmountDisplay
//  USD primary + local equivalent in success dialog
// ─────────────────────────────────────────────────────────────────────────────

class DonationSuccessAmountDisplay extends StatelessWidget {
  final double usdAmount;
  final Color primaryColor;

  const DonationSuccessAmountDisplay({
    super.key,
    required this.usdAmount,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = _isLoading();
      final hasLocal = _hasLocalCurrency();
      final localAmount = (!loading && hasLocal)
          ? _getLocalEquivalent(usdAmount)
          : null;
      final flag = _flag();
      final code = _code();

      return Column(
        children: [
          // USD amount (always shown, primary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '\$${usdAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Local equivalent (shown when available)
          if (localAmount != null && localAmount.isNotEmpty) ...[
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey(localAmount),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (flag.isNotEmpty) ...[
                    Text(flag, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    '≈ $localAmount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  5. DonationWalletBalanceDisplay
//  Shows local equivalent of wallet balance in payment sheets
// ─────────────────────────────────────────────────────────────────────────────

class DonationWalletBalanceDisplay extends StatelessWidget {
  final double walletBalance;
  final double donationAmount;
  final bool hasEnoughBalance;

  const DonationWalletBalanceDisplay({
    super.key,
    required this.walletBalance,
    required this.donationAmount,
    required this.hasEnoughBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = _isLoading();
      final hasLocal = _hasLocalCurrency();

      if (loading || !hasLocal) return const SizedBox.shrink();

      final localBalance = _getLocalEquivalent(walletBalance);
      if (localBalance.isEmpty) return const SizedBox.shrink();

      final shortfall = donationAmount - walletBalance;
      final localShortfall = shortfall > 0
          ? _getLocalEquivalent(shortfall)
          : null;
      final flag = _flag();
      final code = _code();

      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasEnoughBalance
              ? Colors.green.withOpacity(0.06)
              : Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasEnoughBalance
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag.isNotEmpty) ...[
              Text(flag, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                hasEnoughBalance
                    ? '≈ $localBalance $code available'
                    : localShortfall != null
                    ? 'Need ≈ $localShortfall $code more'
                    : '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasEnoughBalance ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Strip Shimmer (loading state)
// ─────────────────────────────────────────────────────────────────────────────

class _DonationStripShimmer extends StatefulWidget {
  final bool isDark;
  const _DonationStripShimmer({required this.isDark});

  @override
  State<_DonationStripShimmer> createState() => _DonationStripShimmerState();
}

class _DonationStripShimmerState extends State<_DonationStripShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, __) {
        final opacity = widget.isDark
            ? 0.1 + _anim.value * 0.15
            : 0.04 + _anim.value * 0.07;

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: (widget.isDark ? Colors.white : Colors.grey).withOpacity(
              opacity * 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (widget.isDark ? Colors.white : Colors.grey).withOpacity(
                opacity,
              ),
            ),
          ),
          child: Row(
            children: [
              // Circle
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.isDark ? Colors.white : Colors.grey)
                      .withOpacity(opacity * 2),
                ),
              ),
              const SizedBox(width: 10),
              // Lines
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: (widget.isDark ? Colors.white : Colors.grey)
                          .withOpacity(opacity * 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 80,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (widget.isDark ? Colors.white : Colors.grey)
                          .withOpacity(opacity * 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pulse Dot (live indicator)
// ─────────────────────────────────────────────────────────────────────────────

class _DonationPulseDot extends StatefulWidget {
  @override
  State<_DonationPulseDot> createState() => _DonationPulseDotState();
}

class _DonationPulseDotState extends State<_DonationPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            Colors.greenAccent.withOpacity(0.35),
            Colors.greenAccent,
            _ctrl.value,
          ),
        ),
      ),
    );
  }
}
