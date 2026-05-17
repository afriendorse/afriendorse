// lib/services/currency_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _apiKey = 'c55c8fbdabb75a489f263675'; // 🔑 Replace this
  static const String _baseUrl =
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/USD';

  // Cache keys
  static const String _ratesCacheKey = 'cached_exchange_rates';
  static const String _cacheTimestampKey = 'exchange_rates_timestamp';
  static const Duration _cacheDuration = Duration(hours: 1);

  // Singleton
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  Map<String, double> _rates = {};
  bool _isFetching = false;

  /// Maps E.164 phone prefix → {currencyCode, countryName, currencySymbol}
  static const Map<String, Map<String, String>> _phonePrefixMap = {
    // Africa
    '+234': {
      'currency': 'NGN',
      'country': 'Nigeria',
      'symbol': '₦',
      'flag': '🇳🇬',
    },
    '+233': {
      'currency': 'GHS',
      'country': 'Ghana',
      'symbol': 'GH₵',
      'flag': '🇬🇭',
    },
    '+27': {
      'currency': 'ZAR',
      'country': 'South Africa',
      'symbol': 'R',
      'flag': '🇿🇦',
    },
    '+254': {
      'currency': 'KES',
      'country': 'Kenya',
      'symbol': 'KSh',
      'flag': '🇰🇪',
    },
    '+255': {
      'currency': 'TZS',
      'country': 'Tanzania',
      'symbol': 'TSh',
      'flag': '🇹🇿',
    },
    '+256': {
      'currency': 'UGX',
      'country': 'Uganda',
      'symbol': 'USh',
      'flag': '🇺🇬',
    },
    '+251': {
      'currency': 'ETB',
      'country': 'Ethiopia',
      'symbol': 'Br',
      'flag': '🇪🇹',
    },
    '+237': {
      'currency': 'XAF',
      'country': 'Cameroon',
      'symbol': 'FCFA',
      'flag': '🇨🇲',
    },
    '+225': {
      'currency': 'XOF',
      'country': 'Côte d\'Ivoire',
      'symbol': 'CFA',
      'flag': '🇨🇮',
    },
    '+221': {
      'currency': 'XOF',
      'country': 'Senegal',
      'symbol': 'CFA',
      'flag': '🇸🇳',
    },
    '+212': {
      'currency': 'MAD',
      'country': 'Morocco',
      'symbol': 'MAD',
      'flag': '🇲🇦',
    },
    '+20': {
      'currency': 'EGP',
      'country': 'Egypt',
      'symbol': 'E£',
      'flag': '🇪🇬',
    },
    '+260': {
      'currency': 'ZMW',
      'country': 'Zambia',
      'symbol': 'ZK',
      'flag': '🇿🇲',
    },
    '+263': {
      'currency': 'USD',
      'country': 'Zimbabwe',
      'symbol': '\$',
      'flag': '🇿🇼',
    },
    '+267': {
      'currency': 'BWP',
      'country': 'Botswana',
      'symbol': 'P',
      'flag': '🇧🇼',
    },
    '+250': {
      'currency': 'RWF',
      'country': 'Rwanda',
      'symbol': 'RF',
      'flag': '🇷🇼',
    },
    '+252': {
      'currency': 'SOS',
      'country': 'Somalia',
      'symbol': 'Sh',
      'flag': '🇸🇴',
    },
    '+249': {
      'currency': 'SDG',
      'country': 'Sudan',
      'symbol': 'SDG',
      'flag': '🇸🇩',
    },

    // Americas
    '+1': {
      'currency': 'USD',
      'country': 'United States',
      'symbol': '\$',
      'flag': '🇺🇸',
    },
    '+55': {
      'currency': 'BRL',
      'country': 'Brazil',
      'symbol': 'R\$',
      'flag': '🇧🇷',
    },
    '+52': {
      'currency': 'MXN',
      'country': 'Mexico',
      'symbol': 'MX\$',
      'flag': '🇲🇽',
    },
    '+57': {
      'currency': 'COP',
      'country': 'Colombia',
      'symbol': 'COL\$',
      'flag': '🇨🇴',
    },
    '+58': {
      'currency': 'VES',
      'country': 'Venezuela',
      'symbol': 'Bs.',
      'flag': '🇻🇪',
    },
    '+54': {
      'currency': 'ARS',
      'country': 'Argentina',
      'symbol': 'AR\$',
      'flag': '🇦🇷',
    },

    // Europe
    '+44': {
      'currency': 'GBP',
      'country': 'United Kingdom',
      'symbol': '£',
      'flag': '🇬🇧',
    },
    '+49': {
      'currency': 'EUR',
      'country': 'Germany',
      'symbol': '€',
      'flag': '🇩🇪',
    },
    '+33': {
      'currency': 'EUR',
      'country': 'France',
      'symbol': '€',
      'flag': '🇫🇷',
    },
    '+34': {
      'currency': 'EUR',
      'country': 'Spain',
      'symbol': '€',
      'flag': '🇪🇸',
    },
    '+39': {
      'currency': 'EUR',
      'country': 'Italy',
      'symbol': '€',
      'flag': '🇮🇹',
    },
    '+31': {
      'currency': 'EUR',
      'country': 'Netherlands',
      'symbol': '€',
      'flag': '🇳🇱',
    },
    '+41': {
      'currency': 'CHF',
      'country': 'Switzerland',
      'symbol': 'CHF',
      'flag': '🇨🇭',
    },

    // Asia
    '+91': {
      'currency': 'INR',
      'country': 'India',
      'symbol': '₹',
      'flag': '🇮🇳',
    },
    '+86': {
      'currency': 'CNY',
      'country': 'China',
      'symbol': '¥',
      'flag': '🇨🇳',
    },
    '+81': {
      'currency': 'JPY',
      'country': 'Japan',
      'symbol': '¥',
      'flag': '🇯🇵',
    },
    '+82': {
      'currency': 'KRW',
      'country': 'South Korea',
      'symbol': '₩',
      'flag': '🇰🇷',
    },
    '+971': {
      'currency': 'AED',
      'country': 'UAE',
      'symbol': 'AED',
      'flag': '🇦🇪',
    },
    '+966': {
      'currency': 'SAR',
      'country': 'Saudi Arabia',
      'symbol': 'SAR',
      'flag': '🇸🇦',
    },
    '+65': {
      'currency': 'SGD',
      'country': 'Singapore',
      'symbol': 'S\$',
      'flag': '🇸🇬',
    },
    '+60': {
      'currency': 'MYR',
      'country': 'Malaysia',
      'symbol': 'RM',
      'flag': '🇲🇾',
    },
    '+62': {
      'currency': 'IDR',
      'country': 'Indonesia',
      'symbol': 'Rp',
      'flag': '🇮🇩',
    },
    '+63': {
      'currency': 'PHP',
      'country': 'Philippines',
      'symbol': '₱',
      'flag': '🇵🇭',
    },
    '+92': {
      'currency': 'PKR',
      'country': 'Pakistan',
      'symbol': 'Rs',
      'flag': '🇵🇰',
    },

    // Oceania
    '+61': {
      'currency': 'AUD',
      'country': 'Australia',
      'symbol': 'A\$',
      'flag': '🇦🇺',
    },
    '+64': {
      'currency': 'NZD',
      'country': 'New Zealand',
      'symbol': 'NZ\$',
      'flag': '🇳🇿',
    },
  };

  /// Resolve currency info from a phone number (E.164 format)
  /// Tries longest prefix first to avoid +1 matching +234 etc.
  static Map<String, String>? resolveCurrencyFromPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;

    final normalized = phone.trim();

    // Try longest prefix first (4 → 3 → 2 digits after +)
    for (int len in [4, 3, 2, 1]) {
      if (normalized.length > len) {
        final prefix = normalized.substring(0, len + 1); // +234 style
        if (_phonePrefixMap.containsKey(prefix)) {
          return _phonePrefixMap[prefix];
        }
      }
    }
    return null;
  }

  /// Fetch exchange rates from API (with 1-hour cache)
  Future<Map<String, double>> fetchRates({bool forceRefresh = false}) async {
    if (_isFetching) return _rates;

    // Return cached in-memory rates if fresh
    if (!forceRefresh && _rates.isNotEmpty) return _rates;

    // Check SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_ratesCacheKey);
    final cachedTimestamp = prefs.getInt(_cacheTimestampKey);

    if (!forceRefresh && cachedJson != null && cachedTimestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTimestamp;
      if (cacheAge < _cacheDuration.inMilliseconds) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
        if (kDebugMode) print('[CurrencyService] Using cached rates ✅');
        return _rates;
      }
    }

    // Fetch fresh from API
    _isFetching = true;
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          final rawRates = data['conversion_rates'] as Map<String, dynamic>;
          _rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));

          // Cache to SharedPreferences
          await prefs.setString(_ratesCacheKey, jsonEncode(_rates));
          await prefs.setInt(
            _cacheTimestampKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          if (kDebugMode) {
            print('[CurrencyService] Fresh rates fetched ✅');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[CurrencyService] Rate fetch error: $e');
      // Fall back to cached even if stale
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } finally {
      _isFetching = false;
    }

    return _rates;
  }

  /// Convert USD amount to target currency
  double convertFromUsd(double usdAmount, String targetCurrency) {
    if (targetCurrency == 'USD') return usdAmount;
    final rate = _rates[targetCurrency];
    if (rate == null) return usdAmount;
    return usdAmount * rate;
  }

  /// Get rate label e.g. "1 USD = 1,580.50 NGN"
  String getRateLabel(String targetCurrency) {
    if (targetCurrency == 'USD') return '';
    final rate = _rates[targetCurrency];
    if (rate == null) return '';
    return '1 USD = ${_formatRate(rate, targetCurrency)} $targetCurrency';
  }

  String _formatRate(double rate, String currency) {
    // High-value currencies (like JPY, KRW, IDR) — no decimals
    const noDecimal = ['JPY', 'KRW', 'IDR', 'UGX', 'TZS', 'RWF', 'SOS'];
    if (noDecimal.contains(currency)) {
      return rate
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return rate
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  /// Format a converted amount with symbol
  String formatConverted(double amount, String currency, String symbol) {
    const noDecimal = ['JPY', 'KRW', 'IDR', 'UGX', 'TZS', 'RWF', 'SOS'];
    final formatted = noDecimal.contains(currency)
        ? amount
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              )
        : amount
              .toStringAsFixed(2)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              );
    return '$symbol$formatted';
  }

  /// Check if rates are loaded
  bool get hasRates => _rates.isNotEmpty;

  /// Get last fetch time from cache
  Future<DateTime?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_cacheTimestampKey);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }
}
