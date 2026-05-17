/*
import 'dart:convert';
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';
import 'package:http/http.dart' as http;

class PaystackInitResponse {
  final String authorizationUrl;
  final String reference;

  PaystackInitResponse({
    required this.authorizationUrl,
    required this.reference,
  });
}

class PaystackHostedPaymentService {
  static const String _defaultCallbackUrl =
      'https://afriendorse.app/paystack-callback';

  static Future<PaystackInitResponse> initialize({
    required String email,
    required double amountNgn,
    Map<String, dynamic>? metadata,
    String callbackUrl = _defaultCallbackUrl,
  }) async {
    final config = await PaymentConfigService.getConfig();
    if (config == null || config.secretKey.trim().isEmpty) {
      throw Exception('Paystack config missing (secretKey).');
    }

    final amountKobo = (amountNgn * 100).round();

    final uri = Uri.parse(config.initializeUrl);
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.secretKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'amount': amountKobo,
        'currency': config.currency,
        'callback_url': callbackUrl,
        if (metadata != null) 'metadata': metadata,
      }),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['status'] != true) {
      throw Exception(body['message'] ?? 'Unable to initialize transaction');
    }

    final data = body['data'] as Map<String, dynamic>;
    return PaystackInitResponse(
      authorizationUrl: data['authorization_url'],
      reference: data['reference'],
    );
  }

  static Future<bool> verify({required String reference}) async {
    final config = await PaymentConfigService.getConfig();
    if (config == null || config.secretKey.trim().isEmpty) {
      throw Exception('Paystack config missing (secretKey).');
    }

    final uri = Uri.parse(config.verifyUrl(reference));
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.secretKey}',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(res.body);
    if (res.statusCode != 200 || body['status'] != true) {
      return false;
    }

    final data = body['data'] as Map<String, dynamic>;
    return (data['status']?.toString().toLowerCase() == 'success');
  }
}
*/

// lib/athlete/feature/donations/flutterwave_hosted_payment_service.dart

import 'dart:convert';
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';
import 'package:http/http.dart' as http;

class FlutterwaveInitResponse {
  final String checkoutUrl; // Flutterwave's hosted checkout link
  final String txRef; // your unique reference (what you passed in)

  FlutterwaveInitResponse({required this.checkoutUrl, required this.txRef});
}

class FlutterwaveHostedPaymentService {
  static const String _defaultRedirectUrl =
      'https://afriendorse.app/flutterwave-callback';

  /// Creates a hosted payment link via POST /v3/payments.
  /// Amount is in USD (decimal), NOT multiplied by 100.
  static Future<FlutterwaveInitResponse> initialize({
    required String email,
    required String customerName,
    required double amountUsd,
    required String txRef, // caller must supply a unique ref
    Map<String, dynamic>? meta,
    String redirectUrl = _defaultRedirectUrl,
  }) async {
    final config = await PaymentConfigService.getConfig();
    if (config == null || config.secretKey.trim().isEmpty) {
      throw Exception('Flutterwave config missing (secretKey).');
    }

    final uri = Uri.parse(config.initializeUrl);
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.secretKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tx_ref': txRef,
        'amount': amountUsd, // decimal e.g. 25.00 — no ×100
        'currency': config.currency, // "USD"
        'redirect_url': redirectUrl,
        'customer': {'email': email, 'name': customerName},
        'customizations': {
          'title': 'AfriEndorse',
          'description': 'Athlete donation',
          'logo': '',
        },
        if (meta != null) 'meta': meta,
      }),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    // Flutterwave: { "status": "success", "data": { "link": "..." } }
    if (res.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Unable to initialize transaction');
    }

    final data = body['data'] as Map<String, dynamic>;
    return FlutterwaveInitResponse(
      checkoutUrl: data['link'] as String,
      txRef: txRef,
    );
  }

  /// Verifies a transaction by its numeric transaction_id (from redirect params).
  /// Also validates amount and currency to prevent response-tampering.
  static Future<bool> verify({
    required String transactionId,
    required double expectedAmount,
  }) async {
    final config = await PaymentConfigService.getConfig();
    if (config == null || config.secretKey.trim().isEmpty) {
      throw Exception('Flutterwave config missing (secretKey).');
    }

    final uri = Uri.parse(config.verifyUrl(transactionId));
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer ${config.secretKey}'},
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['status'] != 'success') {
      return false;
    }

    final data = body['data'] as Map<String, dynamic>;
    final status = (data['status'] as String?)?.toLowerCase() ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final currency = (data['currency'] as String?) ?? '';

    // Guard against amount/currency tampering
    return status == 'successful' &&
        amount == expectedAmount &&
        currency == config.currency;
  }
}
