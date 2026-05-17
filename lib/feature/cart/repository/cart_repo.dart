import 'package:afriendorse/common/models/api_response_model.dart';
import 'package:afriendorse/common/repo/data_sync_repo.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class CartRepo extends DataSyncRepo {
  CartRepo({
    required super.apiClient,
    required SharedPreferences super.sharedPreferences,
  });

  Future<Response> addToCartListToServer(CartModelBody cartModel) async {
    return await apiClient.postData(AppConstants.addToCart, cartModel.toJson());
  }

  Future<ApiResponseModel<T>> getCartListFromServer<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(
      "${AppConstants.getCartList}&&guest_id=${Get.find<SplashController>().getGuestId()}",
      source,
    );
  }

  Future<Response> removeCartFromServer(String cartID) async {
    return await apiClient.postData(
      "${AppConstants.removeCartItem}$cartID?guest_id=${Get.find<SplashController>().getGuestId()}",
      {"_method": "delete"},
    );
  }

  Future<Response> removeAllCartFromServer() async {
    return await apiClient.postData(
      "${AppConstants.removeAllCartItem}?guest_id=${Get.find<SplashController>().getGuestId()}",
      {"_method": "delete"},
    );
  }

  Future<Response> updateCartQuantity(String cartID, int quantity) async {
    return await apiClient.postData(
      "${AppConstants.updateCartQuantity}$cartID?guest_id=${Get.find<SplashController>().getGuestId()}",
      {'quantity': quantity, "_method": "put"},
    );
  }

  Future<Response> updateProvider(String providerId) async {
    return await apiClient.postData(AppConstants.updateCartProvider, {
      'provider_id': providerId,
      "_method": "put",
      "guest_id": Get.find<SplashController>().getGuestId(),
    });
  }

  Future<Response> getProviderBasedOnSubcategory(String subcategoryId) async {
    return await apiClient.getData(
      "${AppConstants.getProviderBasedOnSubcategory}?sub_category_id=$subcategoryId",
    );
  }

  Future<Response> addRebookToServer(String bookingId) async {
    return await apiClient.postData(AppConstants.rebookApi, {
      'booking_id': bookingId,
      'guest_id': Get.find<SplashController>().getGuestId(),
    });
  }
}
