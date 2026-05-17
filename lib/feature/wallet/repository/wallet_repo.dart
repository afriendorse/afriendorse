import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class WalletRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WalletRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getWalletTransactionData(int offset, String type) async {
    return await apiClient.getData(
      '${AppConstants.walletTransactionData}?limit=10&offset=$offset&type=$type',
    );
  }

  Future<Response> getBonusList() async {
    return await apiClient.getData(AppConstants.bonusUri);
  }

  /// Deducts [amount] from the authenticated user's MySQL wallet.
  /// Returns the new balance on success, null on failure.
  /// Handles 422 (insufficient balance) silently — caller shows the message.
  Future<double?> deductWalletFunds({
    required double amount,
    required String purpose,
  }) async {
    try {
      final Response response = await apiClient.postData(
        AppConstants.walletDeductUri,
        {'amount': amount, 'purpose': purpose},
      );

      if (response.statusCode == 200) {
        final newBalance = double.tryParse(
          response.body['content']['wallet_balance'].toString(),
        );
        if (kDebugMode) {
          print('[WalletRepo] deduct success — new balance: $newBalance');
        }
        return newBalance;
      } else if (response.statusCode == 422) {
        // Insufficient balance — return null silently.
        // DO NOT call ApiChecker here — it would show a generic snackbar.
        // GroupPaymentController shows the correct user-facing message.
        if (kDebugMode) {
          print('[WalletRepo] deduct: insufficient balance');
        }
        return null;
      } else if (response.statusCode == 1) {
        // No internet — apiClient already returns statusCode 1 for timeouts
        if (kDebugMode) {
          print('[WalletRepo] deduct: no internet / timeout');
        }
        return null;
      } else {
        // Any other unexpected error — let ApiChecker handle it normally
        ApiChecker.checkApi(response);
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('[WalletRepo] deductWalletFunds error: $e');
      return null;
    }
  }

  Future<void> setWalletAccessToken(String token) {
    return sharedPreferences.setString(AppConstants.walletAccessToken, token);
  }

  String getWalletAccessToken() {
    return sharedPreferences.getString(AppConstants.walletAccessToken) ?? '';
  }
}
