/*
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';

// ─── Sentinel URLs — must match what Paystack dashboard has as callback ───────
// From your log: https://admin.afriendorse.com/payment/paystack/callback?trxref=...
const _kCallbackHost = 'admin.afriendorse.com';
const _kCallbackPath = '/payment/paystack/callback';
const _kCancelPath = '/payment/paystack/cancel';

bool _isSuccessUrl(Uri uri) =>
    uri.host == _kCallbackHost && uri.path.startsWith(_kCallbackPath);

bool _isCancelUrl(Uri uri) =>
    uri.host == _kCallbackHost && uri.path.startsWith(_kCancelPath);

// ─── Overlay snackbar ────────────────────────────────────────────────────────
void _donationSnack(String message, {bool success = false}) {
  final nav = Get.key.currentState;
  if (nav == null || !nav.mounted) return;
  final overlay = nav.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 48,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: success ? Colors.green[600] : Colors.red[400],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), () {
    try {
      entry.remove();
    } catch (_) {}
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class GroupDonationScreen extends StatefulWidget {
  final String donationId;
  final String groupId;
  final double amount;
  final String email;
  final String donorName;

  const GroupDonationScreen({
    Key? key,
    required this.donationId,
    required this.groupId,
    required this.amount,
    required this.email,
    required this.donorName,
  }) : super(key: key);

  @override
  State<GroupDonationScreen> createState() => _GroupDonationScreenState();
}

class _GroupDonationScreenState extends State<GroupDonationScreen> {
  InAppWebViewController? _webController;

  bool _webVisible = false;
  bool _isInitializing = true;
  bool _handled = false;

  String _statusText = 'Connecting to Paystack...';
  String? _checkoutUrl;
  String? _errorText;

  late final String _reference;

  @override
  void initState() {
    super.initState();
    _reference =
        'grp_${widget.donationId}_${DateTime.now().millisecondsSinceEpoch}';
    _initPayment();
  }

  // ── Step 1: initialise transaction ───────────────────────────────────────
  Future<void> _initPayment() async {
    final config = await PaymentConfigService.getConfig();
    if (config == null ||
        config.secretKey.isEmpty ||
        config.publicKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Payment is not configured yet.\nPlease contact support.';
      });
      return;
    }

    if (mounted) setState(() => _statusText = 'Initializing secure payment...');

    try {
      final response = await http
          .post(
            Uri.parse(config.initializeUrl),
            headers: {
              'Authorization': 'Bearer ${config.secretKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': widget.email,
              'amount': (widget.amount * 100).toInt(),
              'currency': config.currency,
              'reference': _reference,
              // No callback_url here — we use the one set in Paystack dashboard
              // which is: https://admin.afriendorse.com/payment/paystack/callback
              'metadata': {
                'custom_fields': [
                  {
                    'display_name': 'Donor',
                    'variable_name': 'donor_name',
                    'value': widget.donorName,
                  },
                  {
                    'display_name': 'Type',
                    'variable_name': 'payment_type',
                    'value': 'group_donation',
                  },
                ],
                'donation_id': widget.donationId,
                'group_id': widget.groupId,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(
          '[Donation] init → status=${body['status']} msg=${body['message']}',
        );
      }

      if (body['status'] == true) {
        final url = body['data']['authorization_url'] as String;
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _webVisible = true;
          _checkoutUrl = url;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _errorText = body['message'] as String? ?? 'Initialization failed.';
        });
      }
    } catch (e) {
      if (kDebugMode) print('[Donation] init error: $e');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Network error. Check your connection and try again.';
      });
    }
  }

  // ── URL check (shared logic) ──────────────────────────────────────────────
  /// Returns true if the URL was handled (success or cancel).
  bool _checkUri(String? rawUrl) {
    if (_handled || rawUrl == null) return false;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return false;

    if (kDebugMode) print('[Donation] checking url: $rawUrl');

    if (_isSuccessUrl(uri)) {
      _handleSuccess(uri);
      return true;
    }
    if (_isCancelUrl(uri)) {
      _handleCancel();
      return true;
    }
    return false;
  }

  // ── shouldOverrideUrlLoading ──────────────────────────────────────────────
  Future<NavigationActionPolicy> _shouldOverride(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final url = action.request.url?.toString() ?? '';
    if (kDebugMode) print('[Donation] nav → $url');

    if (_checkUri(url)) {
      // Block the WebView from actually loading our backend callback page
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  // ── Success ───────────────────────────────────────────────────────────────
  void _handleSuccess(Uri uri) {
    if (_handled) return;
    _handled = true;

    final ref =
        uri.queryParameters['trxref'] ??
        uri.queryParameters['reference'] ??
        _reference;

    if (kDebugMode) print('[Donation] success ref=$ref');
    _verifyAndComplete(ref);
  }

  Future<void> _verifyAndComplete(String trxref) async {
    if (mounted) {
      setState(() {
        _webVisible = false;
        _isInitializing = true;
        _statusText = 'Confirming payment…';
      });
    }

    bool verified = false;
    try {
      final config = await PaymentConfigService.getConfig();
      if (config != null) {
        final res = await http
            .get(
              Uri.parse(config.verifyUrl(trxref)),
              headers: {'Authorization': 'Bearer ${config.secretKey}'},
            )
            .timeout(const Duration(seconds: 15));

        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final status = body['data']?['status'] as String? ?? '';
        verified = status == 'success';

        if (kDebugMode) print('[Donation] verify → $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Donation] verify error: $e — completing optimistically');
      }
      // Trust the redirect on network errors
      verified = true;
    }

    if (verified) {
      final completed = await GroupFirestoreService.completeDonation(
        donationId: widget.donationId,
        transactionRef: trxref,
      );

      if (mounted) Navigator.of(context).pop();

      _donationSnack(
        completed
            ? 'Thank you! Your donation has been split among the athletes 🎉'
            : 'Payment confirmed! Distribution is being processed.',
        success: true,
      );
    } else {
      await _cancelRecord();
      if (mounted) Navigator.of(context).pop();
      _donationSnack('Payment was not completed. Please try again.');
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  void _handleCancel() {
    if (_handled) return;
    _handled = true;
    if (kDebugMode) print('[Donation] cancelled by user');
    _cancelRecord().then((_) {
      if (mounted) Navigator.of(context).pop();
      _donationSnack('Payment cancelled.');
    });
  }

  Future<void> _cancelRecord() async {
    try {
      await GroupFirestoreService.cancelDonation(donationId: widget.donationId);
    } catch (_) {}
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_webVisible || _handled,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _webVisible && !_handled) {
          _handleCancel();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            'Secure Donation',
            style: robotoMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          leading: _webVisible
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    if (!_handled) _handleCancel();
                  },
                )
              : const BackButton(),
        ),
        body: Stack(
          children: [
            // ── WebView ───────────────────────────────────────────────────
            if (_webVisible && _checkoutUrl != null)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_checkoutUrl!)),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  useHybridComposition: true,
                ),
                onWebViewCreated: (c) => _webController = c,

                // Primary intercept — fires before the WebView loads the URL
                shouldOverrideUrlLoading: _shouldOverride,

                // Backup: fires when WebView starts loading a URL
                onLoadStart: (_, url) => _checkUri(url?.toString()),

                // Backup: fires when page finishes loading
                onLoadStop: (_, url) => _checkUri(url?.toString()),

                onProgressChanged: (_, p) {
                  if (kDebugMode) print('[Donation] progress $p%');
                },

                // ✅ Correct signature for flutter_inappwebview
                // WebResourceRequest + WebResourceError (NOT action.request)
                onReceivedError:
                    (
                      InAppWebViewController controller,
                      WebResourceRequest request,
                      WebResourceError error,
                    ) {
                      final url = request.url?.toString() ?? '';
                      if (kDebugMode) {
                        print(
                          '[Donation] webError "${error.description}" for $url',
                        );
                      }
                      // Fallback: if WebView tried to load our callback URL
                      // but got a network error (DNS not found etc.), still handle it
                      _checkUri(url);
                    },
              ),

            // ── Loading / error overlay ───────────────────────────────────
            if (_isInitializing || _errorText != null)
              Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _errorText == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _statusText,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white54,
                                size: 52,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorText!,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Go Back'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


*/

