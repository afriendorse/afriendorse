import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/settings/business/controller/identity_controller.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';

class UserProfileController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UserProfileController({required this.userRepo});

  final GlobalKey<FormState> profileInformationFormKey = GlobalKey<FormState>();

  TextEditingController? companyNameController,
      companyPhoneController,
      companyEmailController,
      personalNameController,
      personalPhoneController,
      personalEmailController,
      emailController,
      passwordController,
      confirmPasswordController;

  bool keepPersonalInfoAsCompanyInfo = false;

  bool _showOverflowDialog = false;
  bool get showOverflowDialog => _showOverflowDialog;

  bool _trialWidgetNotShow = false;
  bool get trialWidgetNotShow => _trialWidgetNotShow;

  String _providerId = '';
  String get providerId => _providerId;

  var countryDialCode = "+234";

  String _selectedZoneID = '';
  String get selectedZoneID => _selectedZoneID;

  String _selectedZoneName = "";
  String get selectedZoneName => _selectedZoneName;

  String myZone = '';
  String? myZoneId;
  double latitude = 0;
  double longitude = 0;

  List<ZoneData> zoneList = [];

  bool _isZoneValid = true;
  bool get isZoneValid => _isZoneValid;

  int _totalCompleteRequest = 0;
  int _totalCanceledRequest = 0;
  int _totalOngoingRequest = 0;
  int _totalAcceptedRequest = 0;

  int get totalCompletedRequest => _totalCompleteRequest;
  int get totalCanceledRequest => _totalCanceledRequest;
  int get totalOngoingRequest => _totalOngoingRequest;
  int get totalAcceptedRequest => _totalAcceptedRequest;

  @override
  void onInit() {
    super.onInit();
    companyNameController = TextEditingController();
    companyPhoneController = TextEditingController();
    companyEmailController = TextEditingController();

    personalNameController = TextEditingController();
    personalPhoneController = TextEditingController();
    personalEmailController = TextEditingController();

    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // ✅ safe — was using .dialCode! which could also crash
    countryDialCode =
        CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel.content?.countryCode ?? "NG",
        ).dialCode ??
        "+234";
  }

  @override
  void onClose() {
    companyNameController?.dispose();
    companyPhoneController?.dispose();
    companyEmailController?.dispose();
    personalNameController?.dispose();
    personalPhoneController?.dispose();
    personalEmailController?.dispose();
    emailController?.dispose();
    passwordController?.dispose();
    confirmPasswordController?.dispose();
  }

  void togglePersonalInfoAsCompanyInfo() {
    keepPersonalInfoAsCompanyInfo = !keepPersonalInfoAsCompanyInfo;

    if (keepPersonalInfoAsCompanyInfo) {
      personalNameController!.text = companyNameController!.text;
      personalPhoneController!.text = companyPhoneController!.text;
      personalEmailController!.text = companyEmailController!.text;
    } else {
      personalNameController!.text =
          _providerModel?.content?.providerInfo?.contactPersonName ?? "";
      personalPhoneController!.text = ValidationHelper.getValidPhone(
        _providerModel?.content?.providerInfo?.contactPersonPhone ?? "",
      );
      personalEmailController!.text =
          _providerModel?.content?.providerInfo?.contactPersonEmail ?? "";
    }
    update();
  }

  ProviderModel? _providerModel;
  XFile? _pickedFile;
  XFile? _coverImageFile;
  bool _isLoading = false;

  ProviderModel? get providerModel => _providerModel;
  XFile? get pickedFile => _pickedFile;
  XFile? get coverImageFile => _coverImageFile;
  bool get isLoading => _isLoading;

  Future<bool> getProviderInfo({reload = false}) async {
    _isLoading = true;

    Get.find<LocationController>().setPickedLocation();

    if (_providerModel == null || reload) {
      Response response = await userRepo.getProviderInfo();
      if (response.statusCode == 200) {
        getZoneList();
        _providerModel = ProviderModel.fromJson(response.body);

        double payablePercentage = getOverflowPercent(
          double.tryParse(
                _providerModel
                        ?.content
                        ?.providerInfo
                        ?.owner
                        ?.account
                        ?.accountPayable ??
                    "0",
              ) ??
              0,
          double.tryParse(
                _providerModel
                        ?.content
                        ?.providerInfo
                        ?.owner
                        ?.account
                        ?.accountReceivable ??
                    "0",
              ) ??
              0,
          Get.find<SplashController>()
                  .configModel
                  .content
                  ?.maxCashInHandLimit ??
              0,
        );

        hideOverflowDialog(
          payablePercentage: payablePercentage,
          hideDialog: false,
        );

        companyNameController!.text =
            _providerModel?.content?.providerInfo?.companyName ?? '';

        // ── Company phone: extract dial code then store local number only ──
        final rawCompanyPhone =
            _providerModel?.content?.providerInfo?.companyPhone ?? '';
        final detectedDialCode = ValidationHelper.getValidCountryCode(
          rawCompanyPhone,
        );

        countryDialCode = detectedDialCode.isNotEmpty
            ? detectedDialCode
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>()
                            .configModel
                            .content
                            ?.countryCode ??
                        'NG',
                  ).dialCode ??
                  '+234';

        companyPhoneController!.text = detectedDialCode.isNotEmpty
            ? rawCompanyPhone.replaceFirst(detectedDialCode, '')
            : ValidationHelper.getValidPhone(rawCompanyPhone).isNotEmpty
            ? ValidationHelper.getValidPhone(rawCompanyPhone)
            : rawCompanyPhone;

        companyEmailController!.text =
            _providerModel?.content?.providerInfo?.companyEmail ?? "";

        personalNameController!.text =
            _providerModel?.content?.providerInfo?.contactPersonName ?? "";

        // ── Contact person phone: strip dial code before storing ──────────
        final rawPersonalPhone =
            _providerModel?.content?.providerInfo?.contactPersonPhone ?? '';
        final detectedPersonalDialCode = ValidationHelper.getValidCountryCode(
          rawPersonalPhone,
        );

        personalPhoneController!.text = detectedPersonalDialCode.isNotEmpty
            ? rawPersonalPhone.replaceFirst(detectedPersonalDialCode, '')
            : ValidationHelper.getValidPhone(rawPersonalPhone).isNotEmpty
            ? ValidationHelper.getValidPhone(rawPersonalPhone)
            : rawPersonalPhone;

        personalEmailController!.text =
            _providerModel?.content?.providerInfo?.contactPersonEmail ?? "";
        emailController!.text =
            _providerModel?.content?.providerInfo?.owner?.email ?? "";
        latitude =
            _providerModel?.content?.providerInfo?.coordinates?.latitude ?? 0;
        longitude =
            _providerModel?.content?.providerInfo?.coordinates?.longitude ?? 0;
        _totalCompleteRequest = 0;
        _totalCanceledRequest = 0;
        _totalOngoingRequest = 0;
        _totalAcceptedRequest = 0;

        _providerId = _providerModel?.content?.providerInfo?.id ?? '';

        // ── Sync to Firestore with correct approval status ──────────────
        final info = _providerModel?.content?.providerInfo;
        final email = info?.owner?.email;
        final mysqlId = info?.id;

        final phone =
            info?.owner?.phone ??
            info?.companyPhone ??
            info?.contactPersonPhone;

        final rawApproval = info?.isApproved;
        final isApproved =
            rawApproval == 1 || rawApproval == '1' || rawApproval == true;

        if (kDebugMode) {
          print(
            '🔐 getProviderInfo() — email=$email | mysqlId=$mysqlId '
            '| isApproved=$isApproved (raw=$rawApproval)',
          );
        }

        if ((email?.isNotEmpty ?? false) && (mysqlId?.isNotEmpty ?? false)) {
          await AthleteFirestoreSyncService.upsertAthleteListingFields(
            email: email!,
            mysqlAthleteId: mysqlId!,
            phone: phone,
            companyName: info?.companyName,
            companyAddress: info?.companyAddress,
            logoFullPath: info?.logoFullPath,
            coverImageFullPath: info?.coverFullPath,
            avgRating: info?.avgRating,
            ratingCount: info?.ratingCount,
            zoneId: info?.zoneId,
            lat: info?.coordinates?.latitude,
            lon: info?.coordinates?.longitude,
          );
        }

        myZoneId = _providerModel?.content?.providerInfo?.zoneId ?? '';
        _selectedZoneID = myZoneId!;
        _selectedZoneName = '';

        getZoneList();

        if (companyNameController!.text == personalNameController!.text &&
            companyPhoneController!.text == personalPhoneController!.text &&
            companyEmailController!.text == personalEmailController!.text) {
          keepPersonalInfoAsCompanyInfo = true;
        } else {
          keepPersonalInfoAsCompanyInfo = false;
        }

        if (_providerModel?.content?.bookingOverview != null &&
            _providerModel!.content!.bookingOverview!.isNotEmpty) {
          for (var element in _providerModel!.content!.bookingOverview!) {
            if (element.bookingStatus == 'accepted') {
              _totalAcceptedRequest = element.total ?? 0;
            } else if (element.bookingStatus == "canceled") {
              _totalCanceledRequest = element.total ?? 0;
            } else if (element.bookingStatus == "completed") {
              _totalCompleteRequest = element.total ?? 0;
            } else if (element.bookingStatus == "ongoing") {
              _totalOngoingRequest = element.total ?? 0;
            }
          }
        } else {
          _totalCompleteRequest = 0;
          _totalCanceledRequest = 0;
          _totalOngoingRequest = 0;
          _totalAcceptedRequest = 0;
        }
        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    }
    _isLoading = false;
    update();

    return _providerModel != null;
  }

  Future<ResponseModel> updateProfile({
    required String address,
    required String identityNumber,
  }) async {
    _isLoading = true;
    update();

    if (Get.find<LocationController>().pickAddress.address != "") {
      latitude = Get.find<LocationController>().pickPosition.latitude;
      longitude = Get.find<LocationController>().pickPosition.longitude;
    }

    // ── Identity: preserve existing server values when not being updated ──
    final existingIdentityType =
        _providerModel?.content?.providerInfo?.owner?.identificationType ?? '';
    final existingIdentityNumber =
        _providerModel?.content?.providerInfo?.owner?.identificationNumber ??
        '';

    final identityTypeToSend =
        Get.find<IdentityController>().selectedIdentityType?.isNotEmpty == true
        ? Get.find<IdentityController>().selectedIdentityType!
        : existingIdentityType;

    final identityNumberToSend = identityNumber.isNotEmpty
        ? identityNumber
        : existingIdentityNumber;

    Response response = await userRepo.updateProfile(
      companyName: companyNameController!.text.toString(),
      companyPhone:
          "$countryDialCode${companyPhoneController!.text.toString()}",
      companyAddress: address,
      lat: latitude,
      lon: longitude,
      companyEmail: companyEmailController!.text.toString(),
      contactPersonName: personalNameController!.text.toString(),
      contactPersonPhone:
          "$countryDialCode${personalPhoneController!.text.toString()}",
      contactPersonEmail: personalEmailController!.text.toString(),
      zoneId: _selectedZoneID,
      profileImage: _pickedFile,
      deletedIdentityImages: Get.find<IdentityController>()
          .getDeletedImageUrls(),
      identityImages: Get.find<IdentityController>().getUploadedImageFiles(),
      coverImages: coverImageFile,
      identityNumber: identityNumberToSend,
      identityType: identityTypeToSend,
    );

    if (response.statusCode == 200) {
      await getProviderInfo(reload: true);

      if (companyNameController!.text == personalNameController!.text &&
          companyPhoneController!.text == personalPhoneController!.text &&
          companyEmailController!.text == personalEmailController!.text) {
        keepPersonalInfoAsCompanyInfo = true;
      } else {
        keepPersonalInfoAsCompanyInfo = false;
      }
      _isLoading = false;
      update();

      return ResponseModel(true, response.body['message']);
    } else {
      _isLoading = false;
      update();
      try {
        return ResponseModel(false, response.body['errors'][0]['message']);
      } catch (e) {
        return ResponseModel(
          false,
          response.statusText ?? "Something went wrong",
        );
      }
    }
  }

  Future<void> updatePassword() async {
    _isLoading = true;
    update();

    Response response = await userRepo.updatePasswordApi(
      password: passwordController!.text,
      confirmPassword: confirmPasswordController!.text,
    );

    if (response.statusCode == 200) {
      showCustomSnackBar(
        response.body['message'],
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar(response.body['errors'][0]['message']);
    }
    _isLoading = false;
    update();
  }

  Future<void> getZoneList() async {
    _selectedZoneName = '';

    if (zoneList.isEmpty) {
      Response? response = await userRepo.getZonesDataList();

      if (response == null || response.statusCode != 200)
        return; // ✅ null guard

      // ✅ Safe body parsing
      final body = response.body;
      if (body == null || body is! Map) return;

      final content = body['content'];
      if (content == null || content is! Map) return;

      final List<dynamic>? list = content['data'];
      if (list == null || list.isEmpty) return;

      zoneList = [];
      for (var element in list) {
        zoneList.add(ZoneData.fromJson(element));
      }

      if (zoneList.isNotEmpty && _providerModel != null) {
        final providerZoneId = _providerModel?.content?.providerInfo?.zoneId;
        if (providerZoneId != null) {
          for (var element in zoneList) {
            if (element.id == providerZoneId) {
              myZone = element.name ?? '';
            }
          }
        }
      }
    } else {
      final providerZoneId = _providerModel?.content?.providerInfo?.zoneId;
      if (_providerModel != null && providerZoneId != null) {
        for (var element in zoneList) {
          if (element.id == providerZoneId) {
            myZone = element.name ?? '';
          }
        }
      }
    }

    update();
  }

  void setNewZoneValue(String zoneName, zoneId) {
    _selectedZoneName = zoneName;
    _selectedZoneID = zoneId;
    update();
  }

  void pickImage() async {
    _pickedFile = (await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ));
    update();
  }

  void pickCoverImage() async {
    _coverImageFile = (await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ));
    update();
  }

  void resetImage() async {
    _pickedFile = null;
    _coverImageFile = null;
  }

  double getOverflowPercent(
    double payable,
    double receivable,
    double maxAmount,
  ) {
    double amount = getTransactionAmountAmount(payable, receivable);
    double percentage = (amount / maxAmount) * 100;
    return percentage;
  }

  double getTransactionAmountAmount(double payable, double receivable) {
    double amount = 0;
    if (payable > receivable) {
      amount = payable - receivable;
    } else {
      amount = receivable - payable;
    }
    return amount;
  }

  TransactionType getTransactionType(double payable, double receivable) {
    TransactionType type = TransactionType.none;

    if (payable == receivable) {
      if (payable == 0 || receivable == 0) {
        type = TransactionType.none;
      } else {
        type = TransactionType.adjust;
      }
    } else if (payable > receivable) {
      if (receivable > 0.0) {
        type = TransactionType.adjustAndPayable;
      } else {
        type = TransactionType.payable;
      }
    } else if (receivable > payable) {
      if (payable > 0.0) {
        type = TransactionType.adjustWithdrawAble;
      } else {
        type = TransactionType.withdrawAble;
      }
    } else {
      type = TransactionType.none;
    }

    return type;
  }

  int numberOfShowDialog = 0;

  hideOverflowDialog({double? payablePercentage, bool hideDialog = true}) {
    if (!hideDialog) {
      if (payablePercentage != null) {
        if (!_showOverflowDialog &&
            payablePercentage >= 80 &&
            payablePercentage < 100 &&
            numberOfShowDialog < 1) {
          numberOfShowDialog++;
          _showOverflowDialog = true;
        } else if (payablePercentage >= 100) {
          numberOfShowDialog = 0;
          _showOverflowDialog = true;
        }
      }
    } else {
      _showOverflowDialog = false;
      update();
    }
  }

  updateNumberOfTimeShowingDialog() {
    numberOfShowDialog = 0;
    _showOverflowDialog = false;
  }

  bool haveAnyAcceptedAndOngoingBooking() {
    return (_totalAcceptedRequest + _totalOngoingRequest) > 0;
  }

  onProfileChangeValidationCheck({bool shouldUpdate = true}) {
    if (selectedZoneName == "") {
      _isZoneValid = false;
    }
    if (shouldUpdate) {
      update();
    }
  }

  void clearUserProfileData() {
    _providerModel = null;
    update();
  }

  Future<bool> trialWidgetShow({required String route}) async {
    const Set<String> routesToHideWidget = {
      '/business-plan',
      'show-dialog',
      '/success',
      '/payment',
    };
    _trialWidgetNotShow = routesToHideWidget.contains(route);

    Future.delayed(const Duration(milliseconds: 500), () {
      update();
    });
    return _trialWidgetNotShow;
  }

  bool checkAvailableFeatureInSubscriptionPlan({required String featureType}) {
    bool status =
        _providerModel?.content?.subscriptionInfo?.status ==
                "subscription_base" &&
            !_providerModel!
                .content!
                .subscriptionInfo!
                .subscribedPackageDetails!
                .featureList!
                .contains(featureType)
        ? false
        : true;

    if (!status) {
      showCustomSnackBar(
        'this_feature_is_not_included_in_your_current_subscription_plan'.tr,
      );
    }
    return status;
  }
}
