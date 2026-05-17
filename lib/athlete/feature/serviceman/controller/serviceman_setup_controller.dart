import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServicemanSetupController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ServicemanRepo servicemanRepo;
  ServicemanSetupController({required this.servicemanRepo});

  XFile? _pickedProfileImage;
  XFile? get pickedProfileImage => _pickedProfileImage;

  List<MultipartBody> _selectedIdentityImageList = [];
  List<MultipartBody> get selectedIdentityImageList =>
      _selectedIdentityImageList;

  int selectedIndex = -1;
  int? currentServicemanIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProfilePicValid = true;
  bool get isProfilePicValid => _isProfilePicValid;

  bool _isServicemanIdentityImageValid = true;
  bool get isServicemanIdentityImageValid => _isServicemanIdentityImageValid;

  bool _isIdentityTypeValid = true;
  bool get isIdentityTypeValid => _isIdentityTypeValid;

  final bool _loading = false;
  bool get loading => _loading;

  String selectedIdentityType = "";

  String _profileImage = '';
  String get profileImage => _profileImage;

  List<String> _identificationImage = [];
  List<String> get identificationImage => _identificationImage;

  List<ServicemanModel>? _servicemanList;
  List<ServicemanModel>? get servicemanList => _servicemanList;

  bool _isFromBookingDetailsPage = false;
  bool get isFromBookingDetailsPage => _isFromBookingDetailsPage;

  final GlobalKey<FormState> addServiceManAccountInfoValidation =
      GlobalKey<FormState>();
  final GlobalKey<FormState> addServiceManGeneralInfoValidation =
      GlobalKey<FormState>();

  int _offset = 1;
  int get offset => _offset;

  int _pageSize = 1;
  int get pageSize => _pageSize;

  int _totalServiceman = 0;
  int get totalServiceman => _totalServiceman;

  bool _isGeneralInfoValid = false;
  bool get isGeneralInfoValid => _isGeneralInfoValid;

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneController = TextEditingController();
  var identityNumberController = TextEditingController();
  var emailController = TextEditingController();
  var passController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  String? countryDialCode = "+880";

  var servicemanPageCurrentState = ServicemanTabControllerState.generalInfo;
  ScrollController scrollController = ScrollController();
  TabController? controller;

  List<Widget> servicemanDetailsTabs = [
    SizedBox(
      width: Get.width * .45,
      child: Tab(text: 'general_info'.tr),
    ),
    SizedBox(
      width: Get.width * .45,
      child: Tab(text: 'account_info'.tr),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (_offset < _pageSize) {
          getAllServicemanList(_offset + 1, reload: false);
        }
      }
    });
    controller = TabController(
      vsync: this,
      length: servicemanDetailsTabs.length,
      initialIndex: 0,
    );
    selectedIndex = -1;
    countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content!.countryCode!,
        ).dialCode ??
        "+880";
  }

  Future<void> assignServiceman({
    String? bookingId,
    String? subBookingId,
    required String servicemanId,
    bool reAssignServiceman = false,
  }) async {
    _isLoading = true;
    update();
    Response response = await servicemanRepo.assignServiceman(
      bookingId: bookingId,
      subBookingId: subBookingId,
      servicemanId: servicemanId,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == "serviceman_assign_success_200") {
      if (bookingId != null) {
        Get.find<BookingDetailsController>().getBookingDetails(
          bookingId,
          reload: false,
        );
      } else if (subBookingId != null) {
        Get.find<BookingDetailsController>().getBookingSubDetails(
          subBookingId,
          reload: false,
        );
      }
      Get.find<BookingDetailsController>().showHideExpandView(0);
      if (_isFromBookingDetailsPage && reAssignServiceman) {
        showCustomSnackBar(
          "service_man_re_assigned_successfully".tr,
          type: ToasterMessageType.success,
        );
      } else {
        showCustomSnackBar(
          "service_man_assigned_successfully".tr,
          type: ToasterMessageType.success,
        );
      }
    } else {
      Get.find<BookingDetailsController>().showHideExpandView(0);
      if (bookingId != null) {
        Get.find<BookingDetailsController>().getBookingDetails(
          bookingId,
          reload: false,
        );
      } else if (subBookingId != null) {
        Get.find<BookingDetailsController>().getBookingSubDetails(
          subBookingId,
          reload: false,
        );
      }
      showCustomSnackBar(response.body["message"].toString().capitalizeFirst);
    }

    _isLoading = false;
    update();
  }

  Future<void> addNewServiceman(ServicemanBody servicemanBody) async {
    _isLoading = true;
    update();
    Response? response = await servicemanRepo.addNewServiceman(
      servicemanBody,
      pickedProfileImage,
      _selectedIdentityImageList,
    );
    if (response!.statusCode == 200) {
      _selectedIdentityImageList = [];
      showCustomSnackBar(
        'serviceman_added_successfully'.tr,
        type: ToasterMessageType.success,
      );

      if (_isFromBookingDetailsPage) {
        await getAllServicemanList(1, reload: true, status: "active");
      } else {
        await getAllServicemanList(1, reload: true);
      }
      Get.find<DashboardController>().getDashboardData();
      clearAllData();
      Get.back();
    } else if (response.statusCode == 400) {
      showCustomSnackBar(response.body['errors'][0]['message']);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> editServicemanInfoWithPassword(
    ServicemanBody servicemanBody,
    String servicemanId,
  ) async {
    _isLoading = true;
    update();

    Response? response = await servicemanRepo.editServicemanInfoWithPassword(
      servicemanBody,
      pickedProfileImage,
      null,
      servicemanId,
    );

    confirmPasswordController.text = '';
    passController.text = '';

    if (response!.statusCode == 200) {
      selectedIndex = -1;
      Get.back();
      showCustomSnackBar(
        'serviceman_password_updated'.tr,
        type: ToasterMessageType.success,
      );
      getAllServicemanList(1, reload: true);
    } else if (response.statusCode == 400) {
      showCustomSnackBar('something_went_wrong'.tr);
    } else {
      showCustomSnackBar('something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  Future<void> editServicemanInfoWithoutPassword(
    ServicemanBody servicemanBody,
    String servicemanId,
  ) async {
    _isLoading = true;
    update();

    Response? response = await servicemanRepo.editServicemanInfoWithoutPassword(
      servicemanBody,
      pickedProfileImage,
      _selectedIdentityImageList,
      servicemanId,
    );
    _selectedIdentityImageList = [];
    if (response!.statusCode == 200) {
      selectedIndex = -1;
      getAllServicemanList(1, reload: true);
      Get.find<ServicemanDetailsController>().getServicemanDetails(
        servicemanId,
      );
      Get.back();
      showCustomSnackBar(
        'serviceman_info_updated'.tr,
        type: ToasterMessageType.success,
      );
    } else if (response.statusCode == 400) {
      if (response.body['errors'][0]['error_code'] == 'email') {
        showCustomSnackBar("the_account_email_has_already_been_taken".tr);
      } else if (response.body['errors'][0]['error_code'] == 'phone') {
        showCustomSnackBar("the_account_phone_has_already_been_taken".tr);
      } else {
        showCustomSnackBar("something_went_wrong".tr);
      }
    } else {
      showCustomSnackBar('something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  Future<void> getAllServicemanList(
    int offset, {
    bool reload = false,
    String status = 'all',
  }) async {
    _offset = offset;
    if (reload || _servicemanList == null) {
      Response response = await servicemanRepo.getAllServicemanData(
        offset,
        status,
      );
      if (response.statusCode == 200) {
        if (_offset == 1) {
          _servicemanList = [];
          List<dynamic> list = response.body['content']['data'];
          for (var serviceman in list) {
            servicemanList?.add(ServicemanModel.fromJson(serviceman));
          }
        } else {
          List<dynamic> list = response.body['content']['data'];
          for (var serviceman in list) {
            servicemanList!.add(ServicemanModel.fromJson(serviceman));
          }
        }

        _pageSize = response.body['content']['last_page'];
        _totalServiceman = response.body['content']['total'];
      } else {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> getSingleServicemanData({int? index, String? fromPage}) async {
    if (fromPage == 'editPage') {
      countryDialCode =
          ValidationHelper.getValidCountryCode(
                servicemanList?[index!].phone ?? "",
              ) !=
              ""
          ? ValidationHelper.getValidCountryCode(
              servicemanList?[index!].phone ?? "",
            )
          : CountryCode.fromCountryCode(
                  Get.find<SplashController>()
                      .configModel
                      .content!
                      .countryCode!,
                ).dialCode ??
                "+880";
      firstNameController.text = servicemanList?[index!].firstName ?? "";
      lastNameController.text = servicemanList?[index!].lastName ?? "";
      phoneController.text =
          ValidationHelper.getValidPhone(servicemanList?[index!].phone ?? "") !=
              ""
          ? ValidationHelper.getValidPhone(servicemanList?[index!].phone ?? "")
          : servicemanList?[index!].phone ?? "";
      identityNumberController.text =
          servicemanList?[index!].identificationNumber ?? "";
      selectedIdentityType = servicemanList?[index!].identificationType ?? "";
      emailController.text = servicemanList?[index!].email ?? "";
      _profileImage = servicemanList?[index!].profileImageFullPath ?? "";
      _identificationImage = [
        ...?servicemanList?[index!].identificationImageFullPath,
      ];
      passController.text = '';
      confirmPasswordController.text = '';
      updateIndex(-1);
      currentServicemanIndex = index;
    } else if (fromPage == 'detailsPage') {
      countryDialCode =
          ValidationHelper.getValidCountryCode(
                Get.find<ServicemanDetailsController>()
                        .servicemanModel
                        ?.user
                        ?.phone ??
                    "",
              ) !=
              ""
          ? ValidationHelper.getValidCountryCode(
              Get.find<ServicemanDetailsController>()
                      .servicemanModel
                      ?.user
                      ?.phone ??
                  "",
            )
          : CountryCode.fromCountryCode(
                  Get.find<SplashController>()
                      .configModel
                      .content!
                      .countryCode!,
                ).dialCode ??
                "+880";
      firstNameController.text = Get.find<ServicemanDetailsController>()
          .servicemanModel!
          .user!
          .firstName!;
      lastNameController.text = Get.find<ServicemanDetailsController>()
          .servicemanModel!
          .user!
          .lastName!;
      phoneController.text =
          ValidationHelper.getValidPhone(
                Get.find<ServicemanDetailsController>()
                        .servicemanModel
                        ?.user
                        ?.phone ??
                    "",
              ) !=
              ""
          ? ValidationHelper.getValidPhone(
              Get.find<ServicemanDetailsController>()
                      .servicemanModel
                      ?.user
                      ?.phone ??
                  "",
            )
          : servicemanList?[index!].phone ?? "";
      identityNumberController.text = Get.find<ServicemanDetailsController>()
          .servicemanModel!
          .user!
          .identificationNumber!;
      selectedIdentityType = Get.find<ServicemanDetailsController>()
          .servicemanModel!
          .user!
          .identificationType!;
      emailController.text =
          Get.find<ServicemanDetailsController>().servicemanModel!.user!.email!;
      passController.text = '';
      confirmPasswordController.text = '';
      _profileImage =
          Get.find<ServicemanDetailsController>()
              .servicemanModel
              ?.user
              ?.profileImageFullPath ??
          "";
      _identificationImage =
          Get.find<ServicemanDetailsController>()
              .servicemanModel
              ?.user
              ?.identificationImageFullPath ??
          [];
    } else {
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      identityNumberController.clear();
      emailController.clear();
      _profileImage = '';
      _pickedProfileImage = null;
      currentServicemanIndex = -1;
      _identificationImage = [];
      _selectedIdentityImageList = [];
      passController.clear();
      confirmPasswordController.clear();
      updateIndex(-1);
      selectedIdentityType = '';
      countryDialCode =
          CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel.content!.countryCode!,
          ).dialCode ??
          "+880";
    }
  }

  Future<void> deleteServiceman(String id, {bool fromDetails = false}) async {
    Response response = await servicemanRepo.deleteServiceman(id);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_delete_200') {
      updateIndex(-1);
      Get.back();

      if (fromDetails) {
        Get.back();
      }
      showCustomSnackBar(
        'serviceman_delete'.tr,
        type: ToasterMessageType.success,
      );
      _servicemanList?.removeWhere((element) => element.serviceman?.id == id);
      _totalServiceman--;
      Get.find<DashboardController>().removeServiceman(id);
    } else {
      updateIndex(-1);
      Get.back();
      showCustomSnackBar(response.body['message']);
    }
    update();
  }

  Future<void> changeServicemanStatus(
    int index,
    String servicemanId, {
    bool fromDetailsPage = false,
  }) async {
    if (fromDetailsPage) {
      Get.find<ServicemanDetailsController>().updateActiveStatus();
    } else {
      int status = servicemanList?[index].isActive == 1 ? 0 : 1;
      servicemanList?[index].isActive = status;
      update();
    }

    Response response = await servicemanRepo.changeServicemanStatus(
      servicemanId,
    );

    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      updateIndex(-1);

      showCustomSnackBar(
        "serviceman_status_updated_successfully".tr,
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar("${response.body['message']}");
    }
    update();
  }

  void pickProfileImage(bool isRemove) async {
    if (isRemove) {
      _pickedProfileImage = null;
    } else {
      _pickedProfileImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      double imageSize = await ImageSize.getImageSizeFromXFile(
        _pickedProfileImage!,
      );
      if (imageSize > AppConstants.limitOfPickedImageSizeInMB) {
        _pickedProfileImage = null;
        showCustomSnackBar(
          "image_size_greater_than".tr,
          type: ToasterMessageType.info,
        );
      }
    }
    update();
  }

  void pickIdentityImage(bool isRemove, {int? index}) async {
    if (isRemove) {
      if (index != null) {
        _selectedIdentityImageList.removeAt(index);
      }
    } else {
      XFile pickedImage = (await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      ))!;
      double imageSize = await ImageSize.getImageSizeFromXFile(pickedImage);

      if (imageSize > AppConstants.limitOfPickedImageSizeInMB) {
        showCustomSnackBar(
          "image_size_greater_than".tr,
          type: ToasterMessageType.info,
        );
      } else {
        if (pickedImage.path.contains('.gif')) {
          showCustomSnackBar(
            'can_not_upload_gif_file'.tr,
            type: ToasterMessageType.info,
          );
        } else {
          _selectedIdentityImageList.add(
            MultipartBody('identity_images[]', pickedImage),
          );
        }
      }
      update();
    }
    update();
  }

  void updateTabControllerValue(ServicemanTabControllerState value) {
    servicemanPageCurrentState = value;
    update();
  }

  void setValue(String value) {
    selectedIdentityType = value;
    update();
  }

  void updateIndex(int index) {
    selectedIndex = index;
    update();
  }

  void clearAllData() {
    _pickedProfileImage = null;
    passController.clear();
    confirmPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    identityNumberController.clear();
    phoneController.clear();
    _selectedIdentityImageList = [];
  }

  void resetOtherValidationData() {
    _isProfilePicValid = true;
    _isServicemanIdentityImageValid = true;
    _isIdentityTypeValid = true;
    _isGeneralInfoValid = false;
  }

  void clearImageData() {
    _pickedProfileImage = null;
    _selectedIdentityImageList = [];
  }

  void fromBookingDetailsPage(bool fromBookingPage) {
    _isFromBookingDetailsPage = fromBookingPage;
    update();
  }

  void checkOtherValidationField({bool isUpdate = true}) {
    if (pickedProfileImage == null && profileImage == '') {
      _isProfilePicValid = false;
    } else {
      _isProfilePicValid = true;
    }

    if (selectedIdentityImageList.isEmpty && identificationImage.isEmpty) {
      _isServicemanIdentityImageValid = false;
    } else {
      _isServicemanIdentityImageValid = true;
    }

    if (selectedIdentityType == '') {
      _isIdentityTypeValid = false;
    } else {
      _isIdentityTypeValid = true;
    }

    if (isUpdate) {
      update();
    }
  }

  void setValidGeneralInfo() {
    _isGeneralInfoValid = true;
    update();
  }
}
