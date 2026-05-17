import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AdvertisementController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final AdvertisementRepo advertisementRepo;
  AdvertisementController({required this.advertisementRepo});

  int _selectedIndex = 0;
  int get currentIndex => _selectedIndex;

  bool _isEditScreen = false;
  bool get isEditScreen => _isEditScreen;

  int _apiHitCount = 0;

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  List<AdvertisementData>? _advertisementDataList;
  List<AdvertisementData>? get advertisementDataList => _advertisementDataList;

  AdvertisementDetailsModel? _advertisementDetailsModel;
  AdvertisementDetailsModel? get advertisementDetailsModel =>
      _advertisementDetailsModel;

  BookingCount? _bookingCount;
  BookingCount? get bookingCount => _bookingCount;

  AutoScrollController? menuScrollController;
  TabController? listTabController;

  final GlobalKey<FormState> noteFormKey = GlobalKey<FormState>();

  bool isDateRangeValid = true;

  bool _isLogoValid = true;
  bool get isLogoValid => _isLogoValid;

  bool _isCoverImageValid = true;
  bool get isCoverImageValid => _isCoverImageValid;

  bool _isRatingsChecked = false;
  bool get isRatingsChecked => _isRatingsChecked;

  bool _isReviewChecked = false;
  bool get isReviewChecked => _isReviewChecked;

  bool _isVideoValid = true;
  bool get isVideoValid => _isVideoValid;

  XFile? _pickedProfileImage;
  XFile? get pickedProfileImage => _pickedProfileImage;

  String? _networkProfileImage;
  String? get networkProfileImage => _networkProfileImage;

  XFile? _pickedCoverImage;
  XFile? get pickedCoverImage => _pickedCoverImage;

  String? _networkCoverImage;
  String? get networkCoverImage => _networkCoverImage;

  XFile? _pickedVideoFile;
  XFile? get pickedVideoFile => _pickedVideoFile;

  String? _networkVideoFile;
  String? get networkVideoFile => _networkVideoFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTimeRange? dateTimeRange;

  List<String> advertisementStatusList = [
    "all",
    "pending",
    "approved",
    "running",
    "paused",
    "expired",
    "denied",
  ];
  List<String> advertisementStatusImageList = [
    Images.allIcon,
    Images.pendingIcon,
    Images.approvedIcon,
    Images.runningIcon,
    Images.pausedIcon,
    Images.expiredIcon,
    Images.deniedIcon,
  ];
  String get advertisementStatus => advertisementStatusList[_selectedIndex];

  final List<String> _adsType = ['video_promotion', "profile_promotion"];
  List<String> get adsType => _adsType;

  String _selectedAdsType = "video_promotion";
  String get selectedAdsType => _selectedAdsType;

  TextEditingController? validationController;
  TextEditingController? titleController;
  TextEditingController? descriptionController;
  TextEditingController? noteController;

  VideoPlayerController? videoPlayerController;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    listTabController = TabController(vsync: this, length: 7);

    validationController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    noteController = TextEditingController();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_offset < _pageSize!) {
          getAdvertisementList(
            advertisementStatus,
            offset + 1,
            paginationLoading: true,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  void initializeAdvertisementValues(AdvertisementData advertisementData) {
    resetAllValues();
    validationController?.text =
        "${DateConverter.stringToLocalDateOnly(advertisementData.startDate ?? "")} - ${DateConverter.stringToLocalDateOnly(advertisementData.endDate ?? "")}";
    setAdsType(type: advertisementData.type ?? "", shouldUpdate: false);
    _networkProfileImage = advertisementData.providerProfileImageFullPath;
    _networkCoverImage = advertisementData.providerCoverImageFullPath;
    _networkVideoFile = advertisementData.promotionalVideoFullPath;
    _isReviewChecked = advertisementData.providerReview == '1';
    _isRatingsChecked = advertisementData.providerRating == '1';
    if (_networkVideoFile != null) {
      initializeVideoPlayerForNetwork();
    }
  }

  Future<void> getAdvertisementList(
    String requestType,
    int offset, {
    bool reload = false,
    int index = 0,
    bool isFirst = false,
    bool paginationLoading = false,
  }) async {
    _offset = offset;
    _apiHitCount++;
    if (reload) {
      _advertisementDataList = null;
    }
    if (paginationLoading) {
      _isLoading = true;
    }
    if (!isFirst) {
      update();
    }

    Response response = await advertisementRepo.getAdvertisementList(
      requestType: requestType.toLowerCase(),
      offset: offset,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      List<dynamic> advertisementList = response.body['content']['data'];
      if (_offset == 1) {
        _advertisementDataList = [];

        for (var item in advertisementList) {
          _advertisementDataList?.add(AdvertisementData.fromJson(item));
        }
      } else {
        for (var item in advertisementList) {
          _advertisementDataList?.add(AdvertisementData.fromJson(item));
        }
      }
      _pageSize = response.body['content']['last_page'];
    } else {
      ApiChecker.checkApi(response);
    }
    _apiHitCount--;

    _isLoading = false;
    if (_apiHitCount == 0) {
      update();
    }
  }

  Future<void> submitNewAdvertisement({
    List<TextEditingController>? titleController,
    List<TextEditingController>? descriptionController,
    List<Language>? languageList,
  }) async {
    _isLoading = true;
    update();

    List<MultipartBody> selectedFiles = [];
    if (selectedAdsType == 'profile_promotion') {
      selectedFiles.add(MultipartBody('profile_image', _pickedProfileImage!));
      selectedFiles.add(MultipartBody('cover_image', _pickedCoverImage!));
    } else {
      selectedFiles.add(MultipartBody('video_attachment', _pickedVideoFile!));
    }

    Map<String, String> body = {
      'type': selectedAdsType,
      'start_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.start.toString() ?? "",
      ),
      'end_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.end.toString() ?? "",
      ),
      'review': isReviewChecked ? "1" : "0",
      'rating': isRatingsChecked ? "1" : "0",
    };
    for (int index = 0; index < titleController!.length; index++) {
      body['title[$index]'] = titleController[index].text;
      body['description[$index]'] = descriptionController![index].text;
      body['lang[$index]'] = languageList![index].languageCode!;
    }

    Response response = await advertisementRepo.submitNewAdvertisement(
      body,
      selectedFiles,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_store_200') {
      await getAdvertisementList("all", 1);
      _isLoading = false;
      updateAdvertisementTabIndex(0);
      update();
      Get.back();
      showCustomBottomSheet(child: const AdCreatedSuccessfullySheet());
    } else {
      _isLoading = false;
      update();
      showCustomSnackBar(response.body['errors'][0]['message']);
    }
  }

  Future<void> editAdvertisement(
    AdvertisementData advertisementData, {
    required bool isFromDetailsPage,
    List<TextEditingController>? titleController,
    List<TextEditingController>? descriptionController,
    List<Language>? languageList,
  }) async {
    _isLoading = true;
    update();

    List<MultipartBody> selectedFiles = [];
    if (selectedAdsType == 'profile_promotion') {
      if (_pickedProfileImage != null) {
        selectedFiles.add(MultipartBody('profile_image', _pickedProfileImage!));
      }
      if (_pickedCoverImage != null) {
        selectedFiles.add(MultipartBody('cover_image', _pickedCoverImage!));
      }
    } else if (selectedAdsType == 'video_promotion') {
      if (_pickedVideoFile != null) {
        selectedFiles.add(MultipartBody('video_attachment', _pickedVideoFile!));
      }
    }

    Map<String, String> body = {
      '_method': 'put',
      'type': selectedAdsType,
      'start_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.start.toString() ?? advertisementData.startDate!,
      ),
      'end_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.end.toString() ?? advertisementData.endDate!,
      ),
      'review': isReviewChecked ? "1" : "0",
      'rating': isRatingsChecked ? "1" : "0",
    };

    for (int index = 0; index < titleController!.length; index++) {
      body['title[$index]'] = titleController[index].text;
      body['description[$index]'] = descriptionController![index].text;
      body['lang[$index]'] = languageList![index].languageCode!;
    }

    Response response = await advertisementRepo.editAdvertisement(
      id: advertisementData.id!,
      body: body,
      selectedFile: selectedFiles,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_update_200') {
      await getAdvertisementList(advertisementStatus, 1);
      updateAdvertisementTabIndex(_selectedIndex);
      if (isFromDetailsPage) {
        Get.back();
      }
      Get.back();
      showCustomSnackBar(
        response.body['message'],
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> getAdvertisementDetails({required String id}) async {
    _advertisementDetailsModel = null;
    Response response = await advertisementRepo.getAdvertisementDetails(id: id);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_200') {
      _advertisementDetailsModel = AdvertisementDetailsModel.fromJson(
        response.body,
      );
    } else if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_204') {
      _advertisementDetailsModel = AdvertisementDetailsModel.fromJson(
        response.body,
      );
      removeAdvertisementItemFromList(id, shouldUpdate: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> deleteAdvertisement({required String id}) async {
    _isLoading = true;
    update();

    Response response = await advertisementRepo.deleteAdvertisement(id: id);
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_delete_200') {
      await getAdvertisementList(advertisementStatus, 1);
      Get.back();
      showCustomSnackBar(
        "${response.body['message']}",
        type: ToasterMessageType.success,
      );
      advertisementDataList?.removeWhere((element) => element.id == id);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> changeAdvertisementStatus({
    required String id,
    required String status,
    bool isFromDetailsPage = false,
  }) async {
    _isLoading = true;
    update();

    Map<String, String> body = {'note': noteController?.text ?? ""};

    Response response = await advertisementRepo.changeAdvertisementStatus(
      id: id,
      status: status,
      body: body,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_status_update_200') {
      getAdvertisementList(advertisementStatus, 1, reload: true);
      resetNoteController();
      if (isFromDetailsPage) {
        Get.back();
      }
      Get.back();
      showCustomSnackBar(
        "${response.body['message']}",
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<void> reSubmitAdvertisement(
    AdvertisementData advertisementData, {
    List<TextEditingController>? titleController,
    List<TextEditingController>? descriptionController,
    List<Language>? languageList,
  }) async {
    _isLoading = true;
    update();

    List<MultipartBody> selectedFiles = [];
    if (selectedAdsType == 'profile_promotion') {
      if (_pickedProfileImage != null) {
        selectedFiles.add(MultipartBody('profile_image', _pickedProfileImage!));
      }
      if (_pickedCoverImage != null) {
        selectedFiles.add(MultipartBody('cover_image', _pickedCoverImage!));
      }
    } else if (selectedAdsType == 'video_promotion') {
      if (_pickedVideoFile != null) {
        selectedFiles.add(MultipartBody('video_attachment', _pickedVideoFile!));
      }
    }

    Map<String, String> body = {
      'type': selectedAdsType,
      'start_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.start.toString() ?? advertisementData.startDate!,
      ),
      'end_date': DateConverter.dateTimeStringToDate(
        dateTimeRange?.end.toString() ?? advertisementData.endDate!,
      ),
      'review': isReviewChecked ? "1" : "0",
      'rating': isRatingsChecked ? "1" : "0",
    };

    for (int index = 0; index < titleController!.length; index++) {
      body['title[$index]'] = titleController[index].text;
      body['description[$index]'] = descriptionController![index].text;
      body['lang[$index]'] = languageList![index].languageCode!;
    }

    Response response = await advertisementRepo.reSubmitAdvertisement(
      advertisementData.id!,
      body: body,
      selectedFile: selectedFiles,
    );
    if (response.statusCode == 200 &&
        response.body['response_code'] == 'default_update_200') {
      await getAdvertisementList(advertisementStatus, 1);
      updateAdvertisementTabIndex(_selectedIndex);
      Get.back();
      showCustomSnackBar(
        response.body['message'],
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  removeAdvertisementItemFromList(
    String advertisementID, {
    bool shouldUpdate = false,
  }) {
    _advertisementDataList?.removeWhere(
      (element) => element.id == advertisementID,
    );
    if (shouldUpdate) {
      update();
    }
  }

  void updateAdvertisementTabIndex(int index, {bool shouldUpdate = true}) {
    _selectedIndex = index;
    listTabController?.index = index;
    if (shouldUpdate) {
      update();
    }
  }

  void pickProfileImage(bool isRemove) async {
    if (isRemove) {
      _pickedProfileImage = null;
      _networkProfileImage = null;
    } else {
      _networkProfileImage = null;
      _pickedProfileImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      double imageSize = await ImageSize.getImageSizeFromXFile(
        _pickedProfileImage!,
      );
      _isLogoValid = true;
      if (imageSize > AppConstants.maxSizeOfASingleFile) {
        _pickedProfileImage = null;
        _isLogoValid = false;
        showCustomSnackBar("logo_size_greater_than".tr);
      }
    }
    update();
  }

  checkValidation() {
    if (selectedAdsType == 'video_promotion') {
      if (_pickedVideoFile == null && _networkVideoFile == null) {
        _isVideoValid = false;
      } else {
        _isVideoValid = true;
      }
    } else {
      if (_pickedProfileImage == null && _networkProfileImage == null) {
        _isLogoValid = false;
      } else {
        _isLogoValid = true;
      }
      if (_pickedCoverImage == null && _networkCoverImage == null) {
        _isCoverImageValid = false;
      } else {
        _isCoverImageValid = true;
      }
    }
    update();
  }

  void pickCoverImage(bool isRemove) async {
    if (isRemove) {
      _pickedCoverImage = null;
      _networkCoverImage = null;
    } else {
      _networkCoverImage = null;
      _pickedCoverImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      double imageSize = await ImageSize.getImageSizeFromXFile(
        _pickedCoverImage!,
      );
      _isCoverImageValid = true;
      if (imageSize > AppConstants.maxSizeOfASingleFile) {
        _pickedCoverImage = null;
        _isCoverImageValid = false;
        showCustomSnackBar("cover_image_size_greater_than".tr);
      }
    }
    update();
  }

  void pickVideoFile(bool isRemove) async {
    if (isRemove) {
      _pickedVideoFile = null;
      _networkVideoFile = null;
      if (videoPlayerController != null &&
          videoPlayerController!.value.isInitialized) {
        videoPlayerController!.dispose();
      }
      update();
    } else {
      _networkVideoFile = null;
      _pickedVideoFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );
      if (_pickedVideoFile != null) {
        double videoSize = await ImageSize.getImageSizeFromXFile(
          _pickedVideoFile!,
        );
        if (videoSize > AppConstants.limitOfPickedVideoSizeInMB) {
          _pickedVideoFile = null;
          _isVideoValid = false;
          showCustomSnackBar("video_size_greater_than".tr);
          update();
        } else {
          _isVideoValid = true;
          update();
          initializeVideoPlayerForPicked();
        }
      }
    }
  }

  initializeVideoPlayerForPicked() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      videoPlayerController!.dispose();
    }
    videoPlayerController =
        VideoPlayerController.file(File(_pickedVideoFile!.path))
          ..initialize().then((_) {
            update();
          });
  }

  initializeVideoPlayerForNetwork() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      videoPlayerController!.dispose();
    }

    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(networkVideoFile ?? ""))
          ..initialize().then((_) {
            update();
          });
  }

  setAdsType({required String type, bool shouldUpdate = true}) {
    _selectedAdsType = type;
    if (shouldUpdate) {
      update();
    }
  }

  String getAdvertisementStatus(
    String? status,
    String startDate,
    String endDate,
  ) {
    DateTime networkStartDate = DateConverter.isoUtcStringToLocalDate(
      startDate,
    );
    DateTime networkEndDate = DateConverter.isoUtcStringToLocalDate(endDate);
    DateTime currentDate = DateTime.now();

    if ((status == "approved" || status == "resumed") &&
        (currentDate.isAfter(networkStartDate) &&
            currentDate.isBefore(networkEndDate))) {
      return "running";
    }

    return status ?? "";
  }

  bool isAdvertisementExpired(String endDate) {
    DateTime dateWithTime = DateConverter.isoUtcStringToLocalDateOnly(endDate);

    DateTime endDateOnly = DateTime(
      dateWithTime.year,
      dateWithTime.month,
      dateWithTime.day,
    );
    DateTime currentDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (currentDate.isAfter(endDateOnly)) {
      return true;
    }
    return false;
  }

  List<PopupMenuModel> getPopupMenuList(String status) {
    if (status == "pending") {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "cancel_ads", icon: Icons.close),
      ];
    } else if (status == "approved" || status == 'running') {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "pause_ads", icon: Icons.pause_circle),
        PopupMenuModel(title: "delete_ads", icon: Icons.delete),
      ];
    } else if (status == 'expired' || status == 'denied') {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "copy_ads", icon: Icons.restore),
        PopupMenuModel(title: "delete_ads", icon: Icons.delete),
      ];
    } else if (status == 'paused') {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "resume_ads", icon: Icons.play_arrow_rounded),
        PopupMenuModel(title: "delete_ads", icon: Icons.delete),
      ];
    } else if (status == 'resumed') {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "pause_ads", icon: Icons.pause_circle),
        PopupMenuModel(title: "delete_ads", icon: Icons.delete),
      ];
    } else if (status == 'canceled') {
      return [
        PopupMenuModel(title: "view_ads", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "edit_ads", icon: Icons.edit),
        PopupMenuModel(title: "copy_ads", icon: Icons.restore),
        PopupMenuModel(title: "delete_ads", icon: Icons.delete),
      ];
    }
    return [];
  }

  setIsEditScreen({required bool isEditScreen, bool shouldUpdate = false}) {
    _isEditScreen = isEditScreen;
    if (shouldUpdate) {
      update();
    }
  }

  resetAllValues({bool shouldUpdate = false}) {
    _isEditScreen = false;
    _selectedAdsType = "video_promotion";
    _pickedVideoFile = null;
    validationController?.text = '';
    descriptionController!.text = '';
    titleController!.text = '';
    _pickedProfileImage = null;
    _pickedCoverImage = null;
    _isCoverImageValid = true;
    _isVideoValid = true;
    _isLogoValid = true;
    _networkVideoFile = null;
    _networkCoverImage = null;
    _networkProfileImage = null;
    _isRatingsChecked = false;
    _isReviewChecked = false;
    dateTimeRange = null;
    noteController?.text = '';
    if (shouldUpdate) {
      update();
    }
  }

  resetNoteController() {
    noteController?.text = '';
    update();
  }

  String modifyDateRange() {
    String firstDate = DateConverter.dateStringMonthYear(dateTimeRange?.start);
    String lastDate = DateConverter.dateStringMonthYear(dateTimeRange?.end);
    return "$firstDate - $lastDate";
  }

  toggleReviewChecked() {
    _isReviewChecked = !_isReviewChecked;
    update();
  }

  toggleRatingChecked() {
    _isRatingsChecked = !_isRatingsChecked;
    update();
  }

  bool validateTimeRange() {
    bool isBefore = false;
    if (validationController?.text != null) {
      List<String> parts = validationController!.text.split('-');
      String formattedString = parts[0].removeAllWhitespace;
      DateTime networkStartDate = DateFormat(
        "ddMMM,yyyy",
      ).parse(formattedString).toLocal();

      DateTime todayDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      isBefore = networkStartDate.isBefore(todayDate);
    }
    return isBefore;
  }
}
