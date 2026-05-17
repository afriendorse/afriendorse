// lib/athlete/feature/campaigns/screens/athlete_campaign_payment_sheet.dart

import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/service/campaign_currency_mixin.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AthleteCampaignPaymentSheet extends StatefulWidget {
  final CampaignModel campaign;
  final double amount;
  final VoidCallback onWalletPayment;
  final VoidCallback onOnlinePayment;

  const AthleteCampaignPaymentSheet({
    super.key,
    required this.campaign,
    required this.amount,
    required this.onWalletPayment,
    required this.onOnlinePayment,
  });

  @override
  State<AthleteCampaignPaymentSheet> createState() =>
      _AthleteCampaignPaymentSheetState();
}

class _AthleteCampaignPaymentSheetState
    extends State<AthleteCampaignPaymentSheet>
    with CampaignCurrencyMixin {
  double _spendableBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ensureCampaignCurrencyReady();
    _loadBalance();
    _waitForCurrency();
  }

  Future<void> _waitForCurrency() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() {});

    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() {});
  }

  Future<void> _loadBalance() async {
    try {
      final walletCtrl = Get.find<WalletController>();
      final balance = walletCtrl.mergedAvailableBalance;

      if (mounted) {
        setState(() {
          _spendableBalance = balance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AthleteCampaignPayment] Wallet load error: $e');
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _hasEnough => _spendableBalance >= widget.amount;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF045F25);
    final numberFormat = NumberFormat('#,##0.##');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 8,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag Handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.payment_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Payment Method',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Donating ${Currency.symbol}'
                      '${numberFormat.format(widget.amount)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),

                    // ✅ Local currency equivalent
                    Builder(
                      builder: (context) {
                        final showLocal =
                            hasLocalCurrency && !isLoadingCurrency;

                        if (!showLocal) {
                          return const SizedBox.shrink();
                        }

                        final localAmount = getLocalEquivalent(widget.amount);
                        if (localAmount.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              if (localCountryFlag.isNotEmpty) ...[
                                Text(
                                  localCountryFlag,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  '≈ $localAmount $localCurrencyCode',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: primary.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Wallet Option ────────────────────────────────────────────
          _isLoading
              ? _LoadingWalletTile(primary: primary)
              : _PaymentOptionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: _hasEnough ? primary : Colors.grey[400]!,
                  title: 'Pay with Wallet',
                  subtitle: _hasEnough
                      ? 'Balance: ${Currency.symbol}'
                            '${numberFormat.format(_spendableBalance)}'
                      : 'Insufficient — ${Currency.symbol}'
                            '${numberFormat.format(_spendableBalance)} available',
                  localEquivalent: hasLocalCurrency && !isLoadingCurrency
                      ? getLocalEquivalent(_spendableBalance)
                      : null,
                  localCurrencyCode: localCurrencyCode,
                  localCountryFlag: localCountryFlag,
                  trailing: _hasEnough
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'Instant',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                  isDisabled: !_hasEnough,
                  onTap: _hasEnough
                      ? () {
                          Get.back();
                          widget.onWalletPayment();
                        }
                      : null,
                ),

          const SizedBox(height: 12),

          // ── Online Payment ───────────────────────────────────────────
          _PaymentOptionTile(
            icon: Icons.credit_card_rounded,
            iconColor: primary,
            title: 'Pay Online',
            subtitle: 'Debit card, bank transfer & more',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 11,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Secure',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Get.back();
              widget.onOnlinePayment();
            },
          ),

          // ── Insufficient Balance Nudge ───────────────────────────────
          if (!_isLoading && !_hasEnough) ...[
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final shortfall = widget.amount - _spendableBalance;
                final showLocalShortfall =
                    hasLocalCurrency && !isLoadingCurrency;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You need ${Currency.symbol}'
                              '${numberFormat.format(shortfall)}'
                              ' more to use your wallet.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[900],
                              ),
                            ),
                            // Local equivalent of shortfall
                            if (showLocalShortfall) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (localCountryFlag.isNotEmpty) ...[
                                    Text(
                                      localCountryFlag,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Text(
                                    '≈ ${getLocalEquivalent(shortfall)} $localCurrencyCode',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(RouteHelper.getWalletRoute());
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Top Up',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          // ── Exchange Rate Strip ──────────────────────────────────────
          Builder(
            builder: (context) {
              final showRate =
                  hasLocalCurrency &&
                  !isLoadingCurrency &&
                  rateLabel.isNotEmpty;

              if (!showRate) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primary.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12,
                        color: primary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          rateLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Payment Option Tile
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? localEquivalent;
  final String? localCurrencyCode;
  final String? localCountryFlag;
  final Widget? trailing;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.localEquivalent,
    this.localCurrencyCode,
    this.localCountryFlag,
    this.trailing,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[200]!
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDisabled ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    // Local equivalent subtitle
                    if (localEquivalent != null &&
                        localCurrencyCode != null &&
                        localEquivalent!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (localCountryFlag != null &&
                              localCountryFlag!.isNotEmpty) ...[
                            Text(
                              localCountryFlag!,
                              style: const TextStyle(fontSize: 9),
                            ),
                            const SizedBox(width: 3),
                          ],
                          Flexible(
                            child: Text(
                              '≈ $localEquivalent $localCurrencyCode',
                              style: TextStyle(
                                fontSize: 10,
                                color: iconColor.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (!isDisabled) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading Wallet Tile
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingWalletTile extends StatelessWidget {
  final Color primary;
  const _LoadingWalletTile({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: primary.withOpacity(0.5),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay with Wallet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Loading balance...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
}
