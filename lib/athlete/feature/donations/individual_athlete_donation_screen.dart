// lib/athlete/feature/donations/individual_athlete_donation_screen.dart

import 'package:afriendorse/athlete/common/widgets/custom_snackbar.dart';
import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/donation_currency_swappy/donation_currency_widgets.dart';
import 'package:afriendorse/athlete/feature/donations/individual_donation_payment_method_sheet.dart';
import 'package:afriendorse/athlete/feature/donations/individual_donation_recorder.dart';
import 'package:afriendorse/athlete/feature/donations/paystack_checkout_webview.dart';
import 'package:afriendorse/athlete/feature/donations/paystack_hosted_payment_service.dart';
import 'package:afriendorse/feature/fan_deals/fan_deal_request_controller.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/auth/controller/auth_controller.dart';
import 'package:afriendorse/feature/profile/controller/user_controller.dart';
import 'package:intl/intl.dart';

class IndividualAthleteDonationScreen extends StatefulWidget {
  final String athleteEmailLower;
  final String athleteDisplayName;
  final String? athleteAvatarUrl;

  const IndividualAthleteDonationScreen({
    super.key,
    required this.athleteEmailLower,
    required this.athleteDisplayName,
    this.athleteAvatarUrl,
  });

  @override
  State<IndividualAthleteDonationScreen> createState() =>
      _IndividualAthleteDonationScreenState();
}

