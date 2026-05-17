// lib/athlete/feature/wallet/widgets/wallet_balance_card.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class WalletBalanceCard extends StatelessWidget {
  final double availableBalance;
  final double totalEarned;
  final double pendingBalance;
  final VoidCallback onWithdraw;

  const WalletBalanceCard({
    super.key,
    required this.availableBalance,
    required this.totalEarned,
    required this.pendingBalance,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // ── Main Balance Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF056B2A), Color(0xFF033D18)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF045F25).withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Label row ────────────────────────────────────────
                Row(
                  children: [
                    _BalancePill(),
                    const Spacer(),
                    // Card chip decoration
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white38,
                        size: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Primary balance amount (USD or Local) ─────────────
                _PrimaryBalanceAmount(availableBalance: availableBalance),

                const SizedBox(height: 8),

                // ── Currency Equivalent Strip ─────────────────────────
                _CurrencyEquivalentStrip(usdAmount: availableBalance),

                const SizedBox(height: 24),

                // ── Stats row ─────────────────────────────────────────
                _StatsRow(
                  totalEarned: totalEarned,
                  pendingBalance: pendingBalance,
                ),

                const SizedBox(height: 24),

                // ── Withdraw button ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: availableBalance > 0 ? onWithdraw : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF045F25),
                      disabledBackgroundColor: Colors.white24,
                      disabledForegroundColor: Colors.white38,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                    label: Text(
                      availableBalance > 0
                          ? 'Withdraw Funds'
                          : 'No Balance Available',
                      style: robotoBold.copyWith(
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
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

// ── Balance Pill ──────────────────────────────────────────────────────────────

class _BalancePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final showLocal = ctrl.showLocalCurrency.value;
      final flag = ctrl.localCountryFlag.value;
      final code = ctrl.localCurrencyCode.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live pulse dot
            _LivePulseDot(isRefreshing: ctrl.isRefreshing.value),
            const SizedBox(width: 6),
            Text(
              showLocal && ctrl.hasLocalCurrency
                  ? '$flag $code Balance'
                  : 'Available Balance',
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Primary Balance Amount ────────────────────────────────────────────────────

class _PrimaryBalanceAmount extends StatelessWidget {
  final double availableBalance;
  const _PrimaryBalanceAmount({required this.availableBalance});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final showLocal = ctrl.showLocalCurrency.value;
      final isToggling = ctrl.isToggling.value;

      final String primaryAmount = showLocal && ctrl.hasLocalCurrency
          ? ctrl.getLocalEquivalent(availableBalance)
          : PriceConverter.convertPrice(availableBalance);

      final String secondaryAmount = showLocal && ctrl.hasLocalCurrency
          ? PriceConverter.convertPrice(availableBalance)
          : ctrl.hasLocalCurrency
          ? ctrl.getLocalEquivalent(availableBalance)
          : '';

      final String secondaryLabel = showLocal
          ? '≈ $secondaryAmount USD'
          : '≈ $secondaryAmount ${ctrl.localCurrencyCode.value}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated primary amount
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: isToggling
                ? const SizedBox(key: ValueKey('toggling'), height: 50)
                : FittedBox(
                    key: ValueKey('$primaryAmount-$showLocal'),
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      primaryAmount,
                      style: robotoBold.copyWith(
                        fontSize: 42,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                  ),
          ),

          // Secondary (smaller, muted)
          if (secondaryAmount.isNotEmpty && !isToggling) ...[
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isToggling ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Text(
                secondaryLabel,
                style: robotoRegular.copyWith(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ── Currency Equivalent Strip ─────────────────────────────────────────────────

class _CurrencyEquivalentStrip extends StatelessWidget {
  final double usdAmount;
  const _CurrencyEquivalentStrip({required this.usdAmount});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();

      // Loading state
      if (ctrl.isLoadingRates.value) {
        return _buildShimmer();
      }

      // USD users — hide strip entirely
      if (!ctrl.hasLocalCurrency) return const SizedBox.shrink();

      final localAmount = ctrl.getLocalEquivalent(usdAmount);
      final flag = ctrl.localCountryFlag.value;
      final code = ctrl.localCurrencyCode.value;
      final rateLabel = ctrl.rateLabel;
      final showLocal = ctrl.showLocalCurrency.value;

      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            // Flag + amounts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: flag + code label
                  Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        '$code Equivalent',
                        style: robotoMedium.copyWith(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _LivePulseDot(isRefreshing: ctrl.isRefreshing.value),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Local amount (animated on toggle)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      key: ValueKey(localAmount),
                      localAmount,
                      style: robotoBold.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // Rate label
                  if (rateLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      rateLabel,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Controls column: toggle + refresh
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle button
                GestureDetector(
                  onTap: ctrl.toggleCurrencyDisplay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            key: ValueKey(showLocal),
                            showLocal ? '$code → USD' : 'USD → $code',
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: showLocal ? 0.0 : 1.0,
                            end: showLocal ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (_, value, __) => Transform.rotate(
                            angle: value * 3.14159,
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Refresh button
                GestureDetector(
                  onTap: ctrl.refreshRates,
                  child: ctrl.isRefreshing.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white38,
                          size: 14,
                        ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Circle shimmer
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 75,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final double totalEarned;
  final double pendingBalance;
  const _StatsRow({required this.totalEarned, required this.pendingBalance});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final showLocal = ctrl.showLocalCurrency.value;
      final hasLocal = ctrl.hasLocalCurrency;

      // When toggled to local, show local equivalent in chips
      final String earnedValue = showLocal && hasLocal
          ? ctrl.getLocalEquivalent(totalEarned)
          : PriceConverter.convertPrice(totalEarned);

      final String pendingValue = showLocal && hasLocal
          ? ctrl.getLocalEquivalent(pendingBalance)
          : PriceConverter.convertPrice(pendingBalance);

      return Row(
        children: [
          _StatChip(
            label: 'Total Earned',
            value: earnedValue,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF4AE080),
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Pending Withdrawal',
            value: pendingValue,
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFFFC844),
          ),
        ],
      );
    });
  }
}

// ── Live Pulse Dot ────────────────────────────────────────────────────────────

class _LivePulseDot extends StatefulWidget {
  final bool isRefreshing;
  const _LivePulseDot({required this.isRefreshing});

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isRefreshing
              ? Colors.orange
              : Color.lerp(
                  const Color(0xFF4AE080).withOpacity(0.4),
                  const Color(0xFF4AE080),
                  _pulse.value,
                ),
        ),
      ),
    );
  }
}

// ── Stat Chip (unchanged but kept here for completeness) ──────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                      color: Colors.white54,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey(value),
                value,
                style: robotoBold.copyWith(
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
