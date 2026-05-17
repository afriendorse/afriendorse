import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Fan/brand session
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as fan_ctrl;
// Athlete session (in case athlete visits fan donation screen)
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_ctrl;

class CurrencyController extends GetxController {
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
      await _resolveUserCurrency();
      await _currencyService.fetchRates();
      _updateLocalRate();
    } catch (e) {
      errorMessage.value = 'Could not load exchange rates';
      if (kDebugMode) print('[CurrencyController] init error: $e');
    } finally {
      isLoadingRates.value = false;
    }
  }

  Future<void> _resolveUserCurrency() async {
    // ── Strategy 1: fan/brand session phone ─────────────────────────────
    final fanPhone = _phoneFromFanSession();
    if (fanPhone != null && fanPhone.isNotEmpty) {
      if (kDebugMode) {
        print('[CurrencyController] phone from fan session: $fanPhone');
      }
      if (_applyPhone(fanPhone)) return;
    }

    // ── Strategy 2: athlete session phone ────────────────────────────────
    final athletePhone = _phoneFromAthleteSession();
    if (athletePhone != null && athletePhone.isNotEmpty) {
      if (kDebugMode) {
        print('[CurrencyController] phone from athlete session: $athletePhone');
      }
      if (_applyPhone(athletePhone)) return;
    }

    // ── Strategy 3: Firebase Auth → Firestore ────────────────────────────
    final authEmail = FirebaseAuth.instance.currentUser?.email
        ?.toLowerCase()
        .trim();
    if (authEmail != null && authEmail.isNotEmpty) {
      final phone = await _fetchPhoneFromFirestore(authEmail);
      if (phone != null && phone.isNotEmpty) {
        if (kDebugMode) {
          print('[CurrencyController] phone from Firestore: $phone');
        }
        if (_applyPhone(phone)) return;
      }
    }

    // ── Strategy 4: session email → Firestore ────────────────────────────
    final sessionEmail = _emailFromAnySession();
    if (sessionEmail != null &&
        sessionEmail.isNotEmpty &&
        sessionEmail != authEmail) {
      final phone = await _fetchPhoneFromFirestore(sessionEmail);
      if (phone != null && phone.isNotEmpty) {
        if (_applyPhone(phone)) return;
      }
    }

    if (kDebugMode) {
      print('[CurrencyController] all strategies exhausted → USD fallback');
    }
    _setUsdFallback();
  }

  String? _phoneFromFanSession() {
    try {
      if (!Get.isRegistered<fan_ctrl.UserController>()) return null;
      final phone = Get.find<fan_ctrl.UserController>().userInfoModel?.phone;
      if (phone != null && phone.trim().isNotEmpty) return phone.trim();
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _phoneFromAthleteSession() {
    try {
      if (!Get.isRegistered<athlete_ctrl.UserProfileController>()) {
        return null;
      }
      final ctrl = Get.find<athlete_ctrl.UserProfileController>();
      final ownerPhone =
          ctrl.providerModel?.content?.providerInfo?.owner?.phone;
      if (ownerPhone != null && ownerPhone.trim().isNotEmpty) {
        return ownerPhone.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _emailFromAnySession() {
    try {
      if (Get.isRegistered<fan_ctrl.UserController>()) {
        final email = Get.find<fan_ctrl.UserController>().userInfoModel?.email;
        if (email != null && email.isNotEmpty) {
          return email.toLowerCase().trim();
        }
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<athlete_ctrl.UserProfileController>()) {
        final email = Get.find<athlete_ctrl.UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo
            ?.owner
            ?.email;
        if (email != null && email.isNotEmpty) {
          return email.toLowerCase().trim();
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String?> _fetchPhoneFromFirestore(String email) async {
    final lower = email.toLowerCase().trim();
    try {
      // users collection (fan/brand)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(lower)
          .get();
      if (kDebugMode) {
        print('[CurrencyController] users/$lower exists: ${userDoc.exists}');
        if (userDoc.exists) {
          print('[CurrencyController] user data: ${userDoc.data()}');
        }
      }
      final userPhone = userDoc.data()?['phone'] as String?;
      if (userPhone != null && userPhone.trim().isNotEmpty) {
        return userPhone.trim();
      }

      // athletes collection fallback
      final athleteDoc = await FirebaseFirestore.instance
          .collection('athletes')
          .doc(lower)
          .get();
      final athletePhone = athleteDoc.data()?['phone'] as String?;
      if (athletePhone != null && athletePhone.trim().isNotEmpty) {
        return athletePhone.trim();
      }

      // Query by email field
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
      if (kDebugMode) print('[CurrencyController] Firestore error: $e');
    }
    return null;
  }

  bool _applyPhone(String phone) {
    final currencyInfo = CurrencyService.resolveCurrencyFromPhone(phone);
    if (kDebugMode) {
      print(
        '[CurrencyController] resolveCurrencyFromPhone("$phone") → $currencyInfo',
      );
    }
    if (currencyInfo == null) return false;

    localCurrencyCode.value = currencyInfo['currency'] ?? 'USD';
    localCurrencySymbol.value = currencyInfo['symbol'] ?? '\$';
    localCountryName.value = currencyInfo['country'] ?? '';
    localCountryFlag.value = currencyInfo['flag'] ?? '';

    if (kDebugMode) {
      print(
        '[CurrencyController] ✅ Resolved: '
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
