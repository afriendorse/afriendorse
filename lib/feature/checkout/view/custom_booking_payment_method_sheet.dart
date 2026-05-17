import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingPaymentMethodSheet extends StatefulWidget {
  final double amount;
  final VoidCallback onWalletPayment;
  final VoidCallback onOnlinePayment;

  const BookingPaymentMethodSheet({
    super.key,
    required this.amount,
    required this.onWalletPayment,
    required this.onOnlinePayment,
  });

  @override
  State<BookingPaymentMethodSheet> createState() =>
      _BookingPaymentMethodSheetState();
}

class _BookingPaymentMethodSheetState extends State<BookingPaymentMethodSheet> {
  double _walletBalance = 0.0;
  bool _isLoadingBalance = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // CartController already holds the wallet balance —
    // no extra network call needed.
    final balance = Get.find<CartController>().walletBalance.toDouble();
    if (mounted) {
      setState(() {
        _walletBalance = balance;
        _isLoadingBalance = false;
      });
    }
  }

  bool get _hasEnough => _walletBalance >= widget.amount;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fmt = NumberFormat('#,##0.##');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // or use Theme cardColor
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
          // ── Drag handle ──────────────────────────────────────────
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

          // ── Header ───────────────────────────────────────────────
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
                    Text(
                      'choose_payment_method'.tr,
                      style: robotoBold.copyWith(fontSize: 17),
                    ),
                    Text(
                      '${'booking_total'.tr}: ${PriceConverter.convertPrice(widget.amount)}',
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Wallet tile ──────────────────────────────────────────
          _isLoadingBalance
              ? _LoadingWalletTile(primary: primary)
              : _PaymentTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: _hasEnough ? primary : Colors.grey[400]!,
                  title: 'pay_via_wallet'.tr,
                  subtitle: _hasEnough
                      ? '${'balance'.tr}: ${PriceConverter.convertPrice(_walletBalance)}'
                      : '${'insufficient'.tr} — ${PriceConverter.convertPrice(_walletBalance)} ${'available'.tr}',
                  trailing: _hasEnough
                      ? _badge(
                          'instant'.tr,
                          Colors.green[50]!,
                          Colors.green[200]!,
                          Colors.green[700]!,
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

          // ── Online payment tile ──────────────────────────────────
          _PaymentTile(
            icon: Icons.credit_card_rounded,
            iconColor: primary,
            title: 'pay_online'.tr,
            subtitle: 'debit_card_bank_transfer'.tr,
            trailing: _badge(
              'secure'.tr,
              Colors.blue[50]!,
              Colors.blue[200]!,
              Colors.blue[700]!,
              leadingIcon: Icons.shield_outlined,
            ),
            onTap: () {
              Get.back();
              widget.onOnlinePayment();
            },
          ),

          // ── Insufficient balance nudge ────────────────────────────
          if (!_isLoadingBalance && !_hasEnough) ...[
            const SizedBox(height: 16),
            Container(
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
                      '${'you_need'.tr} ${PriceConverter.convertPrice(widget.amount - _walletBalance)} ${'more_to_use_wallet'.tr}.',
                      style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(RouteHelper.getMyWalletScreen());
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
                      'top_up'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _badge(
    String label,
    Color bg,
    Color border,
    Color text, {
    IconData? leadingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 11, color: text),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading wallet tile ───────────────────────────────────────────────────────

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
                  'pay_via_wallet'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
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
                      'loading_balance'.tr,
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

// ── Reusable payment tile ─────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PaymentTile({
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
                      style: robotoMedium.copyWith(
                        fontSize: 15,
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
