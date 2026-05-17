// lib/athlete/feature/wallet/controller/athlete_currency_controller.dart

import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Import athlete profile controller — to read email directly from session
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_ctrl;
// Import fan/brand user controller — fallback for fan/brand donors
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as fan_ctrl;

class AthleteCurrencyController extends GetxController {
  final CurrencyService _currencyService = CurrencyService();

  final RxBool isLoadingRates = true.obs;
  final RxBool showLocalCurrency = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isToggling = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString localCurrencyCode = ''.obs;
  final RxString localCurrencySymbol = ''.obs;
  final RxString localCountryName = ''.obs;
  final RxString localCountryFlag = ''.obs;
  final RxDouble localRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initCurrency();
  }

  Future<void> _initCurrency() async {
    isLoadingRates.value = true;
    errorMessage.value = '';

    try {
      await _resolveAthleteCurrency();
      await _currencyService.fetchRates();
      _updateLocalRate();
    } catch (e) {
      errorMessage.value = 'Could not load exchange rates';
      if (kDebugMode) print('[AthleteCurrencyController] init error: $e');
    } finally {
      isLoadingRates.value = false;
    }
  }

  Future<void> _resolveAthleteCurrency() async {
    // ── Strategy 1: Get phone from athlete session controller ────────────
    final phoneFromSession = _phoneFromAthleteSession();
    if (phoneFromSession != null && phoneFromSession.isNotEmpty) {
      if (kDebugMode) {
        print(
          '[AthleteCurrencyController] phone from session: $phoneFromSession',
        );
      }
      if (_applyPhone(phoneFromSession)) return;
    }

    // ── Strategy 2: Get phone from fan/brand session controller ──────────
    final phoneFromFanSession = _phoneFromFanSession();
    if (phoneFromFanSession != null && phoneFromFanSession.isNotEmpty) {
      if (kDebugMode) {
        print(
          '[AthleteCurrencyController] phone from fan session: $phoneFromFanSession',
        );
      }
      if (_applyPhone(phoneFromFanSession)) return;
    }

    // ── Strategy 3: Firebase Auth email → Firestore lookup ───────────────
    final authEmail = FirebaseAuth.instance.currentUser?.email
        ?.toLowerCase()
        .trim();
    if (authEmail != null && authEmail.isNotEmpty) {
      if (kDebugMode) {
        print('[AthleteCurrencyController] trying auth email: $authEmail');
      }
      final phone = await _fetchPhoneFromFirestore(authEmail);
      if (phone != null && phone.isNotEmpty) {
        if (kDebugMode) {
          print('[AthleteCurrencyController] phone from Firestore: $phone');
        }
        if (_applyPhone(phone)) return;
      }
    }

    // ── Strategy 4: Session email → Firestore lookup ─────────────────────
    final sessionEmail = _emailFromAnySession();
    if (sessionEmail != null &&
        sessionEmail.isNotEmpty &&
        sessionEmail != authEmail) {
      if (kDebugMode) {
        print(
          '[AthleteCurrencyController] trying session email: $sessionEmail',
        );
      }
      final phone = await _fetchPhoneFromFirestore(sessionEmail);
      if (phone != null && phone.isNotEmpty) {
        if (_applyPhone(phone)) return;
      }
    }

    if (kDebugMode) {
      print(
        '[AthleteCurrencyController] all strategies exhausted → USD fallback',
      );
    }
    _setUsdFallback();
  }

  // ── Read phone directly from the athlete session model ───────────────────

  String? _phoneFromAthleteSession() {
    try {
      if (!Get.isRegistered<athlete_ctrl.UserProfileController>()) return null;
      final ctrl = Get.find<athlete_ctrl.UserProfileController>();
      // Try owner phone field
      final ownerPhone =
          ctrl.providerModel?.content?.providerInfo?.owner?.phone;
      if (ownerPhone != null && ownerPhone.trim().isNotEmpty) {
        return ownerPhone.trim();
      }
      // Try contact phone field
      final contactPhone =
          ctrl.providerModel?.content?.providerInfo?.companyPhone;
      if (contactPhone != null && contactPhone.trim().isNotEmpty) {
        return contactPhone.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Read phone from fan/brand session model ──────────────────────────────

  String? _phoneFromFanSession() {
    try {
      if (!Get.isRegistered<fan_ctrl.UserController>()) return null;
      final ctrl = Get.find<fan_ctrl.UserController>();
      final phone = ctrl.userInfoModel?.phone;
      if (phone != null && phone.trim().isNotEmpty) return phone.trim();
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Get email from whichever session is active ───────────────────────────

  String? _emailFromAnySession() {
    try {
      if (Get.isRegistered<athlete_ctrl.UserProfileController>()) {
        final email = Get.find<athlete_ctrl.UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo
            ?.owner
            ?.email;
        if (email != null && email.isNotEmpty)
          return email.toLowerCase().trim();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<fan_ctrl.UserController>()) {
        final email = Get.find<fan_ctrl.UserController>().userInfoModel?.email;
        if (email != null && email.isNotEmpty)
          return email.toLowerCase().trim();
      }
    } catch (_) {}

    return null;
  }

  // ── Firestore lookup: tries athletes → users collections ─────────────────

  Future<String?> _fetchPhoneFromFirestore(String email) async {
    final lower = email.toLowerCase().trim();

    try {
      // Try athletes collection first
      final athleteData = await AthleteFirestoreSyncService.getAthleteByEmail(
        lower,
      );
      if (kDebugMode) {
        print('[AthleteCurrencyController] athlete doc: $athleteData');
      }
      final athletePhone = athleteData?['phone'] as String?;
      if (athletePhone != null && athletePhone.trim().isNotEmpty) {
        return athletePhone.trim();
      }

      // Try users collection (fan/brand)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(lower)
          .get();
      if (kDebugMode) {
        print('[AthleteCurrencyController] user doc exists: ${userDoc.exists}');
      }
      final userPhone = userDoc.data()?['phone'] as String?;
      if (userPhone != null && userPhone.trim().isNotEmpty) {
        return userPhone.trim();
      }

      // Try querying by email field (in case doc ID differs)
      final athleteQuery = await FirebaseFirestore.instance
          .collection('athletes')
          .where('email', isEqualTo: lower)
          .limit(1)
          .get();
      if (athleteQuery.docs.isNotEmpty) {
        final phone = athleteQuery.docs.first.data()['phone'] as String?;
        if (phone != null && phone.trim().isNotEmpty) return phone.trim();
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: lower)
          .limit(1)
          .get();
      if (userQuery.docs.isNotEmpty) {
        final phone = userQuery.docs.first.data()['phone'] as String?;
        if (phone != null && phone.trim().isNotEmpty) return phone.trim();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AthleteCurrencyController] Firestore lookup error: $e');
      }
    }

    return null;
  }

  // ── Apply phone → currency mapping ───────────────────────────────────────

  /// Returns true if a valid non-USD currency was resolved
  bool _applyPhone(String phone) {
    final currencyInfo = CurrencyService.resolveCurrencyFromPhone(phone);
    if (kDebugMode) {
      print(
        '[AthleteCurrencyController] resolveCurrencyFromPhone("$phone") → $currencyInfo',
      );
    }
    if (currencyInfo == null) return false;

    localCurrencyCode.value = currencyInfo['currency'] ?? 'USD';
    localCurrencySymbol.value = currencyInfo['symbol'] ?? '\$';
    localCountryName.value = currencyInfo['country'] ?? '';
    localCountryFlag.value = currencyInfo['flag'] ?? '';

    if (kDebugMode) {
      print(
        '[AthleteCurrencyController] ✅ Resolved: '
        '${localCountryFlag.value} ${localCountryName.value} '
        '→ ${localCurrencyCode.value}',
      );
    }
    return true;
  }

  void _setUsdFallback() {
    localCurrencyCode.value = 'USD';
    localCurrencySymbol.value = '\$';
    localCountryName.value = 'United States';
    localCountryFlag.value = '🇺🇸';
    localRate.value = 1.0;
  }

  void _updateLocalRate() {
    if (localCurrencyCode.value.isEmpty || localCurrencyCode.value == 'USD') {
      localRate.value = 1.0;
      return;
    }
    localRate.value = _currencyService.convertFromUsd(
      1.0,
      localCurrencyCode.value,
    );
  }

  // ── Public helpers ────────────────────────────────────────────────────────

  double convertToLocal(double usdAmount) =>
      _currencyService.convertFromUsd(usdAmount, localCurrencyCode.value);

  String getLocalEquivalent(double usdAmount) {
    final converted = convertToLocal(usdAmount);
    return _currencyService.formatConverted(
      converted,
      localCurrencyCode.value,
      localCurrencySymbol.value,
    );
  }

  String get rateLabel =>
      _currencyService.getRateLabel(localCurrencyCode.value);

  bool get hasLocalCurrency =>
      localCurrencyCode.value.isNotEmpty && localCurrencyCode.value != 'USD';

  Future<void> toggleCurrencyDisplay() async {
    if (isToggling.value) return;
    isToggling.value = true;
    await Future.delayed(const Duration(milliseconds: 150));
    showLocalCurrency.value = !showLocalCurrency.value;
    await Future.delayed(const Duration(milliseconds: 150));
    isToggling.value = false;
  }

  Future<void> refreshRates() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await _currencyService.fetchRates(forceRefresh: true);
      _updateLocalRate();
    } finally {
      isRefreshing.value = false;
    }
  }

  bool get hasRates => _currencyService.hasRates;
}
