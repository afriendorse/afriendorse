import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ProviderFavoriteStateController extends GetxController
    implements GetxService {
  final MyFavoriteRepo myFavoriteRepo;

  ProviderFavoriteStateController({required this.myFavoriteRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Set<String> _favoriteProviderIds = <String>{};
  Set<String> get favoriteProviderIds => _favoriteProviderIds;

  bool isFavorite(String providerId) =>
      _favoriteProviderIds.contains(providerId);

  /// Load ALL favorite providers (pagination) so hearts render correctly
  Future<void> loadFavorites({bool reload = false, int maxPages = 50}) async {
    if (_isLoading) return;

    if (!Get.find<AuthController>().isLoggedIn()) {
      _favoriteProviderIds.clear();
      update();
      return;
    }

    if (_favoriteProviderIds.isNotEmpty && !reload) return;

    _isLoading = true;
    update();

    try {
      _favoriteProviderIds.clear();

      int page = 1;
      int lastPage = 1;

      while (page <= lastPage && page <= maxPages) {
        final Response res = await myFavoriteRepo.getFavoriteProviderList(page);

        if (res.statusCode != 200) {
          ApiChecker.checkApi(res);
          break;
        }

        final model = ProviderModel.fromJson(res.body);
        final list = model.content?.data ?? const <ProviderData>[];

        for (final p in list) {
          final id = p.id;
          if (id != null && id.isNotEmpty) {
            _favoriteProviderIds.add(id);
          }
        }

        lastPage = model.content?.lastPage ?? lastPage;
        page++;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProviderFavoriteStateController.loadFavorites error: $e');
      }
    }

    _isLoading = false;
    update();
  }

  /// Toggle favorite using your SQL endpoint:
  /// POST AppConstants.updateFavoriteProviderStatus { provider_id: X }
  Future<void> toggleFavorite(String providerId) async {
    if (!Get.find<AuthController>().isLoggedIn()) {
      customSnackBar(
        type: ToasterMessageType.info,
        "please_login_to_add_favorite_list".tr,
      );
      return;
    }

    // Optimistic UI update
    final bool wasFav = isFavorite(providerId);
    if (wasFav) {
      _favoriteProviderIds.remove(providerId);
    } else {
      _favoriteProviderIds.add(providerId);
    }
    update();

    try {
      final Response res = await myFavoriteRepo.toggleFavoriteProvider(
        providerId,
      );

      if (res.statusCode == 200) {
        // Optional: keep other places in sync
        if (Get.isRegistered<ProviderBookingController>()) {
          Get.find<ProviderBookingController>().updateProviderIsFavoriteValue(
            wasFav ? 0 : 1,
            providerId,
            shouldUpdate: true,
          );
        }

        // Optional: refresh MyFavoriteController lists if it exists
        if (Get.isRegistered<MyFavoriteController>()) {
          // Background refresh (safe)
          Get.find<MyFavoriteController>().getProviderList(1, true);
        }

        return;
      }

      // rollback on failure
      if (wasFav) {
        _favoriteProviderIds.add(providerId);
      } else {
        _favoriteProviderIds.remove(providerId);
      }
      update();

      ApiChecker.checkApi(res);
    } catch (e) {
      // rollback on exception
      if (wasFav) {
        _favoriteProviderIds.add(providerId);
      } else {
        _favoriteProviderIds.remove(providerId);
      }
      update();

      if (kDebugMode) {
        print('❌ ProviderFavoriteStateController.toggleFavorite error: $e');
      }
    }
  }

  void clear() {
    _favoriteProviderIds.clear();
    update();
  }
}
