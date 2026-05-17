import 'package:afriendorse/feature/currency_swapper/currency_controller.dart';
import 'package:afriendorse/feature/currency_swapper/currency_service.dart';
import 'package:afriendorse/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/feature/wallet/repository/wallet_repo.dart';

import 'package:get/get.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WalletController(
        walletRepo: WalletRepo(
          apiClient: Get.find(),
          sharedPreferences: Get.find(),
        ),
      ),
    );

    // Currency service is a singleton — safe to register here
    Get.lazyPut<CurrencyService>(
      () => CurrencyService(),
      fenix: true, // keeps it alive across wallet screen visits
    );

    Get.lazyPut<CurrencyController>(
      () => CurrencyController(),
      fenix:
          true, // reinitializes if disposed, without re-fetching if cache is fresh
    );
  }
}