class _IndividualAthleteDonationScreenState
    extends State<IndividualAthleteDonationScreen> {
  static const Color _kGreen = Color(0xFF045F25);

  final _displayAmountCtrl = TextEditingController();
  final _rawAmountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _numberFormat = NumberFormat('#,##0.##');

  bool _anonymous = false;
  bool _loading = false;
  bool _isTextFieldEmpty = true;
  String _mysqlAthleteId = '';
  double _currentRawAmount = 0.0;

  final _quickAmounts = [5.0, 10.0, 25.0, 50.0, 100.0];

  @override
  void initState() {
    super.initState();
    ensureDonationCurrencyReady(); // ← ADD THIS
    _resolveMysqlAthleteId();
  }

  @override
  void dispose() {
    _displayAmountCtrl.dispose();
    _rawAmountCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    String raw = value.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = raw.split('.');
    if (parts.length > 2) raw = '${parts[0]}.${parts.sublist(1).join('')}';

    _rawAmountCtrl.text = raw;

    if (raw.isEmpty) {
      _displayAmountCtrl.text = '';
      setState(() {
        _isTextFieldEmpty = true;
        _currentRawAmount = 0.0;
      });
    } else {
      final number = double.tryParse(raw) ?? 0;
      final formatted = _numberFormat.format(number);
      _displayAmountCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() {
        _isTextFieldEmpty = false;
        _currentRawAmount = number;
      });
    }
  }

  void _setQuickAmount(double amount) {
    _rawAmountCtrl.text = amount.toString();
    final formatted = _numberFormat.format(amount);
    _displayAmountCtrl.text = formatted;
    setState(() {
      _isTextFieldEmpty = false;
      _currentRawAmount = amount;
    });
  }

  double? _getRawAmount() {
    final raw = _rawAmountCtrl.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _resolveMysqlAthleteId() async {
    final athlete = await AthleteFirestoreSyncService.getAthleteByEmail(
      widget.athleteEmailLower,
    );
    final mysqlId = (athlete?['mysqlAthleteId'] ?? '').toString().trim();
    if (mounted) setState(() => _mysqlAthleteId = mysqlId);
  }

  String _donorName() {
    final u = Get.find<UserController>().userInfoModel;
    final name = ('${u?.fName ?? ''} ${u?.lName ?? ''}').trim();
    if (name.isNotEmpty) return name;
    return (u?.email ?? 'Donor').toString();
  }

  String _donorType() {
    if (Get.isRegistered<FanDealRequestController>()) {
      return Get.find<FanDealRequestController>().currentUserType.value;
    }
    return 'user';
  }

  Future<void> _donate() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute());
      return;
    }

    if (widget.athleteEmailLower.trim().isEmpty) {
      showCustomSnackBar('Athlete email not found');
      return;
    }

    if (_mysqlAthleteId.isEmpty) {
      showCustomSnackBar('Unable to resolve athlete profile');
      return;
    }

    final amount = _getRawAmount();
    if (amount == null) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.black,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return;
    }
    if (amount <= 0) {
      showCustomSnackBar('Amount must be greater than zero');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IndividualDonationPaymentMethodSheet(
        amount: amount,
        onWalletPayment: () => _donateViaWallet(amount),
        onOnlinePayment: () => _donateViaFlutterwave(amount),
      ),
    );
  }

  Future<void> _donateViaWallet(double amount) async {
    setState(() => _loading = true);
    try {
      final walletController = Get.find<WalletController>();
      final success = await walletController.deductAndRefresh(
        amount: amount,
        purpose: 'individual_athlete_donation',
      );

      if (!success) {
        setState(() => _loading = false);
        Get.snackbar(
          'Payment Failed',
          'Wallet payment could not be processed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.red),
        );
        return;
      }

      final walletRef =
          'wallet_${_mysqlAthleteId}_${DateTime.now().millisecondsSinceEpoch}';

      await IndividualDonationRecorder.record(
        athleteEmailLower: widget.athleteEmailLower,
        mysqlAthleteId: _mysqlAthleteId,
        flutterwaveRef: walletRef,
        transactionId: walletRef,
        amount: amount,
        athleteNameOrTitle: 'Support ${widget.athleteDisplayName}',
        donorName: _donorName(),
        isAnonymous: _anonymous,
        message: _messageCtrl.text.trim().isEmpty
            ? null
            : _messageCtrl.text.trim(),
      );

      setState(() => _loading = false);
      _clearForm();
      Get.back();
      await Future.delayed(const Duration(milliseconds: 300));
      _showSuccessOverlay(amount);
    } catch (e) {
      setState(() => _loading = false);
      showCustomSnackBar('Wallet donation failed: $e');
    }
  }

  Future<void> _donateViaFlutterwave(double amount) async {
    setState(() => _loading = true);

    try {
      final donorEmail = (Get.find<UserController>().userInfoModel?.email ?? '')
          .trim();
      final txRef =
          'ind_${_mysqlAthleteId}_${DateTime.now().millisecondsSinceEpoch}';

      final init = await FlutterwaveHostedPaymentService.initialize(
        email: donorEmail.isNotEmpty ? donorEmail : 'support@afriendorse.app',
        customerName: _donorName(),
        amountUsd: amount,
        txRef: txRef,
        redirectUrl: 'https://afriendorse.app/flutterwave-callback',
        meta: {
          'type': 'individual_athlete_donation',
          'athleteEmailLower': widget.athleteEmailLower,
          'mysqlAthleteId': _mysqlAthleteId,
          'donorType': _donorType(),
          'anonymous': _anonymous,
        },
      );

      setState(() => _loading = false);

      final result = await Get.to<FlutterwaveResult?>(
        () => FlutterwaveCheckoutWebView(
          checkoutUrl: init.checkoutUrl,
          redirectUrlPrefix: 'https://afriendorse.app/flutterwave-callback',
        ),
      );

      if (result == null || !result.isSuccessful) {
        showCustomSnackBar('Payment cancelled');
        return;
      }

      setState(() => _loading = true);
      final transactionId = result.transactionId ?? '';

      final ok = await FlutterwaveHostedPaymentService.verify(
        transactionId: transactionId,
        expectedAmount: amount,
      );

      if (!ok) {
        setState(() => _loading = false);
        showCustomSnackBar('Payment not successful. Please try again.');
        return;
      }

      await IndividualDonationRecorder.record(
        athleteEmailLower: widget.athleteEmailLower,
        mysqlAthleteId: _mysqlAthleteId,
        flutterwaveRef: result.txRef ?? txRef,
        transactionId: transactionId,
        amount: amount,
        athleteNameOrTitle: 'Support ${widget.athleteDisplayName}',
        donorName: _donorName(),
        isAnonymous: _anonymous,
        message: _messageCtrl.text.trim().isEmpty
            ? null
            : _messageCtrl.text.trim(),
      );

      setState(() => _loading = false);
      _clearForm();
      Get.back();
      await Future.delayed(const Duration(milliseconds: 300));
      _showSuccessOverlay(amount);
    } catch (e) {
      setState(() => _loading = false);
      showCustomSnackBar('Donation failed: $e');
    }
  }

  void _clearForm() {
    _rawAmountCtrl.clear();
    _displayAmountCtrl.clear();
    _messageCtrl.clear();
    setState(() {
      _anonymous = false;
      _isTextFieldEmpty = true;
      _currentRawAmount = 0.0;
    });
  }

  void _showSuccessOverlay(double amount) {
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (_) => _DonationSuccessDialog(
        athleteName: widget.athleteDisplayName,
        amount: amount,
        anonymous: _anonymous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.athleteDisplayName.isNotEmpty
        ? widget.athleteDisplayName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Make a Donation',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Athlete card ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _kGreen.withOpacity(0.12),
                    backgroundImage: widget.athleteAvatarUrl?.isNotEmpty == true
                        ? NetworkImage(widget.athleteAvatarUrl!)
                        : null,
                    child: widget.athleteAvatarUrl?.isNotEmpty != true
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _kGreen,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.athleteDisplayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: _kGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Accepting donations',
                              style: TextStyle(
                                fontSize: 12,
                                color: _kGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: _kGreen, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Support',
                          style: TextStyle(
                            color: _kGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Quick amounts ─────────────────────────────────────────────
            const Text(
              'Quick amounts',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amt) {
                final isSelected = _rawAmountCtrl.text == amt.toString();
                return DonationQuickChipWithLocal(
                  usdAmount: amt,
                  isSelected: isSelected,
                  onTap: () => _setQuickAmount(amt),
                  activeColor: _kGreen,
                  displayLabel: '\$${_numberFormat.format(amt)}',
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── Custom amount input ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _isTextFieldEmpty ? Colors.grey[300]! : _kGreen,
                  width: _isTextFieldEmpty ? 1 : 2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _kGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _displayAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _isTextFieldEmpty ? Colors.grey[400] : _kGreen,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _onAmountChanged,
                    ),
                  ),
                ],
              ),
            ),

            // ── Live local equivalent hint (as user types) ────────────────
            if (_currentRawAmount > 0)
              DonationLocalAmountHint(
                usdAmount: _currentRawAmount,
                textColor: _kGreen,
              ),

            const SizedBox(height: 14),

            // ── Message ───────────────────────────────────────────────────
            TextField(
              controller: _messageCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Leave a message (optional)',
                prefixIcon: const Icon(Icons.message_outlined, color: _kGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Anonymous toggle ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.07)),
              ),
              child: SwitchListTile(
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
                activeColor: _kGreen,
                title: const Text(
                  'Donate anonymously',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                subtitle: const Text(
                  'Your name will be hidden from the athlete',
                  style: TextStyle(fontSize: 11),
                ),
                secondary: const FaIcon(
                  FontAwesomeIcons.mask,
                  size: 22,
                  color: _kGreen,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── Pay button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _donate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: _kGreen.withOpacity(0.4),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Proceed to Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Security note ─────────────────────────────────────────────
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lock,
                    size: 13,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Secured by Flutterwave',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Success Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _DonationSuccessDialog extends StatelessWidget {
  final String athleteName;
  final double amount;
  final bool anonymous;

  const _DonationSuccessDialog({
    required this.athleteName,
    required this.amount,
    required this.anonymous,
  });

  static const Color _kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Success icon ─────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 34)),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Thank you!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _kGreen,
              ),
            ),

            const SizedBox(height: 12),

            // ── Amount display: USD + local equivalent ────────────────────
            DonationSuccessAmountDisplay(
              usdAmount: amount,
              primaryColor: _kGreen,
            ),

            const SizedBox(height: 14),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.65),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: athleteName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' has received your '),
                  if (anonymous) const TextSpan(text: 'anonymous '),
                  const TextSpan(
                    text:
                        'donation with thanks. The world needs more people like you. 💪',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Close button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
