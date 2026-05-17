What You Actually Want:

    Registration: User chooses Brand or Fan → saved to MySQL + Firestore
    Login: After login, check Firestore for userType → redirect to appropriate dashboard
    Dashboards: Two separate dashboards (BrandDashboard & FanDashboard) instead of one generic one


    am looking at creating a NIL platform taking Opendorse as a case study.. am already using an on demand handy man template(uses mysql database with api to the app) in which have renamed/adjusted somethings to suit the NIL platform.. the tempplate came with two apps the customer and the provider.. the provider app can be used as the athlete app while the customer app will serve for brand/fan app.. am looking at using firestore to make things a bit easy for me instead of having to uses the mysql(its a bit tedious for me as i have little knowledge about it.. but am more familiar with firestore.. and both the customer and the provider app uses the same firebase project.. so the idea is for the brand/fan app.. am thinking that when user is registering(brand/fan) an option should be there to choose like whether the user wants to register as brand or fan.. and ofcourse the reg details will be stored in mysql but i want a copy of it to also be stored in firestore for further utilization... you get.. the idea of also adding the brand or fan option is so that i can provide a personalized dashboard for them.. you get my point so far?

     cd domains/admin.afriendorse.com/public_html/


     alright make sense.. now unto the major challenge i have note am yet to do a live test run on my app because of the little errors am having.. i want to ensure i fix every possible error so i can build and check if its working as intended.. now unto the challenge.. i have two sides(app) in my app in which i merged it so basically it's the athlete and the brand/fan(there's a role feature in this one.. which make things a bit easier since its in one code folder unlike the athlete side that has it's own folder and own code.. now what prompted me to explain all this.. is because of the user controller error am having.. in my group controller.. The name 'UserController' isn't a type, so it can't be used as a type argument.
Try correcting the name to an existing type, or defining a type named 'UserController'.dartnon_type_as_type_argument.. // lib/feature/groups/controller/group_controller.dart

import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/controller/group_payment_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupController extends GetxController {
  final RxList<DocumentSnapshot> myGroups = <DocumentSnapshot>[].obs;
  final RxList<DocumentSnapshot> groupPosts = <DocumentSnapshot>[].obs;
  final RxList<DocumentSnapshot> publicGroups = <DocumentSnapshot>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<UserRole> currentUserRole = UserRole.unknown.obs;
  final RxString currentGroupId = ''.obs;
  final Rx<DocumentSnapshot?> currentGroup = Rx<DocumentSnapshot?>(null);
  final RxBool canUserPost = false.obs;
  final RxBool canUserJoin = false.obs;
  
  // Form controllers
  final groupNameController = TextEditingController();
  final groupDescriptionController = TextEditingController();
  final postContentController = TextEditingController();
  final donationAmountController = TextEditingController();
  final donationMessageController = TextEditingController();
  final inviteCodeController = TextEditingController();

  late final GroupPaymentController _paymentController;

  String get currentUserId {
    final athleteEmail = Get.find<UserProfileController>()
        .providerModel?.content?.providerInfo?.owner?.email;
    if (athleteEmail != null && athleteEmail.isNotEmpty) return athleteEmail;
    
    try {
      return Get.find<UserController>().userInfoModel?.id ?? '';
    } catch (e) {
      return '';
    }
  }

  String get currentUserEmail {
    try {
      return Get.find<UserProfileController>()
          .providerModel?.content?.providerInfo?.owner?.email ?? '';
    } catch (e) {
      try {
        return Get.find<UserController>().userInfoModel?.email ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  String get currentUserName {
    try {
      final profile = Get.find<UserProfileController>().providerModel?.content?.providerInfo;
      return '${profile?.contactPersonName ?? ''}'.trim();
    } catch (e) {
      try {
        final user = Get.find<UserController>().userInfoModel;
        return '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
      } catch (e) {
        return 'User';
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _paymentController = Get.put(GroupPaymentController());
    _initUserRole();
    // FIX: Removed _initDynamicLinks() - it's called in main.dart only once
  }

  Future<void> _initUserRole() async {
    final role = await GroupFirestoreService.getUserRole(currentUserId);
    currentUserRole.value = role;
    canUserPost.value = role == UserRole.athlete;
    canUserJoin.value = role == UserRole.athlete;
    
    if (role == UserRole.athlete) {
      _initAthleteGroupsStream();
    } else if (role == UserRole.brand || role == UserRole.fan) {
      _initPublicGroupsStream();
    }
  }

  /// For Athletes: Load their joined groups
  void _initAthleteGroupsStream() {
    final email = currentUserEmail;
    if (email.isEmpty) return;
    
    FirebaseFirestore.instance
        .collection('athlete_profiles')
        .doc(email)
        .snapshots()
        .listen((profile) async {
          final data = profile.data() as Map<String, dynamic>?;
          final groups = (data?['groups'] as List<dynamic>?) ?? [];
          
          if (groups.isEmpty) {
            myGroups.clear();
            return;
          }
          
          final snapshots = await Future.wait(
            groups.map((id) => FirebaseFirestore.instance.collection('groups').doc(id).get())
          );
          
          myGroups.value = snapshots.where((s) => s.exists).toList();
        });
  }

  /// For Brands/Fans: Load all public groups for discovery
  void _initPublicGroupsStream() {
    publicGroups.bindStream(GroupFirestoreService.getPublicGroups());
  }

  void loadGroupDetails(String groupId) {
    currentGroupId.value = groupId;
    currentGroup.bindStream(
      FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots()
    );
    loadGroupPosts(groupId);
  }

  void loadGroupPosts(String groupId) {
    groupPosts.bindStream(
      GroupFirestoreService.getGroupPosts(groupId).map((snapshot) => snapshot.docs)
    );
  }

  Future<void> createGroup() async {
    if (!canUserPost.value) {
      showCustomSnackBar('Only athletes can create groups');
      return;
    }

    if (groupNameController.text.isEmpty) {
      showCustomSnackBar('Please enter group name');
      return;
    }

    isLoading.value = true;
    
    final email = currentUserEmail;
    final fullName = currentUserName;
    
    final groupId = await GroupFirestoreService.createGroup(
      creatorEmail: email,
      creatorName: fullName,
      name: groupNameController.text.trim(),
      description: groupDescriptionController.text.trim(),
      sport: 'General',
    );
    
    isLoading.value = false;
    
    if (groupId != null) {
      groupNameController.clear();
      groupDescriptionController.clear();
      showCustomSnackBar('Group created successfully!', type: ToasterMessageType.success);
      Get.back();
    } else {
      showCustomSnackBar('Failed to create group');
    }
  }

  Future<void> joinGroupByCode() async {
    if (!canUserJoin.value) {
      showCustomSnackBar('Only athletes can join groups');
      return;
    }

    final code = inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      showCustomSnackBar('Please enter invite code');
      return;
    }

    isLoading.value = true;
    
    final groupDoc = await GroupFirestoreService.getGroupByInviteCode(code);
    if (groupDoc == null) {
      showCustomSnackBar('Invalid invite code');
      isLoading.value = false;
      return;
    }
    
    final success = await GroupFirestoreService.joinGroup(
      groupId: groupDoc.id,
      userId: currentUserEmail,
      firstName: currentUserName.split(' ').first,
      lastName: currentUserName.split(' ').last,
    );
    
    isLoading.value = false;
    inviteCodeController.clear();
    
    if (success) {
      showCustomSnackBar('Joined group successfully!', type: ToasterMessageType.success);
      Get.back();
    }
  }

  Future<void> createPost() async {
    if (!canUserPost.value) {
      showCustomSnackBar('Only athletes can post in groups');
      return;
    }

    if (postContentController.text.isEmpty) {
      showCustomSnackBar('Please enter post content');
      return;
    }

    isLoading.value = true;
    
    final success = await GroupFirestoreService.createPost(
      groupId: currentGroupId.value,
      authorId: currentUserEmail,
      authorName: currentUserName,
      content: postContentController.text.trim(),
    );
    
    isLoading.value = false;
    
    if (success) {
      postContentController.clear();
      showCustomSnackBar('Posted successfully!', type: ToasterMessageType.success);
    } else {
      showCustomSnackBar('Failed to create post');
    }
  }

  void showDonationDialog(String groupId) {
    final isDonor = currentUserRole.value == UserRole.brand || 
                   currentUserRole.value == UserRole.fan ||
                   currentUserRole.value == UserRole.athlete;
    
    if (!isDonor) {
      showCustomSnackBar('Please sign in to donate');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Donate to Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your donation will be split equally among all athlete members',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: donationAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Enter amount',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: donationMessageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Message (optional)',
                prefixIcon: Icon(Icons.message),
                hintText: 'Support message...',
              ),
            ),
            if (currentUserRole.value == UserRole.brand || currentUserRole.value == UserRole.fan) ...[
              SizedBox(height: 8),
              Text(
                'Donating as ${currentUserRole.value == UserRole.brand ? 'Brand' : 'Fan'}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              donationAmountController.clear();
              donationMessageController.clear();
              Get.back();
            },
            child: Text('Cancel'),
          ),
          Obx(() => isLoading.value || _paymentController.isLoading.value
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : ElevatedButton(
                onPressed: () => _processDonation(groupId),
                child: Text('Donate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _processDonation(String groupId) async {
    final amount = double.tryParse(donationAmountController.text) ?? 0;
    if (amount <= 0) {
      showCustomSnackBar('Please enter valid amount');
      return;
    }

    Get.back();

    String donorType;
    switch (currentUserRole.value) {
      case UserRole.athlete:
        donorType = 'athlete';
        break;
      case UserRole.brand:
        donorType = 'brand';
        break;
      case UserRole.fan:
        donorType = 'fan';
        break;
      default:
        donorType = 'unknown';
    }

    await _paymentController.donateToGroup(
      groupId: groupId,
      amount: amount,
      donorId: currentUserId,
      donorEmail: currentUserEmail,
      donorName: currentUserName,
      donorType: donorType,
      message: donationMessageController.text.isEmpty ? null : donationMessageController.text,
    );

    donationAmountController.clear();
    donationMessageController.clear();
  }

  Future<void> shareGroup(String groupId, String inviteCode, String groupName) async {
    await _paymentController.shareGroup(groupId, inviteCode, groupName);
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    postContentController.dispose();
    donationAmountController.dispose();
    donationMessageController.dispose();
    inviteCodeController.dispose();
    super.onClose();
  }
}.. i noticed that if i use my athlete user controller i get the error but if i use my brand/fan user controller the error goes.. if this discrepancy isnt fixed or sorted out there might be more issues that relates to brand/fan and athlete in terms of roles you get.. now below is my brand/fan user controller.. import 'package:afriendorse/api/local/cache_response.dart';
import 'package:afriendorse/helper/data_sync_helper.dart';
import 'package:afriendorse/helper/file_validation_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:timeago/timeago.dart' as timeago;
//
class UserController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UserController({required this.userRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedProfileImageFile;
  XFile? get pickedProfileImageFile => _pickedProfileImageFile;

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  var countryDialCode = "+880";

  final int _year = 0;
  int get year => _year;

  final int _month = 0;
  int get month => _month;

  final int _day = 0;
  int get day => _day;
  final now = DateTime.now();
  String _createdAccountAgo = '';
  String get createdAccountAgo => _createdAccountAgo;

  String _userProfileImage = '';
  String get userProfileImage => _userProfileImage;

  var editProfilePageCurrentState = EditProfileTabControllerState.generalInfo;

  UserInfoModel? setUserInfoModelData(UserInfoModel? userInfoModel) =>
      _userInfoModel = userInfoModel;

  Future<void> getUserInfo({bool reload = true}) async {
    if (reload || _userInfoModel == null) {
      _userInfoModel = null;
    }

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () =>
          userRepo.getUserInfo<CacheResponseData>(source: DataSourceEnum.local),
      fetchFromClient: () =>
          userRepo.getUserInfo(source: DataSourceEnum.client),
      onResponse: (data, source) {
        _userInfoModel = UserInfoModel.fromJson(data['content']);
        _userProfileImage = _userInfoModel?.image ?? "";
        final difference = now.difference(
          DateConverter.isoUtcStringToLocalDate(data['content']['created_at']),
        );
        _createdAccountAgo = timeago.format(now.subtract(difference));

        AddressModel? addressModel = Get.find<LocationController>()
            .getUserAddress();

        if (_userInfoModel != null &&
            (addressModel?.contactPersonNumber == "" ||
                addressModel?.contactPersonNumber == null)) {
          String? firstName;
          if (Get.find<UserController>().userInfoModel?.phone != null &&
              Get.find<UserController>().userInfoModel?.fName != null) {
            firstName = "${Get.find<UserController>().userInfoModel?.fName} ";
          }
          addressModel?.contactPersonNumber = firstName != null
              ? Get.find<UserController>().userInfoModel?.phone ?? ""
              : "";
          addressModel?.contactPersonName = firstName != null
              ? "$firstName${Get.find<UserController>().userInfoModel?.lName ?? ""}"
              : "";
          if (addressModel != null) {
            Get.find<LocationController>().saveUserAddress(addressModel);
          }
        }
        update();
      },
    );
  }

  bool showReferWelcomeDialog() {
    if (_userInfoModel != null &&
        _userInfoModel!.referredBy != null &&
        _userInfoModel!.bookingsCount != null &&
        _userInfoModel!.bookingsCount! < 1) {
      return true;
    } else {
      return false;
    }
  }

  Future removeUser() async {
    _isLoading = true;
    update();
    Response response = await userRepo.deleteUser();
    _isLoading = false;
    if (response.statusCode == 200) {
      customSnackBar('your_account_remove_successfully'.tr);
      Get.find<AuthController>().clearSharedData();
      Get.find<AuthController>().googleLogout();
      Get.find<AuthController>().signOutWithFacebook();
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      Get.back();
      ApiChecker.checkApi(response);
    }
  }

  void pickProfileImage() async {
    _pickedProfileImageFile = await FileValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
    );
    update();
  }

  Future<void> removeProfileImage() async {
    _pickedProfileImageFile = null;
  }

  void updateEditProfilePage(
    EditProfileTabControllerState editProfileTabControllerState, {
    bool shouldUpdate = true,
  }) {
    editProfilePageCurrentState = editProfileTabControllerState;
    if (shouldUpdate) {
      update();
    }
  }

  Future<void> updateUserProfile({required UserInfoModel userInfoModel}) async {
    _isLoading = true;
    update();
    Response response = await userRepo.updateProfile(
      userInfoModel,
      pickedProfileImageFile,
    );

    if (response.body['response_code'] == 'default_update_200') {
      customSnackBar(
        '${response.body['response_code']}'.tr,
        type: ToasterMessageType.success,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    await Get.find<UserController>().getUserInfo(reload: false);
    _isLoading = false;
    update();
  }
}
.. and below is my athlete user controller.. import 'package:afriendorse/athlete/feature/settings/business/controller/identity_controller.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
//
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

  var countryDialCode = "+880";

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
    //getProviderInfo();
    companyNameController = TextEditingController();
    companyPhoneController = TextEditingController();
    companyEmailController = TextEditingController();

    personalNameController = TextEditingController();
    personalPhoneController = TextEditingController();
    personalEmailController = TextEditingController();

    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    countryDialCode = CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
    ).dialCode!;
  }

  @override
  void onClose() {
    companyNameController!.dispose();
    companyPhoneController!.dispose();
    companyEmailController!.dispose();
    personalNameController!.dispose();
    personalPhoneController!.dispose();
    personalEmailController!.dispose();

    emailController!.dispose();
    passwordController!.dispose();
    confirmPasswordController!.dispose();
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

        countryDialCode =
            ValidationHelper.getValidCountryCode(
                  _providerModel?.content?.providerInfo?.companyPhone ?? "",
                ) !=
                ""
            ? ValidationHelper.getValidCountryCode(
                _providerModel?.content?.providerInfo?.companyPhone ?? "",
              )
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>()
                        .configModel
                        .content!
                        .countryCode!,
                  ).dialCode ??
                  "+880";
        companyPhoneController!.text =
            ValidationHelper.getValidPhone(
                  _providerModel?.content?.providerInfo?.companyPhone ?? "",
                ) !=
                ""
            ? ValidationHelper.getValidPhone(
                _providerModel?.content?.providerInfo?.companyPhone ?? "",
              )
            : _providerModel?.content?.providerInfo?.companyPhone ?? "";

        companyEmailController!.text =
            _providerModel?.content?.providerInfo?.companyEmail ?? "";
        personalNameController!.text =
            _providerModel?.content?.providerInfo?.contactPersonName ?? "";
        personalPhoneController!.text =
            ValidationHelper.getValidPhone(
                  _providerModel?.content?.providerInfo?.contactPersonPhone ??
                      "",
                ) !=
                ""
            ? ValidationHelper.getValidPhone(
                _providerModel?.content?.providerInfo?.contactPersonPhone ?? "",
              )
            : _providerModel?.content?.providerInfo?.contactPersonPhone ?? "";
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

        _providerId = _providerModel!.content!.providerInfo!.id!;
        myZoneId = _providerModel!.content!.providerInfo!.zoneId!;
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

        if (_providerModel!.content!.bookingOverview != [] &&
            _providerModel!.content!.bookingOverview != null) {
          for (var element in _providerModel!.content!.bookingOverview!) {
            if (element.bookingStatus == 'accepted') {
              _totalAcceptedRequest = element.total!;
            } else if (element.bookingStatus == "canceled") {
              _totalCanceledRequest = element.total!;
            } else if (element.bookingStatus == "completed") {
              _totalCompleteRequest = element.total!;
            } else if (element.bookingStatus == "ongoing") {
              _totalOngoingRequest = element.total!;
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
      identityNumber: identityNumber,
      identityType: Get.find<IdentityController>().selectedIdentityType,
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
      if (response!.statusCode == 200) {
        zoneList = [];

        List<dynamic>? list = response.body['content']['data'];

        if (zoneList.isEmpty) {
          for (var element in list!) {
            zoneList.add(ZoneData.fromJson(element));
          }
        }

        if (zoneList.isNotEmpty && _providerModel != null) {
          for (var element in zoneList) {
            if (element.id == _providerModel!.content!.providerInfo!.zoneId!) {
              myZone = element.name!;
            }
          }
        }
      } else {}
    } else {
      if (_providerModel != null) {
        for (var element in zoneList) {
          if (element.id == _providerModel!.content!.providerInfo!.zoneId!) {
            myZone = element.name!;
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
        } else {
          // //numberOfShowDialog = 0;
          // _showOverflowDialog = false;
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
... do you get my point now?