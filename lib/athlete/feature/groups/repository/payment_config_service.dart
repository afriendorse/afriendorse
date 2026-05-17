// lib/athlete/feature/groups/repository/payment_config_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/*
class PaystackConfig {
  final String publicKey;
  final String secretKey;
  final bool isLive;
  final String currency;

  const PaystackConfig({
    required this.publicKey,
    required this.secretKey,
    required this.isLive,
    required this.currency,
  });

  String get initializeUrl => 'https://api.paystack.co/transaction/initialize';
  String verifyUrl(String ref) =>
      'https://api.paystack.co/transaction/verify/$ref';
}

class PaymentConfigService {
  static final _db = FirebaseFirestore.instance;
  static PaystackConfig? _cached;

  static Future<PaystackConfig?> getConfig({bool forceRefresh = false}) async {
    if (_cached != null && !forceRefresh) return _cached;

    try {
      final doc = await _db.collection('payment_config').doc('paystack').get();
      if (!doc.exists) {
        if (kDebugMode) {
          print(
            '[PaymentConfig] payment_config/paystack not found in Firestore',
          );
        }
        return null;
      }

      final d = doc.data() as Map<String, dynamic>;
      _cached = PaystackConfig(
        publicKey: (d['publicKey'] as String? ?? '').trim(),
        secretKey: (d['secretKey'] as String? ?? '').trim(),
        isLive: (d['mode'] as String? ?? 'test') == 'live',
        currency: (d['currency'] as String? ?? 'NGN').trim(),
      );

      if (kDebugMode) {
        print(
          '[PaymentConfig] loaded — mode=${d['mode']} currency=${_cached!.currency}',
        );
      }
      return _cached;
    } catch (e) {
      if (kDebugMode) print('[PaymentConfig] error: $e');
      return null;
    }
  }

  static void clearCache() => _cached = null;
}
*/

class FlutterwaveConfig {
  final String publicKey;
  final String secretKey;
  final bool isLive;
  final String currency;

  const FlutterwaveConfig({
    required this.publicKey,
    required this.secretKey,
    required this.isLive,
    required this.currency,
  });

  /// Standard Flutterwave charge endpoint
  String get initializeUrl => 'https://api.flutterwave.com/v3/payments';

  /// Verify a transaction by its transaction ID (not reference)
  String verifyUrl(String transactionId) =>
      'https://api.flutterwave.com/v3/transactions/$transactionId/verify';

  /// Flutterwave hosted checkout redirect URL (used in WebView)
  /// The SDK returns this directly from the /v3/payments response.
  String get checkoutBaseUrl => 'https://checkout.flutterwave.com/v3.js';
}

class PaymentConfigService {
  static final _db = FirebaseFirestore.instance;
  static FlutterwaveConfig? _cached;

  /// Reads config from Firestore doc: payment_config/flutterwave
  ///
  /// Expected fields:
  ///   publicKey  (String)  — your FLW public key
  ///   secretKey  (String)  — your FLW secret key
  ///   mode       (String)  — "live" | "test"
  ///   currency   (String)  — e.g. "USD"
  static Future<FlutterwaveConfig?> getConfig({
    bool forceRefresh = false,
  }) async {
    if (_cached != null && !forceRefresh) return _cached;

    try {
      final doc = await _db
          .collection('payment_config')
          .doc('flutterwave')
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print(
            '[PaymentConfig] payment_config/flutterwave not found in Firestore',
          );
        }
        return null;
      }

      final d = doc.data() as Map<String, dynamic>;
      _cached = FlutterwaveConfig(
        publicKey: (d['publicKey'] as String? ?? '').trim(),
        secretKey: (d['secretKey'] as String? ?? '').trim(),
        isLive: (d['mode'] as String? ?? 'test') == 'live',
        currency: (d['currency'] as String? ?? 'USD').trim(),
      );

      if (kDebugMode) {
        print(
          '[PaymentConfig] loaded — mode=${d['mode']} '
          'currency=${_cached!.currency}',
        );
      }

      return _cached;
    } catch (e) {
      if (kDebugMode) print('[PaymentConfig] error: $e');
      return null;
    }
  }

  static void clearCache() => _cached = null;
}
