// lib/athlete/feature/wallet/binding/athlete_wallet_binding.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:get/get.dart';

class AthleteWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);

    // CurrencyService is a singleton — safe to re-register,
    // it returns the same instance every time
    Get.lazyPut<CurrencyService>(() => CurrencyService(), fenix: true);

    Get.lazyPut<AthleteCurrencyController>(
      () => AthleteCurrencyController(),
      fenix: true,
    );
  }
}
