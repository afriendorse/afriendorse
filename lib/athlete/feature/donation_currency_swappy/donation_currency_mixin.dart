// lib/shared/donation_currency_mixin.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_controller.dart';
import 'package:get/get.dart';

/// Resolves the correct currency controller regardless of
/// which user role (fan / brand / athlete) is donating.
mixin DonationCurrencyMixin {
  // ── Getters ──────────────────────────────────────────────────────────────

  /// Returns true if any currency controller is available and loaded
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

  // ── Methods ───────────────────────────────────────────────────────────────

  /// Get formatted local equivalent e.g. "₦2,450,000.00"
  String getLocalEquivalent(double usdAmount) {
    final ctrl = _resolveCtrl();
    if (ctrl == null) return '';
    return ctrl.getLocalEquivalent(usdAmount);
  }

  /// Convert USD to local
  double convertToLocal(double usdAmount) {
    return _resolveCtrl()?.convertToLocal(usdAmount) ?? usdAmount;
  }

  /// Toggle USD ⇄ local display
  Future<void> toggleCurrencyDisplay() async {
    await _resolveCtrl()?.toggleCurrencyDisplay();
  }

  /// Force refresh rates
  Future<void> refreshRates() async {
    await _resolveCtrl()?.refreshRates();
  }

  // ── Private resolver ──────────────────────────────────────────────────────

  /// Priority: AthleteCurrencyController → CurrencyController → null
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

/// Internal proxy — normalizes both controllers to a common interface
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
