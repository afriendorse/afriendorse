import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/suggest_service/model/suggest_service_model.dart';
import 'package:get/get.dart';

class SuggestServiceController extends GetxController implements GetxService {
  final SuggestServiceRepo suggestServiceRepo;
  SuggestServiceController({required this.suggestServiceRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isShowInputField = false;
  bool get isShowInputField => _isShowInputField;

  bool _isCategoryValidate = true;
  bool get isCategoryValidate => _isCategoryValidate;

  double initialButtonPadding = 230;
  double initialContainerOpacity = 0.0;
  double initialImageSize = 100.0;
  String selectedCategoryName = "";
  String selectedCategoryId = "";

  List<ServiceCategoryModel> serviceCategoryList = [];
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController serviceDetailsController = TextEditingController();

  List<SuggestedService> suggestedServiceList = [];
  SuggestedServiceModel? suggestedServiceModel;

  @override
  void onInit() {
    super.onInit();
    getCategoryList();
  }

  Future<void> getCategoryList() async {
    Response response = await suggestServiceRepo.getCategoryList();
    if (response.statusCode == 200) {
      serviceCategoryList = [];
      List<dynamic> list = response.body['content']['data'];
      for (var category in list) {
        serviceCategoryList.add(ServiceCategoryModel.fromJson(category));
      }

      serviceCategoryList.add(ServiceCategoryModel(name: "others".tr));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSuggestedServiceList(int offset, {reload = false}) async {
    if (reload) {
      suggestedServiceModel = null;
    }
    Response response = await suggestServiceRepo.getSuggestedServiceList(
      offset,
    );
    if (response.statusCode == 200) {
      suggestedServiceModel = SuggestedServiceModel.fromJson(response.body);
      if (offset != 1) {
        suggestedServiceList.addAll(
          suggestedServiceModel!.content!.suggestedServiceList!,
        );
      } else {
        suggestedServiceList = [];
        suggestedServiceList.addAll(
          suggestedServiceModel!.content!.suggestedServiceList!,
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> submitNewServiceRequest() async {
    _isLoading = true;
    update();

    Map<String, String> body = {
      "category_id": selectedCategoryId,
      "service_name": serviceNameController.text,
      "service_description": serviceDetailsController.text,
    };
    Response response = await suggestServiceRepo.submitNewServiceRequest(body);
    if (response.statusCode == 200) {
      clearData();
      showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: false));
      updateShowInputField(
        shouldUpdate: false,
        showInputField: false,
        buttonPadding: 230,
        opacity: 0.0,
        imageSize: 100,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void updateShowInputField({
    bool showInputField = true,
    double buttonPadding = 570,
    double imageSize = 70,
    double opacity = 1.0,
    bool shouldUpdate = true,
  }) {
    _isShowInputField = showInputField;
    if (shouldUpdate) {
      update();
    }

    initialButtonPadding = buttonPadding;
    initialImageSize = imageSize;
    initialContainerOpacity = opacity;

    if (shouldUpdate) {
      update();
    }
  }

  void updateSelectedCategory(ServiceCategoryModel? serviceCategoryModel) {
    selectedCategoryName = serviceCategoryModel?.id == null ? "others".tr : "";
    selectedCategoryId = "";

    for (var element in serviceCategoryList) {
      if (element.id == serviceCategoryModel?.id) {
        selectedCategoryName = element.name ?? "";
        selectedCategoryId = element.id ?? "";
      }
    }
    update();
  }

  clearData() {
    serviceNameController.text = "";
    serviceDetailsController.text = "";
    selectedCategoryName = "";
    selectedCategoryId = "";
  }

  updateCategoryValidateValue({
    bool shouldUpdate = true,
    bool isInitial = false,
  }) {
    if (selectedCategoryName != "" || isInitial) {
      _isCategoryValidate = true;
    } else {
      _isCategoryValidate = false;
    }
    if (shouldUpdate) {
      update();
    }
  }
}
