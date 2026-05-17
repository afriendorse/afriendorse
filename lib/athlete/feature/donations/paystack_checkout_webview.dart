/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaystackCheckoutWebView extends StatefulWidget {
  final String authorizationUrl;
  final String
  callbackUrlPrefix; // e.g. https://afriendorse.app/paystack-callback
  final String expectedReference;

  const PaystackCheckoutWebView({
    super.key,
    required this.authorizationUrl,
    required this.callbackUrlPrefix,
    required this.expectedReference,
  });

  @override
  State<PaystackCheckoutWebView> createState() =>
      _PaystackCheckoutWebViewState();
}

class _PaystackCheckoutWebViewState extends State<PaystackCheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            final url = req.url;

            // Detect callback redirect
            if (url.startsWith(widget.callbackUrlPrefix)) {
              // Paystack redirects to callback_url?reference=XXXX
              final uri = Uri.tryParse(url);
              final ref =
                  uri?.queryParameters['reference'] ?? widget.expectedReference;

              Navigator.of(context).pop(ref);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
*/

// lib/athlete/feature/donations/flutterwave_checkout_webview.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Result returned when the WebView closes.
class FlutterwaveResult {
  final String? transactionId; // numeric id from ?transaction_id=
  final String? txRef; // your reference from ?tx_ref=
  final String? status; // "successful" | "cancelled" | "failed"

  const FlutterwaveResult({this.transactionId, this.txRef, this.status});

  bool get isSuccessful => status == 'successful' || status == 'completed';
}

class FlutterwaveCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;

  /// Base of your redirect URL — must match what you passed to /v3/payments.
  /// e.g. "https://afriendorse.app/flutterwave-callback"
  final String redirectUrlPrefix;

  const FlutterwaveCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.redirectUrlPrefix,
  });

  @override
  State<FlutterwaveCheckoutWebView> createState() =>
      _FlutterwaveCheckoutWebViewState();
}

class _FlutterwaveCheckoutWebViewState
    extends State<FlutterwaveCheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            final url = req.url;

            // Flutterwave redirects to:
            // {redirect_url}?transaction_id=xxx&tx_ref=yyy&status=successful
            if (url.startsWith(widget.redirectUrlPrefix)) {
              final uri = Uri.tryParse(url);
              final result = FlutterwaveResult(
                transactionId: uri?.queryParameters['transaction_id'],
                txRef: uri?.queryParameters['tx_ref'],
                status: uri?.queryParameters['status'],
              );
              Navigator.of(context).pop(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(
              context,
            ).pop(const FlutterwaveResult(status: 'cancelled')),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
