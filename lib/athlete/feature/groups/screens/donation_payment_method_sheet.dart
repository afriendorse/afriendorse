// lib/athlete/feature/groups/screens/donation_payment_method_sheet.dart

import 'package:afriendorse/athlete/feature/donation_currency_swappy/donation_currency_widgets.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/feature/wallet/controller/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DonationPaymentMethodSheet extends StatefulWidget {
  final String groupId;
  final double amount;
  final GroupController controller;

  const DonationPaymentMethodSheet({
    super.key,
    required this.groupId,
    required this.amount,
    required this.controller,
  });

  @override
  State<DonationPaymentMethodSheet> createState() =>
      _DonationPaymentMethodSheetState();
}

class _DonationPaymentMethodSheetState
    extends State<DonationPaymentMethodSheet> {
  double _walletBalance = 0.0;
  bool _isLoadingBalance = true;
  bool _walletAvailable = false;

  final _numberFormat = NumberFormat('#,##0.##');

  @override
  void initState() {
    super.initState();
    ensureDonationCurrencyReady(); // ← ADD THIS
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final walletController = Get.find<WalletController>();
      _walletAvailable = true;
      final balance = await walletController.getWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalance = balance;
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ WalletController NOT found: $e');
      if (mounted) {
        setState(() {
          _walletAvailable = false;
          _isLoadingBalance = false;
        });
      }
    }
  }

  bool get _hasEnoughBalance => _walletBalance >= widget.amount;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
          // Drag handle
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

          // ── Header ──────────────────────────────────────────────────────
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
                      'Donating \$${_numberFormat.format(widget.amount)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Currency equivalent strip ─────────────────────────────────────
          DonationCurrencyStrip(usdAmount: widget.amount, isDark: false),

          const SizedBox(height: 20),

          // ── Wallet option ─────────────────────────────────────────────────
          if (_walletAvailable) ...[
            _isLoadingBalance
                ? _LoadingWalletTile(primary: primary)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PaymentOptionTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: _hasEnoughBalance
                            ? primary
                            : Colors.grey[400]!,
                        title: 'Pay with Wallet',
                        subtitle: _hasEnoughBalance
                            ? 'Balance: \$${_numberFormat.format(_walletBalance)}'
                            : 'Insufficient — \$${_numberFormat.format(_walletBalance)} available',
                        trailing: _hasEnoughBalance
                            ? _InstantBadge()
                            : Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                        isDisabled: !_hasEnoughBalance,
                        onTap: _hasEnoughBalance
                            ? () {
                                Get.back();
                                widget.controller.processDonation(
                                  widget.groupId,
                                  paymentMethod: 'wallet',
                                );
                              }
                            : null,
                      ),

                      // Local wallet balance equivalent
                      DonationWalletBalanceDisplay(
                        walletBalance: _walletBalance,
                        donationAmount: widget.amount,
                        hasEnoughBalance: _hasEnoughBalance,
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
          ],

          // ── Online payment option ─────────────────────────────────────────
          _PaymentOptionTile(
            icon: Icons.credit_card_rounded,
            iconColor: primary,
            title: 'Pay Online',
            subtitle: 'Debit card, bank transfer & more',
            trailing: _SecureBadge(),
            onTap: () {
              Get.back();
              widget.controller.processDonation(
                widget.groupId,
                paymentMethod: 'online',
              );
            },
          ),

          // ── Insufficient balance nudge ─────────────────────────────────────
          if (_walletAvailable && !_isLoadingBalance && !_hasEnoughBalance) ...[
            const SizedBox(height: 16),
            _InsufficientNudge(shortfall: widget.amount - _walletBalance),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
// ─── Loading Wallet Tile ──────────────────────────────────────────────────────

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

// ─── Reusable tile ────────────────────────────────────────────────────────────

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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

// ─── Instant Badge ────────────────────────────────────────────────────────────

class _InstantBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
  }
}

// ─── Secure Badge ─────────────────────────────────────────────────────────────

class _SecureBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 11, color: Colors.blue[700]),
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
    );
  }
}

// ─── Insufficient Balance Nudge ───────────────────────────────────────────────

class _InsufficientNudge extends StatelessWidget {
  final double shortfall;
  final _numberFormat = NumberFormat('#,##0.##');

  _InsufficientNudge({required this.shortfall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.amber[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You need \$${_numberFormat.format(shortfall)} more to use your wallet.',
              style: TextStyle(fontSize: 12, color: Colors.amber[900]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.getWalletRoute());
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  }
}