// lib/athlete/feature/groups/screens/group_donation_screen.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';

// ─── Sentinel URLs — set these in your Flutterwave dashboard ─────────────────
// Redirect URL:  https://admin.afriendorse.com/payment/flutterwave/callback
// Cancel  URL:   https://admin.afriendorse.com/payment/flutterwave/cancel
const _kCallbackHost = 'admin.afriendorse.com';
const _kCallbackPath = '/payment/flutterwave/callback';
const _kCancelPath = '/payment/flutterwave/cancel';

bool _isSuccessUrl(Uri uri) =>
    uri.host == _kCallbackHost && uri.path.startsWith(_kCallbackPath);

bool _isCancelUrl(Uri uri) =>
    uri.host == _kCallbackHost && uri.path.startsWith(_kCancelPath);

// ─── Overlay snackbar ────────────────────────────────────────────────────────
void _donationSnack(String message, {bool success = false}) {
  final nav = Get.key.currentState;
  if (nav == null || !nav.mounted) return;
  final overlay = nav.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 48,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: success ? Colors.green[600] : Colors.red[400],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), () {
    try {
      entry.remove();
    } catch (_) {}
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class GroupDonationScreen extends StatefulWidget {
  final String donationId;
  final String groupId;
  final double amount;
  final String email;
  final String donorName;

  const GroupDonationScreen({
    Key? key,
    required this.donationId,
    required this.groupId,
    required this.amount,
    required this.email,
    required this.donorName,
  }) : super(key: key);

  @override
  State<GroupDonationScreen> createState() => _GroupDonationScreenState();
}

class _GroupDonationScreenState extends State<GroupDonationScreen> {
  InAppWebViewController? _webController;

  bool _webVisible = false;
  bool _isInitializing = true;
  bool _handled = false;

  String _statusText = 'Connecting to Flutterwave...';
  String? _checkoutUrl;
  String? _errorText;

  /// Flutterwave tx_ref — their equivalent of Paystack's reference
  late final String _txRef;

  @override
  void initState() {
    super.initState();
    // tx_ref must be unique per transaction
    _txRef =
        'grp_${widget.donationId}_${DateTime.now().millisecondsSinceEpoch}';
    _initPayment();
  }

  // ── Step 1: create hosted-payment link ───────────────────────────────────
  Future<void> _initPayment() async {
    final config = await PaymentConfigService.getConfig();
    if (config == null ||
        config.secretKey.isEmpty ||
        config.publicKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Payment is not configured yet.\nPlease contact support.';
      });
      return;
    }

    if (mounted) {
      setState(() => _statusText = 'Initializing secure payment...');
    }

    try {
      // Flutterwave /v3/payments creates a hosted checkout link.
      // Amount is passed as a decimal (e.g. 25.00), NOT multiplied by 100.
      final response = await http
          .post(
            Uri.parse(config.initializeUrl),
            headers: {
              'Authorization': 'Bearer ${config.secretKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'tx_ref': _txRef,
              'amount': widget.amount, // decimal, e.g. 25.00
              'currency': config.currency, // "USD"
              'redirect_url': 'https://$_kCallbackHost$_kCallbackPath',
              'customer': {'email': widget.email, 'name': widget.donorName},
              'customizations': {
                'title': 'Group Donation',
                'description': 'Support athletes in this group',
                'logo': '', // optional: your logo URL
              },
              'meta': {
                'donation_id': widget.donationId,
                'group_id': widget.groupId,
                'payment_type': 'group_donation',
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(
          '[Donation] FLW init → status=${body['status']} '
          'msg=${body['message']}',
        );
      }

      // Flutterwave returns { "status": "success", "data": { "link": "..." } }
      if (body['status'] == 'success') {
        final url = body['data']['link'] as String;
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _webVisible = true;
          _checkoutUrl = url;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _errorText = body['message'] as String? ?? 'Initialization failed.';
        });
      }
    } catch (e) {
      if (kDebugMode) print('[Donation] init error: $e');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Network error. Check your connection and try again.';
      });
    }
  }

  // ── URL check (shared logic) ──────────────────────────────────────────────
  bool _checkUri(String? rawUrl) {
    if (_handled || rawUrl == null) return false;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return false;

    if (kDebugMode) print('[Donation] checking url: $rawUrl');

    if (_isSuccessUrl(uri)) {
      _handleSuccess(uri);
      return true;
    }
    if (_isCancelUrl(uri)) {
      _handleCancel();
      return true;
    }
    return false;
  }

  // ── shouldOverrideUrlLoading ──────────────────────────────────────────────
  Future<NavigationActionPolicy> _shouldOverride(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final url = action.request.url?.toString() ?? '';
    if (kDebugMode) print('[Donation] nav → $url');

    if (_checkUri(url)) {
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  // ── Success ───────────────────────────────────────────────────────────────
  void _handleSuccess(Uri uri) {
    if (_handled) return;
    _handled = true;

    // Flutterwave appends ?transaction_id=...&tx_ref=...&status=successful
    final transactionId = uri.queryParameters['transaction_id'] ?? '';
    final txRef = uri.queryParameters['tx_ref'] ?? _txRef;
    final status = uri.queryParameters['status'] ?? '';

    if (kDebugMode) {
      print(
        '[Donation] FLW callback — status=$status '
        'txRef=$txRef transactionId=$transactionId',
      );
    }

    if (status == 'successful' || status == 'completed') {
      _verifyAndComplete(transactionId, txRef);
    } else {
      // Flutterwave returned status=failed or status=cancelled via redirect
      _cancelRecord().then((_) {
        if (mounted) Navigator.of(context).pop();
        _donationSnack('Payment was not completed. Please try again.');
      });
    }
  }

  Future<void> _verifyAndComplete(String transactionId, String txRef) async {
    if (mounted) {
      setState(() {
        _webVisible = false;
        _isInitializing = true;
        _statusText = 'Confirming payment…';
      });
    }

    bool verified = false;
    try {
      final config = await PaymentConfigService.getConfig();
      if (config != null && transactionId.isNotEmpty) {
        // Verify by transaction ID (Flutterwave's recommended approach)
        final res = await http
            .get(
              Uri.parse(config.verifyUrl(transactionId)),
              headers: {'Authorization': 'Bearer ${config.secretKey}'},
            )
            .timeout(const Duration(seconds: 15));

        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final verifyStatus = body['data']?['status'] as String? ?? '';
        final verifiedAmount =
            (body['data']?['amount'] as num?)?.toDouble() ?? 0;
        final verifiedCurrency = body['data']?['currency'] as String? ?? '';

        // Guard: amount and currency must match what we initiated
        verified =
            verifyStatus == 'successful' &&
            verifiedAmount == widget.amount &&
            verifiedCurrency == (config.currency);

        if (kDebugMode) {
          print(
            '[Donation] FLW verify → status=$verifyStatus '
            'amount=$verifiedAmount currency=$verifiedCurrency '
            'verified=$verified',
          );
        }
      } else if (transactionId.isEmpty) {
        // No transaction_id in redirect — trust redirect optimistically
        // (happens on some network configs)
        verified = true;
        if (kDebugMode) {
          print('[Donation] no transactionId — completing optimistically');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Donation] verify error: $e — completing optimistically');
      }
      verified = true;
    }

    if (verified) {
      final completed = await GroupFirestoreService.completeDonation(
        donationId: widget.donationId,
        // Store Flutterwave's transaction ID as the canonical reference
        transactionRef: transactionId.isNotEmpty ? transactionId : txRef,
      );

      if (mounted) Navigator.of(context).pop();
      _donationSnack(
        completed ? 'Thank you! 🎉' : 'Payment confirmed!',
        success: true,
      );
    } else {
      await _cancelRecord();
      if (mounted) Navigator.of(context).pop();
      _donationSnack('Payment was not completed. Please try again.');
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  void _handleCancel() {
    if (_handled) return;
    _handled = true;
    if (kDebugMode) print('[Donation] cancelled by user');
    _cancelRecord().then((_) {
      if (mounted) Navigator.of(context).pop();
      _donationSnack('Payment cancelled.');
    });
  }

  Future<void> _cancelRecord() async {
    try {
      await GroupFirestoreService.cancelDonation(donationId: widget.donationId);
    } catch (_) {}
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_webVisible || _handled,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _webVisible && !_handled) {
          _handleCancel();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            'Secure Donation',
            style: robotoMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          leading: _webVisible
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    if (!_handled) _handleCancel();
                  },
                )
              : const BackButton(),
        ),
        body: Stack(
          children: [
            // ── WebView ───────────────────────────────────────────────────
            if (_webVisible && _checkoutUrl != null)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_checkoutUrl!)),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  useHybridComposition: true,
                ),
                onWebViewCreated: (c) => _webController = c,

                shouldOverrideUrlLoading: _shouldOverride,
                onLoadStart: (_, url) => _checkUri(url?.toString()),
                onLoadStop: (_, url) => _checkUri(url?.toString()),

                onProgressChanged: (_, p) {
                  if (kDebugMode) print('[Donation] progress $p%');
                },

                onReceivedError:
                    (
                      InAppWebViewController controller,
                      WebResourceRequest request,
                      WebResourceError error,
                    ) {
                      final url = request.url?.toString() ?? '';
                      if (kDebugMode) {
                        print(
                          '[Donation] webError "${error.description}" for $url',
                        );
                      }
                      _checkUri(url);
                    },
              ),

            // ── Loading / error overlay ───────────────────────────────────
            if (_isInitializing || _errorText != null)
              Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _errorText == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _statusText,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white54,
                                size: 52,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorText!,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Go Back'),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
