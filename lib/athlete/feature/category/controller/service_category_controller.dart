import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceCategoryController extends GetxController implements GetxService {
  final ServiceRepo serviceRepo;
  ServiceCategoryController({required this.serviceRepo});

  int _selectedCategoryIndex = 0;
  int _selectedSubsCategoryIndex = 0;
  int _subscriptionIndex = -1;
  int get selectedSubscriptionIndex => _subscriptionIndex;

  int get selectedCategory => _selectedCategoryIndex;
  int get selectedSubsCategoryIndex => _selectedSubsCategoryIndex;

  bool _isSubCategoryLoading = false;
  bool _isSubscriptionLoading = false;
  bool _isPaginationLoading = false;
  int? subscriptionStatus;

  bool get isSubCategoryLoading => _isSubCategoryLoading;
  bool get isSubscriptionLoading => _isSubscriptionLoading;
  bool get isPaginationLoading => _isPaginationLoading;

  List<ServiceCategoryModel>? serviceCategoryList;
  List<ServiceSubCategoryModel> serviceSubCategoryList = [];

  List<ServiceModel>? _serviceList;
  List<ServiceModel>? get serviceList => _serviceList;

  List<ServiceModel>? _searchServiceList;
  List<ServiceModel>? get searchServiceList => _searchServiceList;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  int _offset = 1;
  int get offset => _offset;

  int _pageSize = 1;
  int get pageSize => _pageSize;

  final ScrollController scrollController = ScrollController();
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize) {
          if (serviceCategoryList != null && serviceCategoryList!.isNotEmpty)
            getSubCategoryList(offset: _offset + 1, isFromPagination: true);
        }
      }
    });
  }

  Future<void> getCategoryList({
    bool shouldUpdate = true,
    bool reloadSubcategory = false,
  }) async {
    serviceCategoryList = null;
    Response response = await serviceRepo.getCategoryList();
    if (response.statusCode == 200) {
      serviceCategoryList = [];
      List<dynamic> list = response.body['content']['data'];
      for (var category in list) {
        serviceCategoryList!.add(ServiceCategoryModel.fromJson(category));
      }

      if ((serviceCategoryList!.isNotEmpty && serviceSubCategoryList.isEmpty) ||
          reloadSubcategory) {
        getSubCategoryList(offset: 1, isFromPagination: false);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  int _subcategoryApitHitCount = 0;

  Future<void> getSubCategoryList({
    required int offset,
    bool isFromPagination = false,
    String? categoryId,
  }) async {
    _subcategoryApitHitCount++;
    _offset = offset;
    if (!isFromPagination) {
      serviceSubCategoryList = [];
      _isSubCategoryLoading = true;
      update();
    }
    _isPaginationLoading = true;
    update();

    Response response = await serviceRepo.getSubCategoryList(
      serviceCategoryList?[selectedCategory].id.toString() ?? "",
      offset,
    );
    if (response.statusCode == 200) {
      if (!isFromPagination) {
        serviceSubCategoryList = [];
      }

      List<dynamic> list = response.body['content']['data'];
      for (var subCategory in list) {
        serviceSubCategoryList.add(
          ServiceSubCategoryModel.fromJson(subCategory),
        );
      }
      _pageSize = response.body['content']['last_page'];
    } else {
      ApiChecker.checkApi(response);
    }
    _subcategoryApitHitCount--;
    _isSubCategoryLoading = false;
    _isPaginationLoading = false;

    if (_subcategoryApitHitCount == 0) {
      update();
    }
  }

  Future<ResponseModel> changeSubscriptionStatus(
    String id,
    int index, {
    String fromPage = "",
  }) async {
    _isSubscriptionLoading = true;
    update();
    Response response = await serviceRepo.changeSubscriptionStatus(id);

    if (response.statusCode == 200) {
      if (fromPage == "category") {
        int statusValue = serviceSubCategoryList[index].isSubscribed == 1
            ? 0
            : 1;
        serviceSubCategoryList[index].isSubscribed = statusValue;

        Get.find<DashboardController>().getDashboardData();
        Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(
          id,
        );
      } else if (fromPage == "dashboard") {
        Get.find<DashboardController>().removeSubscriptionItem(id);
        Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(
          id,
        );
        Get.back();
      } else if (fromPage == "subscription_list") {
        Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(
          id,
        );
        Get.find<DashboardController>().removeSubscriptionItem(id);
      } else if (fromPage == "subscription_details") {
        Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(
          id,
        );
        Get.find<DashboardController>().removeSubscriptionItem(id);
        Get.back();
      } else {}
      changeSubscriptionIndex(-1);
      _isSubscriptionLoading = false;
      update();

      return ResponseModel(true, "${response.body['message']}");
    } else {
      changeSubscriptionIndex(-1);
      _isSubscriptionLoading = false;
      update();
      return ResponseModel(false, "${response.body['message']}");
    }
  }

  Future<void> getServiceListBasedOnSubcategory({
    required String subCategoryId,
    bool shouldUpdate = false,
  }) async {
    _serviceList = null;
    _searchServiceList = null;
    if (shouldUpdate) {
      update();
    }

    Response response = await serviceRepo.getServiceListBasedOnSubcategory(
      subCategoryId,
    );
    if (response.statusCode == 200) {
      List<dynamic> list = response.body['content']['data'];
      _serviceList = [];
      for (var service in list) {
        _serviceList?.add(ServiceModel.fromJson(service));
      }
    } else {
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getSearchedServiceListBasedOnSubcategory({
    required String subCategoryId,
    bool shouldUpdate = false,
    String? queryText,
  }) async {
    _searchServiceList = null;
    _isSearchComplete = false;
    update();

    Response response = await serviceRepo.getServiceListBasedOnSubcategory(
      subCategoryId,
      queryText: queryText ?? "",
    );
    if (response.statusCode == 200) {
      List<dynamic> list = response.body['content']['data'];
      _searchServiceList = [];
      for (var service in list) {
        _searchServiceList?.add(ServiceModel.fromJson(service));
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isSearchComplete = true;
    update();
  }

  void changeCategory(int categoryIndex, {bool isUpdate = true}) {
    _selectedCategoryIndex = categoryIndex;
    if (isUpdate) {
      update();
    }
  }

  void changeSubscriptionCategoryIndex(
    int categoryIndex, {
    bool isUpdate = true,
  }) {
    _selectedSubsCategoryIndex = categoryIndex;
    if (isUpdate) {
      update();
    }
  }

  void changeSubscriptionIndex(int subscriptionIndex) {
    _subscriptionIndex = subscriptionIndex;
    update();
  }

  void toggleSubscriptionStatus(int subscriptionStatus) {
    subscriptionStatus = subscriptionStatus;
    update();
  }

  void showSuffixIcon(context, String text) {
    if (text.isNotEmpty) {
      _isActiveSuffixIcon = true;
    } else if (text.isEmpty) {
      _isActiveSuffixIcon = false;
    }
    update();
  }

  void clearSearchController({bool shouldUpdate = true}) {
    searchController.clear();
    _isSearchComplete = true;
    _searchServiceList = null;
    _isActiveSuffixIcon = false;
    if (shouldUpdate) {
      update();
    }
  }
}
