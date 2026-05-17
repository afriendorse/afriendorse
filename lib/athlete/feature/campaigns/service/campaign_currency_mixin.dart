// lib/athlete/feature/campaigns/utils/campaign_currency_mixin.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Currency support for campaign donation screens
/// Ensures controller is ready before any screen uses it
mixin CampaignCurrencyMixin {
  /// Call this in initState() of campaign donation screens
  void ensureCampaignCurrencyReady() {
    // Ensure CurrencyService singleton exists
    if (!Get.isRegistered<CurrencyService>()) {
      Get.put<CurrencyService>(CurrencyService(), permanent: true);
    }

    // Check if either controller already exists and is loaded
    if (Get.isRegistered<AthleteCurrencyController>()) {
      final c = Get.find<AthleteCurrencyController>();
      if (!c.isLoadingRates.value && c.hasLocalCurrency) return;
    }

    if (Get.isRegistered<CurrencyController>()) {
      final c = Get.find<CurrencyController>();
      if (!c.isLoadingRates.value && c.hasLocalCurrency) return;
    }

    // Register based on active session
    try {
      // Check for athlete session
      Get.find(tag: 'athlete_profile_controller');
      if (!Get.isRegistered<AthleteCurrencyController>()) {
        Get.put<AthleteCurrencyController>(
          AthleteCurrencyController(),
          permanent: false,
        );
      }
      if (kDebugMode) {
        print('[CampaignCurrency] Athlete controller initialized');
      }
      return;
    } catch (_) {}

    // Fan/brand session
    if (!Get.isRegistered<CurrencyController>()) {
      Get.put<CurrencyController>(CurrencyController(), permanent: false);
      if (kDebugMode) {
        print('[CampaignCurrency] Fan/brand controller initialized');
      }
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  bool get hasCurrencySupport {
    final ctrl = _resolveCtrl();
    return ctrl != null && !ctrl.isLoadingRates && ctrl.hasLocalCurrency;
  }

  bool get isLoadingCurrency {
    return _resolveCtrl()?.isLoadingRates ?? false;
  }

  bool get hasLocalCurrency {
    return _resolveCtrl()?.hasLocalCurrency ?? false;
  }

  String get localCurrencyCode {
    return _resolveCtrl()?.localCurrencyCode ?? 'USD';
  }

  String get localCurrencySymbol {
    return _resolveCtrl()?.localCurrencySymbol ?? '\$';
  }

  String get localCountryFlag {
    return _resolveCtrl()?.localCountryFlag ?? '';
  }

  String get rateLabel {
    return _resolveCtrl()?.rateLabel ?? '';
  }

  bool get showLocalCurrency {
    return _resolveCtrl()?.showLocalCurrency ?? false;
  }

  // ── Methods ──────────────────────────────────────────────────────────────

  String getLocalEquivalent(double usdAmount) {
    final ctrl = _resolveCtrl();
    if (ctrl == null) return '';
    return ctrl.getLocalEquivalent(usdAmount);
  }

  double convertToLocal(double usdAmount) {
    return _resolveCtrl()?.convertToLocal(usdAmount) ?? usdAmount;
  }

  Future<void> toggleCurrencyDisplay() async {
    await _resolveCtrl()?.toggleCurrencyDisplay();
  }

  Future<void> refreshRates() async {
    await _resolveCtrl()?.refreshRates();
  }

  // ── Private resolver ─────────────────────────────────────────────────────

  _CurrencyCtrlProxy? _resolveCtrl() {
    if (Get.isRegistered<AthleteCurrencyController>()) {
      final c = Get.find<AthleteCurrencyController>();
      return _CurrencyCtrlProxy(
        isLoadingRates: c.isLoadingRates.value,
        hasLocalCurrency: c.hasLocalCurrency,
        localCurrencyCode: c.localCurrencyCode.value,
        localCurrencySymbol: c.localCurrencySymbol.value,
        localCountryFlag: c.localCountryFlag.value,
        rateLabel: c.rateLabel,
        showLocalCurrency: c.showLocalCurrency.value,
        getLocalEquivalent: c.getLocalEquivalent,
        convertToLocal: c.convertToLocal,
        toggleCurrencyDisplay: c.toggleCurrencyDisplay,
        refreshRates: c.refreshRates,
      );
    }
    if (Get.isRegistered<CurrencyController>()) {
      final c = Get.find<CurrencyController>();
      return _CurrencyCtrlProxy(
        isLoadingRates: c.isLoadingRates.value,
        hasLocalCurrency: c.hasLocalCurrency,
        localCurrencyCode: c.localCurrencyCode.value,
        localCurrencySymbol: c.localCurrencySymbol.value,
        localCountryFlag: c.localCountryFlag.value,
        rateLabel: c.rateLabel,
        showLocalCurrency: c.showLocalCurrency.value,
        getLocalEquivalent: c.getLocalEquivalent,
        convertToLocal: c.convertToLocal,
        toggleCurrencyDisplay: c.toggleCurrencyDisplay,
        refreshRates: c.refreshRates,
      );
    }
    return null;
  }
}

class _CurrencyCtrlProxy {
  final bool isLoadingRates;
  final bool hasLocalCurrency;
  final String localCurrencyCode;
  final String localCurrencySymbol;
  final String localCountryFlag;
  final String rateLabel;
  final bool showLocalCurrency;
  final String Function(double) getLocalEquivalent;
  final double Function(double) convertToLocal;
  final Future<void> Function() toggleCurrencyDisplay;
  final Future<void> Function() refreshRates;

  const _CurrencyCtrlProxy({
    required this.isLoadingRates,
    required this.hasLocalCurrency,
    required this.localCurrencyCode,
    required this.localCurrencySymbol,
    required this.localCountryFlag,
    required this.rateLabel,
    required this.showLocalCurrency,
    required this.getLocalEquivalent,
    required this.convertToLocal,
    required this.toggleCurrencyDisplay,
    required this.refreshRates,
  });
}
